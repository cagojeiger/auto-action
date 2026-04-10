package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"
)

func main() {
	graceful := strings.ToLower(os.Getenv("GRACEFUL")) == "true"
	podName := os.Getenv("POD_NAME")
	if podName == "" {
		podName = "unknown"
	}

	// graceful drain 최대 대기 시간 (초). 기본 30초.
	shutdownTimeoutSec := 30
	if v := os.Getenv("SHUTDOWN_TIMEOUT_SEC"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 {
			shutdownTimeoutSec = n
		}
	}

	mux := http.NewServeMux()

	// 즉시 응답 — 어떤 파드가 응답했는지 확인용
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}
		fmt.Fprintf(w, "pod=%s time=%s\n", podName, time.Now().Format(time.RFC3339Nano))
	})

	// 지연 응답 — 처리 중 종료 재현용
	mux.HandleFunc("/slow", func(w http.ResponseWriter, r *http.Request) {
		ms, _ := strconv.Atoi(r.URL.Query().Get("ms"))
		if ms <= 0 {
			ms = 3000
		}
		log.Printf("[REQ] /slow?ms=%d started on %s", ms, podName)
		time.Sleep(time.Duration(ms) * time.Millisecond)
		fmt.Fprintf(w, "pod=%s delayed=%dms\n", podName, ms)
		log.Printf("[REQ] /slow?ms=%d completed on %s", ms, podName)
	})

	// probe용
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, "ok")
	})

	srv := &http.Server{
		Addr:    ":8080",
		Handler: mux,
	}

	// SIGTERM 핸들링
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGTERM, syscall.SIGINT)

	shutdownDone := make(chan struct{})

	go func() {
		sig := <-sigCh
		log.Printf("[SHUTDOWN] signal=%s graceful=%v pod=%s time=%s",
			sig, graceful, podName, time.Now().Format(time.RFC3339Nano))

		if !graceful {
			log.Println("[SHUTDOWN] ungraceful — exiting immediately")
			os.Exit(0)
		}

		// graceful shutdown: 새 연결 거부 + 기존 요청 마무리
		log.Printf("[SHUTDOWN] graceful — draining connections (timeout=%ds)", shutdownTimeoutSec)
		ctx, cancel := context.WithTimeout(context.Background(), time.Duration(shutdownTimeoutSec)*time.Second)
		defer cancel()
		if err := srv.Shutdown(ctx); err != nil {
			log.Printf("[SHUTDOWN] error: %v", err)
		}
		log.Println("[SHUTDOWN] graceful shutdown complete")
		close(shutdownDone)
	}()

	log.Printf("[START] pod=%s graceful=%v addr=:8080", podName, graceful)
	if err := srv.ListenAndServe(); err != http.ErrServerClosed {
		log.Fatalf("[FATAL] %v", err)
	}

	// graceful shutdown이 끝날 때까지 main 대기 (in-flight 요청 drain 보장)
	if graceful {
		<-shutdownDone
	}
}
