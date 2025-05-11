# Template Deployment Helm Chart

이 Helm 차트는 Kubernetes에서 다양한 워크로드를 쉽게 배포할 수 있는 템플릿 기반 배포 시스템입니다.

## 개요

Template Deployment Helm 차트는 단일 차트를 사용하여 여러 종류의 애플리케이션을 쉽게 배포할 수 있는 기능을 제공합니다. values.yaml 파일에 정의된 템플릿 목록을 기반으로 여러 Kubernetes 리소스를 자동으로 생성합니다.

## 주요 기능

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

values.yaml 파일은 `templates` 배열 아래에 여러 애플리케이션 정의를 포함합니다:

```yaml
templates:
  - name: app-name
    image:
      repository: image-repository
      tag: "image-tag"
      pullPolicy: IfNotPresent
    # 기타 설정...
```

### 예제

차트에는 다음과 같은 예제 템플릿이 포함되어 있습니다:

1. **nginx-echo**: 기본 웹 서버 설정
2. **netshoot**: 네트워크 디버깅 도구
3. **code-server**: VS Code 서버 환경

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
