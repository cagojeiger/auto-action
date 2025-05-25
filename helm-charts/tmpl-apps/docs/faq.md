# Tmpl Apps FAQ (자주 묻는 질문)

## 일반 질문

### Q: Tmpl Apps와 일반 헬름 차트의 차이점은 무엇인가요?

**A**: 일반 헬름 차트는 단일 애플리케이션 배포에 초점을 맞춥니다. Tmpl Apps는 여러 애플리케이션을 하나의 차트로 배포하고, 프로파일 기반 설정과 자동 연결 기능을 제공합니다.

```yaml
# 일반 헬름 차트
replicaCount: 3
image:
  repository: nginx
  tag: latest
service:
  type: ClusterIP
  port: 80

# Tmpl Apps
apps:
  web:
    image: nginx:latest
    scale: 3
    expose: 80
```

### Q: template-deployment와 어떻게 다른가요?

**A**: 주요 차이점:

| 특성 | template-deployment | tmpl-apps |
|------|-------------------|-----------|
| 네이밍 | `templates`, `templateDefaults` | `apps`, `profiles` |
| 설정 방식 | 타입 기반 | 프로파일 기반 |
| 축약 문법 | 제한적 | `scale`, `expose`, `host` |
| 자동 연결 | 수동 설정 | `connections` 자동화 |
| 타겟 사용자 | 인프라 엔지니어 | 개발자 친화적 |

### Q: 언제 Tmpl Apps를 사용해야 하나요?

**A**: 다음과 같은 경우에 적합합니다:
- 마이크로서비스 아키텍처
- 여러 관련 애플리케이션을 함께 배포
- 개발/스테이징/프로덕션 환경 관리
- 빠른 프로토타이핑

## 설정 관련

### Q: 프로파일을 어떻게 커스터마이징하나요?

**A**: values.yaml에서 프로파일을 정의하거나 확장할 수 있습니다:

```yaml
profiles:
  # 새 프로파일 생성
  my-api:
    extends: api
    replicas: 5
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
    
  # 기존 프로파일 덮어쓰기
  web:
    replicas: 3
    ingress:
      className: traefik
```

### Q: 여러 환경을 어떻게 관리하나요?

**A**: 환경별 values 파일을 사용합니다:

```bash
# 개발 환경
helm install app ./tmpl-apps -f values-dev.yaml

# 프로덕션 환경
helm install app ./tmpl-apps -f values-prod.yaml

# 오버라이드 체인
helm install app ./tmpl-apps -f values.yaml -f values-prod.yaml -f values-secrets.yaml
```

### Q: 기존 쿠버네티스 리소스와 통합하려면?

**A**: 외부 서비스 참조나 기존 리소스 사용이 가능합니다:

```yaml
apps:
  api:
    env:
      # 외부 서비스 참조
      EXTERNAL_API: "https://external-api.com"
      # 기존 ConfigMap 참조
      CONFIG_VALUE:
        valueFrom:
          configMapKeyRef:
            name: existing-config
            key: value
    
    # 기존 PVC 사용
    volumes:
      - name: data
        persistentVolumeClaim:
          claimName: existing-pvc
    volumeMounts:
      - name: data
        mountPath: /data
```

## 문제 해결

### Q: "nil pointer" 에러가 발생합니다

**A**: 일부 선택적 필드에 대한 nil 체크가 필요합니다. 최신 버전으로 업데이트하거나 다음과 같이 설정하세요:

```yaml
apps:
  myapp:
    image: nginx
    # 명시적으로 비활성화
    probes:
      enabled: false
    metrics:
      enabled: false
```

### Q: 서비스가 서로를 찾지 못합니다

**A**: 다음을 확인하세요:

1. 서비스가 활성화되어 있는지:
   ```yaml
   backend:
     expose: 8080  # 또는 service.enabled: true
   ```

2. 올바른 이름을 사용하는지:
   ```yaml
   frontend:
     connections:
       - backend  # apps에 정의된 정확한 이름
   ```

3. 네임스페이스가 같은지:
   ```bash
   kubectl get svc -n <namespace>
   ```

### Q: 이미지 풀이 실패합니다

**A**: Private 레지스트리를 사용하는 경우:

```yaml
global:
  imagePullSecrets:
    - name: regcred

# Secret 생성
kubectl create secret docker-registry regcred \
  --docker-server=myregistry.io \
  --docker-username=user \
  --docker-password=pass
```

## 고급 사용법

### Q: 사이드카 컨테이너를 추가하려면?

**A**: 현재 버전은 단일 컨테이너만 지원합니다. 임시 해결책:

```yaml
apps:
  myapp:
    # Init 컨테이너로 설정 작업
    initContainers:
      - name: setup
        image: busybox
        command: ['sh', '-c', 'echo "Setup complete"']
```

### Q: StatefulSet을 사용하려면?

**A**: 현재 Deployment만 지원합니다. StatefulSet이 필요한 경우:
- 다른 헬름 차트 사용 (예: bitnami/postgresql)
- 향후 버전 대기 (v0.2.0 예정)

### Q: 커스텀 리소스를 추가하려면?

**A**: `templates/custom/` 디렉토리에 추가 템플릿을 만들 수 있습니다:

```yaml
# templates/custom/my-resource.yaml
{{- range $appName, $appConfig := .Values.apps }}
{{- if $appConfig.customResource }}
apiVersion: custom.io/v1
kind: MyResource
metadata:
  name: {{ include "tmpl-apps.appFullname" (dict "root" $ "app" (set $appConfig "name" $appName)) }}
spec:
  # 커스텀 스펙
{{- end }}
{{- end }}
```

## 성능 및 확장성

### Q: 많은 수의 앱을 배포할 때 성능은?

**A**: Tmpl Apps는 효율적으로 설계되었습니다:
- 템플릿 렌더링은 O(n) 복잡도
- 50개 이상의 앱도 문제없이 처리
- 주요 병목은 쿠버네티스 API 서버

### Q: 리소스 제한을 어떻게 설정하나요?

**A**: 프로파일이나 앱 레벨에서 설정:

```yaml
profiles:
  web:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 1000m
        memory: 512Mi

apps:
  high-memory-app:
    profile: web
    resources:
      limits:
        memory: 2Gi  # 프로파일 오버라이드
```

## 마이그레이션

### Q: 기존 Docker Compose에서 마이그레이션하려면?

**A**: 기본 매핑 가이드:

```yaml
# docker-compose.yml
services:
  web:
    image: nginx
    ports:
      - "80:80"
    environment:
      - API_URL=http://api:8080
    depends_on:
      - api

# values.yaml
apps:
  web:
    image: nginx
    expose: 80
    host: web
    env:
      API_URL: http://api:8080
    connections:
      - api
```

### Q: 기존 쿠버네티스 매니페스트에서 마이그레이션하려면?

**A**: 단계별 접근:

1. Deployment 분석 → `apps.name`
2. Service 확인 → `expose`
3. Ingress 확인 → `host`
4. ConfigMap/Secret → `config`/`secrets`
5. 연결 관계 파악 → `connections`

## 베스트 프랙티스

### Q: 권장하는 네이밍 컨벤션은?

**A**: 
- 앱 이름: 소문자, 하이픈 구분 (`user-service`)
- 프로파일: 역할 기반 (`web`, `api`, `worker`)
- 환경변수: 대문자, 언더스코어 구분 (`API_KEY`)

### Q: 보안 Best Practice는?

**A**:
1. Secret을 values.yaml에 직접 넣지 마세요
2. 별도 values-secrets.yaml 사용
3. Sealed Secrets 또는 External Secrets 활용
4. RBAC 최소 권한 원칙

```bash
# 보안 설정 분리
helm install app ./tmpl-apps \
  -f values.yaml \
  -f values-secrets.yaml \
  --set-string apps.api.secrets.env.API_KEY=$API_KEY
```