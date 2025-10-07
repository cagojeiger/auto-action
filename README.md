# auto-action

GitOps 기반 자동화 인프라 배포 저장소입니다. GitHub Actions를 통해 Docker 이미지와 Helm 차트를 자동으로 빌드하고 배포합니다.

## 주요 특징

- **완전 자동화**: 코드 변경 감지 시 이미지 빌드 및 차트 배포 자동 실행
- **멀티 플랫폼 지원**: linux/amd64, linux/arm64 이미지 동시 빌드
- **의존성 자동 업데이트**: upstream 저장소의 최신 버전 자동 추적 및 반영
- **동적 매트릭스 빌드**: 변경된 아티팩트만 선택적으로 병렬 처리

## 빠른 시작

```bash
# Helm 차트 설치
helm install casdoor oci://docker.io/cagojeiger/casdoor

# 또는 로컬에서 직접 설치
helm install casdoor helm-charts/casdoor -f helm-charts/casdoor/values.yaml
```

## 디렉터리 구조

- **containers/** - Docker 이미지 (Casdoor, Code-server 등)
- **helm-charts/** - 프로덕션 Helm 차트
- **helm-charts-archive/** - 고급 기능 포함 아카이브 차트 (template-deployment, ops-stack 등)
- **docker-composes/** - 로컬 개발용 Docker Compose 설정

각 디렉터리의 README에서 상세 정보를 확인할 수 있습니다.

## 자동화 워크플로

- **unified-artifact-push**: 변경 감지 시 이미지/차트 자동 빌드 및 배포
- **update-\***: upstream 의존성 자동 업데이트 (일일/주간)
- **slack-notifications**: 빌드 실패 시 Slack 알림

## 상세 문서

개발 가이드, 템플릿 시스템, 테스트 방법 등 상세 정보는 [CLAUDE.md](CLAUDE.md)를 참고하세요.

## 기여 방법

코드 변경 시 Google Style Guide를 따르고, 커밋 메시지는 Conventional Commits 규칙에 맞춰 작성합니다. 가능한 한 기존 동작과의 호환성을 유지해 주세요.

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
