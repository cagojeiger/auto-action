# Tmpl Apps 헬름 차트 가이드

## 소개

Tmpl Apps는 쿠버네티스에서 멀티 애플리케이션 배포를 혁신적으로 간소화하는 헬름 차트입니다. 복잡한 YAML 설정을 최소화하고, 스마트한 기본값과 자동 연결 기능을 제공합니다.

## 핵심 철학

### 1. **간결함이 힘이다**
```yaml
# 기존 방식
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: my-app
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
spec:
  rules:
  - host: my-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app
            port:
              number: 80

# Tmpl Apps 방식
apps:
  my-app:
    image: nginx:latest
    scale: 3
    expose: 80
    host: my-app
```

### 2. **프로파일로 패턴화**

일반적인 애플리케이션 패턴을 프로파일로 정의하여 재사용:

- **web**: 프론트엔드 애플리케이션
- **api**: 백엔드 API 서비스
- **worker**: 백그라운드 작업자
- **database**: 데이터 저장소

### 3. **자동 연결**

서비스 간 연결을 자동으로 처리하여 수동 설정을 제거합니다.

## 주요 기능 상세

### 스마트 축약어

| 축약어 | 실제 의미 | 예시 |
|--------|-----------|------|
| `scale` | `replicas` | `scale: 3` → 3개의 파드 |
| `expose` | `service.port` + `service.enabled: true` | `expose: 8080` → 8080 포트로 서비스 노출 |
| `host` | `ingress.host` + `ingress.enabled: true` | `host: api` → api.example.com으로 인그레스 생성 |
| `connections` | 환경변수 자동 생성 | `connections: [redis]` → `REDIS_URL` 환경변수 |
| `database` | 데이터베이스 URL 생성 | `database: postgres` → `DATABASE_URL` 환경변수 |

### 프로파일 상속 시스템

```yaml
# 1. 기본 프로파일 정의
profiles:
  microservice:
    replicas: 2
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
    probes:
      liveness:
        httpGet:
          path: /health
      readiness:
        httpGet:
          path: /ready

  # 2. 프로파일 확장
  public-api:
    extends: microservice
    replicas: 3
    ingress:
      enabled: true
      className: nginx

# 3. 사용
apps:
  user-service:
    profile: public-api
    image: user-service:v1
    host: users  # users.example.com
```

### 자동 서비스 디스커버리

```yaml
apps:
  frontend:
    profile: web
    image: frontend:latest
    connections:
      - backend    # BACKEND_URL=http://release-backend:8080
      - auth       # AUTH_URL=http://release-auth:9000

  backend:
    profile: api
    image: backend:latest
    expose: 8080
    database: postgres  # DATABASE_URL=postgresql://postgres:5432/backend

  auth:
    profile: api
    image: auth:latest
    expose: 9000

  postgres:
    profile: database
    image: postgres:14
```

## 실전 패턴

### 1. 마이크로서비스 스택

```yaml
apps:
  # API 게이트웨이
  gateway:
    profile: api
    image: kong:latest
    host: api
    connections:
      - user-service
      - order-service
      - payment-service

  # 개별 서비스들
  user-service:
    profile: api
    image: services/user:v1
    expose: 8001
    database: postgres

  order-service:
    profile: api
    image: services/order:v1
    expose: 8002
    database: postgres
    connections:
      - inventory-service
      - notification-service

  # 워커
  notification-worker:
    profile: worker
    image: workers/notification:v1
    connections:
      - redis
      - notification-service
```

### 2. 웹 애플리케이션 + API

```yaml
apps:
  # SPA 프론트엔드
  frontend:
    profile: web
    image: frontend:latest
    host: www
    config:
      data:
        config.json: |
          {
            "apiUrl": "https://api.example.com",
            "features": ["auth", "dashboard"]
          }
      mount:
        path: /usr/share/nginx/html/config

  # API 백엔드
  api:
    profile: api
    image: api:latest
    host: api
    scale: 5
    database: postgres
    secrets:
      env:
        JWT_SECRET: "your-secret"
        API_KEY: "api-key"

  # 캐시
  redis:
    image: redis:alpine
    expose: 6379
```

### 3. 개발 환경 vs 프로덕션

```yaml
# values-dev.yaml
global:
  domain: dev.local

profiles:
  web:
    replicas: 1
    resources:
      requests:
        cpu: 50m
        memory: 64Mi

apps:
  app:
    profile: web
    image: app:dev
    env:
      DEBUG: "true"
```

```yaml
# values-prod.yaml
global:
  domain: production.com

profiles:
  web:
    replicas: 3
    resources:
      requests:
        cpu: 200m
        memory: 256Mi
    autoscaling:
      enabled: true
      minReplicas: 3
      maxReplicas: 10

apps:
  app:
    profile: web
    image: app:v1.0.0
    env:
      DEBUG: "false"
    ingress:
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-prod
      tls: true
```

## 고급 팁

### 1. 설정 관리

```yaml
apps:
  api:
    # 환경변수로 설정
    env:
      LOG_LEVEL: info
    
    # ConfigMap으로 설정 파일
    config:
      data:
        application.yaml: |
          server:
            port: 8080
          database:
            pool: 10
      mount:
        path: /app/config
    
    # Secret으로 민감한 데이터
    secrets:
      env:
        DB_PASSWORD: "secure-password"
```

### 2. 볼륨 관리

```yaml
apps:
  postgres:
    profile: database
    persistence:
      size: 100Gi
      storageClass: fast-ssd
    
  app:
    volumes:
      - name: data
        persistentVolumeClaim:
          claimName: app-data
    volumeMounts:
      - name: data
        mountPath: /data
```

### 3. 헬스체크 커스터마이징

```yaml
profiles:
  custom-api:
    extends: api
    probes:
      liveness:
        httpGet:
          path: /healthz
          port: 8080
        initialDelaySeconds: 30
        periodSeconds: 30
      readiness:
        httpGet:
          path: /readyz
          port: 8080
        initialDelaySeconds: 10
        periodSeconds: 10
      startup:
        httpGet:
          path: /startupz
          port: 8080
        failureThreshold: 30
        periodSeconds: 10
```

## 문제 해결

### 서비스가 연결되지 않을 때

1. 연결 이름 확인:
   ```yaml
   connections:
     - backend  # 정확한 앱 이름인지 확인
   ```

2. 서비스 포트 확인:
   ```yaml
   backend:
     expose: 8080  # 포트가 정의되어 있는지 확인
   ```

### 환경변수가 설정되지 않을 때

1. ConfigMap/Secret 생성 확인:
   ```bash
   kubectl get configmap
   kubectl get secret
   ```

2. 마운트 경로 충돌 확인

### 이미지 풀 실패

1. imagePullSecrets 설정:
   ```yaml
   global:
     imagePullSecrets:
       - name: regcred
   ```

## 마이그레이션 가이드

### 기존 Kubernetes YAML에서 마이그레이션

1. Deployment 분석
2. Service 포트 확인
3. Ingress 호스트 확인
4. ConfigMap/Secret 통합
5. Tmpl Apps 형식으로 변환

### 기존 Helm 차트에서 마이그레이션

1. values.yaml 구조 분석
2. 템플릿 로직 이해
3. 프로파일 매핑
4. 앱 정의 작성

## 베스트 프랙티스

1. **프로파일 우선**: 개별 앱 설정보다 프로파일로 표준화
2. **축약어 활용**: `scale`, `expose`, `host` 등 활용
3. **연결 자동화**: `connections`와 `database` 활용
4. **환경 분리**: 환경별 values 파일 분리
5. **버전 관리**: 이미지 태그는 명시적으로

## 결론

Tmpl Apps는 쿠버네티스 배포의 복잡성을 획기적으로 줄입니다. 프로파일 기반 접근과 스마트한 기본값으로 개발자는 인프라 설정보다 애플리케이션 로직에 집중할 수 있습니다.