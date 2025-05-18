# auto-action

이 저장소는 Docker 이미지와 Helm 차트를 이용해 여러 인프라 서비스를 배포하기 위해 사용됩니다. GitHub Actions 워크플로가 이미지 빌드와 차트 배포를 자동화합니다.

## 디렉터리 구조

- **containers/** - 컨테이너 이미지를 위한 Dockerfile과 스크립트가 있습니다. `code-server` 이미지는 Kubernetes 관련 도구를 포함합니다.
- **docker-composes/** - 로컬 테스트용 Docker Compose 설정을 제공합니다. 예를 들어 OpenHands 애플리케이션 구성 파일이 있습니다.
- **helm-charts/** - 서비스를 배포하기 위한 Helm 차트 모음입니다. 주요 차트는 다음과 같습니다.
  - `casdoor`: 인증 서버 배포
  - `code-server`: Kubernetes 도구가 포함된 코드 서버
  - `monitoring`: Prometheus, Loki, Promtail 패키지
  - `ops-stack`: Redis, PostgreSQL, MinIO, Harbor, Gitea, Argo CD 등이 포함된 번들
  - `oss-ai-stack`, `oss-data-infra`: 오픈소스 AI 및 데이터 작업을 위한 인프라
  - `template-deployment`: 사용자 정의 배포를 위한 템플릿
- **.github/workflows/** - 아티팩트 업데이트와 배포를 담당하는 CI 설정이 위치합니다.

## 워크플로 개요

- **unified-artifact-push.yaml**: Dockerfile이나 Helm 차트 변경 시 자동으로 이미지를 빌드하고 차트를 배포합니다.
- **update-casdoor.yaml**, **update-code-server.yaml**: 외부 저장소의 최신 버전을 가져와 차트와 Dockerfile을 갱신하는 작업을 수행합니다.

## 사용 방법

일반적으로 이미지는 자동으로 빌드되고 차트는 자동으로 배포됩니다. 수동으로 수행하려면 다음 명령을 참고하세요.

```bash
# 컨테이너 이미지 빌드
cd containers/code-server
docker buildx build --platform linux/amd64,linux/arm64 -t <image>:<tag> .

# 차트 설치
helm dependency update helm-charts/ops-stack
helm install ops-stack helm-charts/ops-stack -f helm-charts/ops-stack/values.yaml
```

각 디렉터리의 README에서 세부 정보를 확인할 수 있습니다.

## 기여 방법

코드 변경 시 Google Style Guide를 따르고, 커밋 메시지는 Conventional Commits 규칙에 맞춰 작성합니다. 가능한 한 기존 동작과의 호환성을 유지해 주세요.

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
