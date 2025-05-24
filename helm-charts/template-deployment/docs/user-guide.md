# Template-deployment 사용자 가이드

## 목차
1. [소개](#소개)
2. [빠른 시작](#빠른-시작)
3. [핵심 개념](#핵심-개념)
4. [기본 사용법](#기본-사용법)
5. [고급 기능](#고급-기능)
6. [실전 예제](#실전-예제)
7. [문제 해결](#문제-해결)

## 소개

Template-deployment는 쿠버네티스에서 여러 워크로드를 하나의 헬름 차트로 배포할 수 있게 해주는 메타 차트입니다. 템플릿 상속을 통해 설정을 재사용하고, 복잡한 멀티서비스 애플리케이션을 쉽게 관리할 수 있습니다.

### 주요 특징
- 🔄 **템플릿 상속**: 공통 설정을 한 번만 정의하고 재사용
- 🚀 **멀티 배포**: 하나의 차트로 여러 서비스 동시 배포
- 🎯 **타입 시스템**: 서비스 타입별 기본값 정의
- 🔧 **유연한 설정**: 세밀한 커스터마이징 가능
- 📦 **ConfigMap/Secret 관리**: 템플릿별 설정 파일 자동 생성 및 마운트
- 🌐 **향상된 Ingress**: 경로별 백엔드 서비스 커스터마이징

## 빠른 시작

### 1. 차트 의존성 추가

`Chart.yaml`:
```yaml
dependencies:
  - name: template-deployment
    version: "0.4.0"
    repository: "https://your-helm-repo.com"
```

### 2. 기본 설정

`values.yaml`:
```yaml
template-deployment:
  templates:
    - name: web
      image:
        repository: nginx
        tag: latest
      service:
        port: 80
```

### 3. 설치

```bash
helm dependency update
helm install my-app .
```

## 핵심 개념

### Templates 배열

`templates`는 배포할 워크로드들을 정의하는 배열입니다:

```yaml
templates:
  - name: frontend   # 첫 번째 서비스
  - name: backend    # 두 번째 서비스
  - name: worker     # 세 번째 서비스
```

### Template Defaults

모든 템플릿에 공통으로 적용되는 기본값을 정의합니다:

```yaml
templateDefaults:
  default:           # 모든 템플릿에 적용
    replicas: 2
    image:
      pullPolicy: IfNotPresent
```

### Type 시스템

타입을 통해 유사한 서비스들의 공통 설정을 관리합니다:

```yaml
templateDefaults:
  web:               # 웹 서비스 타입
    service:
      port: 80
  worker:            # 워커 타입
    service:
      enabled: false
```

## 기본 사용법

### 단일 서비스 배포

```yaml
template-deployment:
  templates:
    - name: api
      image:
        repository: myapp/api
        tag: v1.0.0
      replicas: 3
      service:
        port: 8080
      ingress:
        enabled: true
        hosts:
          - api.example.com
```

### 멀티 서비스 배포

```yaml
template-deployment:
  templates:
    # 웹 프론트엔드
    - name: frontend
      type: web
      image:
        repository: myapp/frontend
        tag: v2.0.0
      
    # API 백엔드
    - name: backend
      type: [web, loadbalanced]
      image:
        repository: myapp/backend
        tag: v2.0.0
      env:
        - name: DATABASE_URL
          value: postgresql://db:5432
    
    # 백그라운드 워커
    - name: worker
      type: worker
      image:
        repository: myapp/worker
        tag: v2.0.0
```

### 환경 변수 설정

```yaml
templates:
  - name: web
    env:
      # 직접 값 설정
      - name: LOG_LEVEL
        value: info
      
      # ConfigMap에서 가져오기
      - name: APP_CONFIG
        valueFrom:
          configMapKeyRef:
            name: app-config
            key: config.json
      
      # Secret에서 가져오기
      - name: API_KEY
        valueFrom:
          secretKeyRef:
            name: api-secrets
            key: api-key
    
    # 전체 ConfigMap 참조
    envFrom:
      - configMapRef:
          name: app-config
      - secretRef:
          name: app-secrets
```

### 볼륨 설정

```yaml
templates:
  - name: web
    volumeMounts:
      - name: data
        mountPath: /data
      - name: config
        mountPath: /etc/app
    
    volumes:
      - name: data
        persistentVolumeClaim:
          claimName: app-data
      - name: config
        configMap:
          name: app-config
```

## 고급 기능

### 템플릿 상속

```yaml
templateDefaults:
  # 기본 Django 앱 설정
  django-app:
    image:
      pullPolicy: IfNotPresent
    command: ["python", "manage.py", "runserver"]
    env:
      - name: DJANGO_SETTINGS_MODULE
        value: settings.production
    probes:
      liveness:
        httpGet:
          path: /health
          port: 8000
      readiness:
        httpGet:
          path: /ready
          port: 8000

templates:
  # Django 앱 타입 상속
  - name: web
    type: django-app
    args: ["0.0.0.0:8000"]
    
  - name: celery
    type: django-app
    command: ["celery", "worker"]
    probes:
      enabled: false  # 워커는 HTTP 프로브 불필요
```

### 멀티 타입 상속

```yaml
templateDefaults:
  web:
    service:
      port: 80
  
  loadbalanced:
    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 10
  
  cached:
    env:
      - name: CACHE_ENABLED
        value: "true"

templates:
  - name: api
    type: [web, loadbalanced, cached]  # 세 가지 타입 모두 상속
    image:
      repository: myapp/api
```

### 조건부 배포

```yaml
templates:
  - name: monitoring
    image:
      repository: prometheus/node-exporter
    # 모니터링이 활성화된 경우에만 배포
    enabled: "{{ .Values.monitoring.enabled }}"
```

### HPA (자동 스케일링) 설정

```yaml
templates:
  - name: api
    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 10
      targetCPUUtilizationPercentage: 70
      targetMemoryUtilizationPercentage: 80
```

### PodDisruptionBudget 설정

```yaml
templates:
  - name: web
    podDisruptionBudget:
      enabled: true
      minAvailable: 1
      # 또는
      maxUnavailable: 1
```

### ConfigMap/Secret 관리 (v0.6.0+)

템플릿별로 여러 개의 ConfigMap과 Secret을 생성하고 자동으로 관리할 수 있습니다:

```yaml
templates:
  - name: web
    configMaps:
      # 첫 번째 ConfigMap
      - name: app-config
        data:
          DATABASE_URL: "postgres://localhost:5432/db"
          REDIS_URL: "redis://localhost:6379"
        envFrom: true  # 환경변수로 자동 로드
        
      # 두 번째 ConfigMap - 파일로 마운트
      - name: nginx-config
        data:
          nginx.conf: |
            server {
              listen 80;
              server_name localhost;
            }
        volumeMount:
          mountPath: /etc/nginx/conf.d
          defaultMode: 0644
    
    # Secret 관리
    secrets:
      - name: api-keys
        stringData:
          API_KEY: "secret-key-123"
          JWT_SECRET: "jwt-secret-456"
        envFrom: true
      
      # 파일로 마운트할 Secret
      - name: certificates
        data:
          tls.crt: "base64-encoded-cert"
          tls.key: "base64-encoded-key"
        volumeMount:
          mountPath: /etc/ssl/certs
          readOnly: true
```

### 향상된 Ingress 설정 (v0.6.0+)

더 유연한 Ingress 설정을 지원합니다:

```yaml
templates:
  - name: web
    ingress:
      enabled: true
      className: nginx
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: "/$2"
        nginx.ingress.kubernetes.io/proxy-body-size: "50m"
      
      # 새로운 rules 형식 - 경로별 백엔드 설정
      rules:
        - host: api.example.com
          paths:
            - path: /v1(/|$)(.*)
              pathType: ImplementationSpecific
              backend:
                service:
                  name: api-v1-service
                  port: 8080
            - path: /v2(/|$)(.*)
              pathType: ImplementationSpecific
              backend:
                service:
                  name: api-v2-service
                  port: 8090
        
        - host: admin.example.com
          paths:
            - path: /
              pathType: Prefix
              # backend 생략 시 템플릿의 서비스 사용
```

## 실전 예제

### 1. 마이크로서비스 애플리케이션

```yaml
template-deployment:
  # 글로벌 설정
  global:
    imageRegistry: myregistry.io
    imagePullSecrets:
      - name: registry-secret
  
  # 타입별 기본값
  templateDefaults:
    default:
      resources:
        requests:
          memory: 128Mi
          cpu: 100m
        limits:
          memory: 512Mi
          cpu: 500m
    
    web:
      service:
        port: 8000
      ingress:
        enabled: true
        className: nginx
    
    worker:
      service:
        enabled: false
  
  # 서비스 정의
  templates:
    # API 게이트웨이
    - name: gateway
      type: web
      image:
        repository: services/gateway
        tag: v1.2.0
      ingress:
        hosts:
          - api.example.com
        paths:
          - path: /
            pathType: Prefix
    
    # 사용자 서비스
    - name: user-service
      type: web
      image:
        repository: services/user
        tag: v1.0.0
      env:
        - name: DATABASE_URL
          value: postgresql://user-db:5432/users
    
    # 주문 서비스
    - name: order-service
      type: web
      image:
        repository: services/order
        tag: v1.1.0
      env:
        - name: DATABASE_URL
          value: postgresql://order-db:5432/orders
    
    # 이메일 워커
    - name: email-worker
      type: worker
      image:
        repository: services/email-worker
        tag: v1.0.0
      env:
        - name: SMTP_HOST
          value: smtp.example.com
```

### 2. 개발/운영 환경 분리

`values-dev.yaml`:
```yaml
template-deployment:
  templateDefaults:
    default:
      replicas: 1
      resources:
        requests:
          memory: 64Mi
          cpu: 50m
```

`values-prod.yaml`:
```yaml
template-deployment:
  templateDefaults:
    default:
      replicas: 3
      resources:
        requests:
          memory: 256Mi
          cpu: 200m
    
    web:
      autoscaling:
        enabled: true
        minReplicas: 3
        maxReplicas: 20
```

## 문제 해결

### 1. 템플릿이 생성되지 않음

**증상**: 정의한 템플릿이 배포되지 않음

**해결책**:
- `name` 필드가 있는지 확인
- `image.repository`가 정의되어 있는지 확인
- `enabled: false`로 설정되어 있지 않은지 확인

### 2. 상속이 작동하지 않음

**증상**: templateDefaults의 값이 적용되지 않음

**해결책**:
- 타입 이름이 정확한지 확인
- 템플릿에서 값을 덮어쓰고 있지 않은지 확인
- 딥 머지 동작 이해: 배열과 기본값은 교체됨

### 3. 서비스 간 통신 문제

**증상**: 서비스가 서로를 찾지 못함

**해결책**:
```yaml
# 서비스 이름을 통한 접근
http://{{ template-name }}.{{ .Release.Namespace }}.svc.cluster.local:{{ port }}

# 예시
http://backend.default.svc.cluster.local:8000
```

### 4. 리소스 제한 관련 문제

**증상**: 파드가 Pending 또는 CrashLoopBackOff 상태

**해결책**:
- 리소스 요청량이 클러스터 용량 내에 있는지 확인
- limits가 requests보다 크거나 같은지 확인
- 노드의 가용 리소스 확인

## 향후 개선 계획

실제 프로덕션 환경의 복잡한 멀티서비스 애플리케이션 분석을 통해 다음과 같은 개선 사항들이 계획되어 있습니다:

### 1. 템플릿 상속 강화
- **템플릿 베이스**: 재사용 가능한 기본 템플릿 정의
- **다단계 상속**: 템플릿이 다른 템플릿을 확장
- **조건부 상속**: 환경에 따른 동적 상속

### 2. 서비스 디스커버리
- 서비스 간 URL 자동 생성 헬퍼 함수
- 외부 차트 의존성과의 연동 간소화

### 3. 멀티 컨테이너 지원
- 사이드카 패턴 네이티브 지원
- 컨테이너 간 볼륨 공유 자동화

### 4. 고급 볼륨 관리
- 볼륨 템플릿 재사용
- 동적 볼륨 프로비저닝 지원

### 5. 조건부 리소스 생성
- 템플릿 수준의 조건부 활성화
- 리소스별 세밀한 조건 설정

## 다음 단계

- [템플릿 상속 상세 가이드](./template-inheritance.md)
- [API 레퍼런스](./api-reference.md)