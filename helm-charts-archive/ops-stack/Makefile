################################################################################
# 변수 정의
################################################################################
SHELL := /bin/bash
GIT_ROOT := $(shell git rev-parse --show-toplevel 2>/dev/null || echo "$$(pwd)")
LOCAL_BIN := $(GIT_ROOT)/.bin
GOMPLATE_BIN := $(LOCAL_BIN)/gomplate
VALUES_TMPL := values.yaml.tmpl
VALUES_FILE := values.yaml
VARS_FILE := vars.yaml
UNAME_S := $(shell uname -s)

################################################################################
# .PHONY 타겟 정의
################################################################################
.PHONY: all help template install-gomplate install uninstall

################################################################################
# 기본 타겟
################################################################################
all: help

################################################################################
# 도움말
################################################################################
help:
	@echo "사용 가능한 명령어:"
	@echo "  make                 - 이 도움말 메시지 표시"
	@echo "  make template        - values.yaml 템플릿 생성"
	@echo "  make install-gomplate - gomplate 도구 설치 (macOS 전용)"
	@echo "  make install         - Helm 차트 배포/업그레이드"
	@echo "  make uninstall       - Helm 차트 언인스톨"

################################################################################
# Gomplate 설치 (macOS 전용)
################################################################################
install-gomplate:
	@if [ -f $(GOMPLATE_BIN) ]; then \
		echo "gomplate가 이미 설치되어 있습니다: $(GOMPLATE_BIN)"; \
	else \
		echo "gomplate 도구 설치 중..."; \
		if [ "$(UNAME_S)" = "Darwin" ]; then \
			mkdir -p $(LOCAL_BIN); \
			curl -o $(GOMPLATE_BIN) -sSL https://github.com/hairyhenderson/gomplate/releases/latest/download/gomplate_darwin-arm64 || { \
				echo "오류: gomplate 다운로드 실패"; \
				exit 1; \
			}; \
			chmod 755 $(GOMPLATE_BIN); \
			echo "gomplate 설치 완료: $(GOMPLATE_BIN)"; \
		else \
			echo "이 명령어는 macOS에서만 지원됩니다."; \
			exit 1; \
		fi; \
	fi

################################################################################
# 템플릿 생성
################################################################################
template:
	@echo "values.yaml 파일 생성 중..."
	@if [ ! -f $(VALUES_TMPL) ]; then \
		echo "오류: $(VALUES_TMPL) 파일을 찾을 수 없습니다."; \
		exit 1; \
	fi
	@if [ ! -f $(VARS_FILE) ]; then \
		echo "오류: $(VARS_FILE) 파일을 찾을 수 없습니다."; \
		exit 1; \
	fi
	@if [ ! -f $(GOMPLATE_BIN) ]; then \
		$(MAKE) install-gomplate; \
	fi
	@$(GOMPLATE_BIN) -f $(VALUES_TMPL) -c vars=$(VARS_FILE) > $(VALUES_FILE) || { \
		echo "오류: values.yaml 생성 실패"; \
		exit 1; \
	}
	@echo "values.yaml 파일 생성 완료"

################################################################################
# Helm 차트 배포/업그레이드
################################################################################
install:
	helm upgrade --install ops-stack . -n ops-stack --create-namespace -f values.yaml

################################################################################
# Helm 차트 언인스톨
################################################################################
uninstall:
	helm uninstall ops-stack -n ops-stack