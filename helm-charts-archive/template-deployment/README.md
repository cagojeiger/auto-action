# Template Deployment Helm Chart

Kubernetes에서 다양한 워크로드를 쉽게 배포할 수 있는 템플릿 기반 Helm 차트입니다.

## 주요 기능

- 템플릿 상속 및 재사용 메커니즘
- 중첩 객체의 깊은 병합 지원
- ConfigMap, Service, Ingress 등 다양한 리소스 자동 생성

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
    # 기타 설정...
```

## 템플릿 상속

템플릿은 `type` 필드를 통해 `templateDefaults`에 정의된 설정을 상속받습니다.
다중 타입 상속 시 배열 형태로 지정하며, 앞에 있는 타입이 우선순위가 높습니다.

템플릿 상속에 대한 자세한 내용은 [템플릿 상속 문서](docs/template-inheritance.md)를 참조하세요.

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
- Ingress
- ConfigMap
- PersistentVolumeClaim
- HorizontalPodAutoscaler
- ServiceAccount
- ClusterRole
- ClusterRoleBinding
- PodDisruptionBudget