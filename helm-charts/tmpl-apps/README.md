# Tmpl Apps 헬름 차트

스마트한 기본값과 프로파일 기반 설정으로 여러 쿠버네티스 애플리케이션을 배포하세요.

## 주요 기능

- 🎯 **프로파일 기반 설정** - 재사용 가능한 프로파일 정의 (web, api, worker, database)
- 🔄 **스마트 기본값** - 최소한의 설정으로 합리적인 기본값 제공
- 🔗 **자동 연결** - 자동 서비스 디스커버리와 연결 문자열 생성
- 📦 **멀티앱 배포** - 하나의 차트로 전체 스택 배포
- 🚀 **개발자 친화적** - 간단한 문법으로 강력한 기능 구현

## 빠른 시작

### 설치

```bash
helm install my-apps ./tmpl-apps -f values.yaml
```

### 최소 설정

```yaml
apps:
  frontend:
    profile: web
    image: nginx:alpine
    host: www  # 자동으로 www.example.com으로 확장

  backend:
    profile: api
    image: myapp/api:v1
    scale: 3  # replicas의 축약형
    expose: 8080  # service.port의 축약형
```

## 프로파일

일반적인 애플리케이션 타입에 대한 사전 구성된 설정을 제공합니다:

- **`base`** - 모든 앱의 기본 설정
- **`web`** - 인그레스가 포함된 웹 애플리케이션
- **`api`** - 메트릭이 포함된 API 서비스
- **`worker`** - 서비스가 없는 백그라운드 워커
- **`database`** - 영구 저장소가 있는 데이터베이스

### 프로파일 사용

```yaml
apps:
  myapp:
    profile: web  # 모든 web 프로파일 설정을 상속
    image: myapp:latest
    # 특정 설정만 오버라이드
    replicas: 5
```

### 프로파일 상속

```yaml
profiles:
  custom-web:
    extends: web  # web 프로파일에서 상속
    replicas: 4
    resources:
      requests:
        memory: "256Mi"
```

## 설정 예제

### 완전한 웹 애플리케이션

```yaml
apps:
  webapp:
    profile: web
    image: myapp/web:v2.0.0
    host: app.mycompany.com
    replicas: 3
    
    env:
      API_URL: "https://api.mycompany.com"
      ENVIRONMENT: "production"
    
    config:
      data:
        config.json: |
          {
            "theme": "dark",
            "features": ["auth", "dashboard"]
          }
      mount:
        path: /usr/share/nginx/html/config
    
    ingress:
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt
      tls: true
```

### 데이터베이스를 사용하는 API

```yaml
apps:
  api:
    profile: api
    image: myapp/api:v1.5.0
    expose: 3000
    database: postgres  # DATABASE_URL 자동 생성
    
    secrets:
      env:
        JWT_SECRET: "change-me-in-production"
        API_KEY: "secret-api-key"
    
    resources:
      requests:
        cpu: 200m
        memory: 512Mi
      limits:
        cpu: 1000m
        memory: 1Gi

  postgres:
    profile: database
    image: postgres:14
    persistence:
      size: 50Gi
      storageClass: fast-ssd
    env:
      POSTGRES_DB: myapp
    secrets:
      env:
        POSTGRES_PASSWORD: "secure-password"
```

### 연결된 마이크로서비스

```yaml
apps:
  frontend:
    profile: web
    image: frontend:latest
    host: www
    connections:
      - backend
      - auth

  backend:
    profile: api
    image: backend:latest
    expose: 8080
    connections:
      - redis
      - postgres

  auth:
    profile: api
    image: auth-service:latest
    expose: 9000

  worker:
    profile: worker
    image: worker:latest
    connections:
      - redis
      - backend

  redis:
    image: redis:7-alpine
    expose: 6379

  postgres:
    profile: database
    image: postgres:14
```

## 스마트 기능

### 자동 생성되는 환경 변수

```yaml
apps:
  frontend:
    connections:
      - backend
    # 자동 생성: BACKEND_URL=http://release-backend:8080

  api:
    database: postgres
    # 자동 생성: DATABASE_URL=postgresql://postgres:5432/api
```

### 간소화된 문법

```yaml
apps:
  myapp:
    image: nginx
    scale: 5        # → replicas: 5
    expose: 8080    # → service.port: 8080, service.enabled: true
    host: api       # → ingress.host: api.example.com, ingress.enabled: true
```

## 설정 참조

### 앱 설정

| 필드 | 설명 | 기본값 |
|-------|-------------|---------|
| `profile` | 상속할 기본 프로파일 | `base` |
| `image` | 컨테이너 이미지 | 필수 |
| `replicas` | 복제본 수 | `1` |
| `scale` | replicas의 축약형 | - |
| `expose` | service.port의 축약형 | - |
| `host` | ingress.host의 축약형 | - |
| `env` | 환경 변수 | `{}` |
| `config` | ConfigMap 데이터와 마운트 | - |
| `secrets` | Secret 데이터와 환경 변수 | - |
| `connections` | 앱 의존성 목록 | `[]` |
| `database` | 데이터베이스 연결 도우미 | - |

### 고급 설정

모든 표준 쿠버네티스 배포 옵션을 지원합니다:

- `command`, `args`
- `resources`
- `probes` (liveness, readiness, startup)
- `volumeMounts`, `volumes`
- `nodeSelector`, `affinity`, `tolerations`
- `service.*` (모든 서비스 옵션)
- `ingress.*` (모든 인그레스 옵션)

## 테스트

```bash
# 드라이런
helm install my-apps ./tmpl-apps --dry-run --debug

# 템플릿 출력
helm template my-apps ./tmpl-apps

# 린트
helm lint ./tmpl-apps
```

## 라이선스

Apache 2.0