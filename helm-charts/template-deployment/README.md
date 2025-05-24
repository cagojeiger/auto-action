# Template Deployment Helm Chart

Kubernetes에서 다양한 워크로드를 쉽게 배포할 수 있는 템플릿 기반 Helm 차트입니다.

## 주요 기능

- 템플릿 상속 및 재사용 메커니즘
- 중첩 객체의 깊은 병합 지원
- ConfigMap, Service, Ingress 등 다양한 리소스 자동 생성
- **[v0.6.0] ConfigMap/Secret 관리**: 템플릿별 ConfigMap/Secret 생성 및 자동 마운트
- **[v0.6.0] 향상된 Ingress 지원**: 경로별 백엔드 서비스 커스터마이징

## 설치 방법

```bash
helm install my-deployment ./template-deployment -f values.yaml
```

## values.yaml 구성

```yaml
# 템플릿 기본값 정의
templateDefaults:
  default:  # 모든 템플릿에 적용되는 기본값
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
  
  web:  # 웹 애플리케이션 타입
    service:
      enabled: true
      port: 80
  
  database:  # 데이터베이스 타입
    persistence:
      enabled: true

# 템플릿 정의
templates:
  - name: app-name
    type: web  # 또는 [web, api]와 같이 다중 타입 지정
    image:
      repository: image-repository
      tag: "image-tag"
    
    # ConfigMap/Secret 관리 (v0.6.0+)
    configMaps:
      - name: app-config
        data:
          KEY: value
        envFrom: true  # 환경변수로 자동 로드
        volumeMount:   # 볼륨으로 마운트
          mountPath: /etc/config
    
    secrets:
      - name: app-secrets
        stringData:
          API_KEY: secret-value
        envFrom: true
    
    # 향상된 Ingress 설정 (v0.6.0+)
    ingress:
      enabled: true
      rules:
        - host: example.com
          paths:
            - path: /api
              pathType: Prefix
              backend:
                service:
                  name: api-service
                  port: 8080
```

## 템플릿 상속

템플릿은 `type` 필드를 통해 `templateDefaults`에 정의된 설정을 상속받습니다.
다중 타입 상속 시 배열 형태로 지정하며, 앞에 있는 타입이 우선순위가 높습니다.

템플릿 상속에 대한 자세한 내용은 [템플릿 상속 문서](docs/template-inheritance.md)를 참조하세요.

## 문서

- [사용자 가이드](docs/user-guide.md) - 시작하기와 상세 사용법
- [템플릿 상속](docs/template-inheritance.md) - 템플릿 상속 시스템 상세 설명
- [개선 제안서](docs/improvement-proposal.md) - 향후 개선 계획

## 테스트

```bash
# Makefile을 사용한 테스트
make test

# 또는 직접 실행
helm unittest ./helm-charts/template-deployment
```

## 지원되는 리소스 유형

- Deployment
- Service
- Ingress (향상된 경로 설정 지원)
- ConfigMap (템플릿별 다중 생성 지원)
- Secret (템플릿별 다중 생성 지원)
- PersistentVolumeClaim
- HorizontalPodAutoscaler
- ServiceAccount
- ClusterRole
- ClusterRoleBinding
- PodDisruptionBudget

## Changelog

[CHANGELOG.md](CHANGELOG.md)를 참조하세요.