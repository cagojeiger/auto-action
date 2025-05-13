# Auto-Action

자동화된 컨테이너 이미지 및 Helm 차트 배포를 위한 GitHub Actions 워크플로우 저장소입니다.

## 개요

이 저장소는 다음과 같은 기능을 제공합니다:

1. **자동화된 아티팩트 배포**: 컨테이너 이미지와 Helm 차트를 자동으로 빌드하고 배포하는 GitHub Actions 워크플로우
2. **Code-Server 자동 업데이트**: 최신 Code-Server 버전을 자동으로 감지하고 업데이트하는 워크플로우
3. **Kubernetes 도구 모음**: Kubernetes 환경에서 사용할 수 있는 다양한 도구가 포함된 컨테이너 이미지

## 저장소 구조

```
auto-action/
├── containers/             # 컨테이너 이미지 정의
│   └── code-server/        # Code-Server 컨테이너 (Kubernetes 도구 포함)
├── helm-charts/            # Helm 차트 모음
│   ├── code-server/        # Code-Server Helm 차트
│   ├── monitoring/         # 모니터링 스택 Helm 차트
│   ├── ops-stack/          # 운영 스택 Helm 차트
│   ├── oss-ai-stack/       # OSS AI 스택 Helm 차트
│   ├── oss-data-infra/     # OSS 데이터 인프라 Helm 차트
│   └── template-deployment/ # 템플릿 배포 Helm 차트
└── .github/workflows/      # GitHub Actions 워크플로우
    ├── unified-artifact-push.yaml  # 통합 아티팩트 배포 워크플로우
    └── update-code-server.yaml     # Code-Server 자동 업데이트 워크플로우
```

## 주요 기능

### 통합 아티팩트 배포 (Unified Artifact Push)

`unified-artifact-push.yaml` 워크플로우는 다음과 같은 기능을 제공합니다:

- 변경된 Helm 차트 및 컨테이너 이미지 자동 감지
- 멀티 아키텍처(amd64, arm64) 컨테이너 이미지 빌드 및 배포
- Helm 차트 패키징 및 OCI 레지스트리 배포
- 수동 트리거를 통한 특정 아티팩트 배포 지원

### Code-Server 자동 업데이트

`update-code-server.yaml` 워크플로우는 다음과 같은 기능을 제공합니다:

- 매일 최신 Code-Server 버전 확인
- 새 버전 감지 시 자동 업데이트 및 PR 생성
- 자동 PR 병합 및 아티팩트 배포 트리거

## Code-Server 컨테이너

Code-Server 컨테이너는 다음과 같은 Kubernetes 도구를 포함합니다:

- `kubectl`: Kubernetes 클러스터 관리
- `helm`: Kubernetes 패키지 관리자
- `k9s`: Kubernetes CLI 대시보드
- `skopeo`: 컨테이너 이미지 관리 도구
- `mc`: MinIO 클라이언트
- `gomplate`: 템플릿 렌더링 도구

## 사용 방법

### 워크플로우 수동 트리거

GitHub UI에서 Actions 탭을 통해 워크플로우를 수동으로 트리거할 수 있습니다:

1. **통합 아티팩트 배포**:
   - 아티팩트 유형 선택: `helm` 또는 `docker`
   - 특정 아티팩트 이름 지정 (선택 사항)

2. **Code-Server 업데이트**:
   - 워크플로우 수동 실행 (파라미터 없음)

### 컨테이너 이미지 사용

```bash
# Code-Server 컨테이너 실행 (로컬 디버깅용)
docker run -it --rm --entrypoint bash cagojeiger/code-server:latest
```

### Helm 차트 사용

```bash
# OCI 레지스트리에서 Helm 차트 설치
helm install my-code-server oci://docker.io/cagojeiger/code-server
```

## 라이센스

이 프로젝트는 LICENSE 파일에 명시된 라이센스 조건에 따라 배포됩니다.