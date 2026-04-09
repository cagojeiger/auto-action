# graceful-demo

K8s 파드 종료 시 graceful shutdown 실험을 위한 데모 HTTP 서버.

## 엔드포인트

| 경로 | 설명 |
|------|------|
| `GET /` | 즉시 200 응답. 파드 이름과 시각 반환 |
| `GET /slow?ms=N` | N밀리초 후 200 응답. 처리 중 종료 재현용 (기본 3000ms) |
| `GET /health` | readiness/liveness probe용 |

## 환경변수

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `GRACEFUL` | `false` | `true`: SIGTERM 시 기존 요청 마무리 후 종료. `false`: 즉시 종료 |
| `POD_NAME` | `unknown` | 응답/로그에 표시할 파드 이름. `fieldRef: metadata.name`으로 주입 |

## 실험 시나리오

4가지 조합으로 롤링 배포 중 5xx 발생 여부를 비교한다.

| | preStop 없음 | preStop: sleep 5 |
|---|---|---|
| **GRACEFUL=false** | 5xx 많음 | 5xx 줄어듦 (처리 중이던 건 실패) |
| **GRACEFUL=true** | 5xx 일부 (새 요청이 죽어가는 파드로) | 5xx 없음 |

## 로컬 테스트

```bash
docker build -t graceful-demo .
docker run -p 8080:8080 -e GRACEFUL=true -e POD_NAME=local graceful-demo
```

## K8s 배포 예시

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: graceful-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: graceful-demo
  template:
    metadata:
      labels:
        app: graceful-demo
    spec:
      terminationGracePeriodSeconds: 40
      containers:
        - name: demo
          image: cagojeiger/graceful-demo:latest
          ports:
            - containerPort: 8080
          env:
            - name: GRACEFUL
              value: "true"
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 2
            periodSeconds: 5
          lifecycle:
            preStop:
              exec:
                command: ["sleep", "5"]
---
apiVersion: v1
kind: Service
metadata:
  name: graceful-demo
spec:
  selector:
    app: graceful-demo
  ports:
    - port: 80
      targetPort: 8080
```

## 부하 테스트

```bash
# 별도 파드에서 지속적으로 요청
kubectl run loadgen --image=busybox --rm -it -- sh -c \
  'while true; do wget -qO- --timeout=2 http://graceful-demo/slow?ms=1000 || echo "FAIL $(date)"; done'
```
