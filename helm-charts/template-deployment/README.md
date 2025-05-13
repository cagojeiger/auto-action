# Template Deployment Helm Chart

이 Helm 차트는 Kubernetes에서 다양한 워크로드를 쉽게 배포할 수 있는 템플릿 기반 배포 시스템입니다.

## 개요

Template Deployment Helm 차트는 단일 차트를 사용하여 여러 종류의 애플리케이션을 쉽게 배포할 수 있는 기능을 제공합니다. values.yaml 파일에 정의된 템플릿 목록을 기반으로 여러 Kubernetes 리소스를 자동으로 생성합니다.

## 주요 기능

- 템플릿 상속 및 재사용 메커니즘 (v0.5.0 신규 기능)
- ConfigMap을 통한 설정 관리
- 서비스 및 인그레스를 통한 네트워크 노출
- PVC를 통한 영구 스토리지 지원
- 수평적 Pod 자동 확장(HPA) 지원
- 서비스 어카운트 및 클러스터 롤 연동 지원

## 사용 방법

### 설치

```bash
helm install my-deployment ./template-deployment -f values.yaml
```

### values.yaml 파일 구성

values.yaml 파일은 `templateDefaults`와 `templates` 섹션으로 구성됩니다:

```yaml
# 템플릿 기본값 정의
templateDefaults:
  web:  # 웹 애플리케이션 타입
    service:
      enabled: true
      port: 80
    # 기타 기본 설정...
  
  database:  # 데이터베이스 애플리케이션 타입
    persistence:
      enabled: true
    # 기타 기본 설정...
  
  utility:  # 유틸리티 애플리케이션 타입
    # 기타 기본 설정...

# 템플릿 정의
templates:
  - name: app-name
    type: web  # 템플릿 타입 (web, database, utility 등)
    image:
      repository: image-repository
      tag: "image-tag"
    # 기본값 오버라이드 또는 추가 설정...
```

### 템플릿 상속 기능 (v0.5.0 신규 기능)

템플릿 상속 기능을 사용하면 공통 설정을 한 번만 정의하고 여러 템플릿에서 재사용할 수 있습니다. `templateDefaults` 섹션에 타입별 기본값을 정의하고, 각 템플릿에서 `type` 필드를 통해 상속받을 수 있습니다.

자세한 내용은 [템플릿 상속 기능 상세 문서](./docs/template-inheritance.md)를 참조하세요.

### 예제

차트에는 다음과 같은 예제 템플릿이 포함되어 있습니다:

1. **nginx-echo**: 기본 웹 서버 설정 (type: web)
2. **netshoot**: 네트워크 디버깅 도구 (type: utility)
3. **code-server**: VS Code 서버 환경 (type: web)
4. **postgres**: 데이터베이스 서버 (type: database)

자세한 예제는 `values-example.yaml` 파일을 참조하세요.

## 스키마 검증

`values.schema.json` 파일은 values.yaml의 구조를 검증하는 JSON 스키마를 제공합니다. 이를 통해 필수 필드가 누락되지 않도록 보장합니다.

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
