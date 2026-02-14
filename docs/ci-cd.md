# CI/CD 자동화 프로세스

## 개요

파일 변경 → main 머지 → 자동 빌드/배포 (수동 호출 불필요)

## 자동 트리거 규칙

| 경로 변경 | 워크플로우 | 배포 대상 |
|-----------|-----------|----------|
| `containers/**` | docker-push.yaml | Docker Hub |
| `helm-charts/**` | publish-helm-charts.yaml | GitHub Pages |

---

## Docker 이미지 빌드

### 디렉토리 구조

```
containers/
└── {name}/
    ├── Dockerfile      # 필수
    ├── *.sh            # 선택 (유틸리티 스크립트)
    └── README.md       # 선택 (문서)
```

### 이미지 이름 규칙

```
containers/{name}/  →  {DOCKERHUB_USERNAME}/{name}:{version}
```

예시:
| 디렉토리 | Docker 이미지 |
|----------|--------------|
| `containers/code-server/` | `cagojeiger/code-server:4.108.1` |
| `containers/my-app/` | `cagojeiger/my-app:1.0.0` |

### 버전 결정 규칙 (2단계, 완전 독립)

Docker 이미지 빌드는 **Dockerfile만** 참조합니다 (Helm Chart 독립).

1. **Dockerfile ARG** (명시적 버전)
   ```dockerfile
   ARG {ANY}_VERSION=x.x.x
   ```

   ⚠️ **주의**: 반드시 `_VERSION=` 패턴 필요

   | Dockerfile | 추출 버전 |
   |------------|----------|
   | `ARG CODE_SERVER_VERSION=4.108.1` | ✅ 4.108.1 |
   | `ARG APP_VERSION=1.0.0` | ✅ 1.0.0 |
   | `ARG MY_TOOL_VERSION=2.3.4` | ✅ 2.3.4 |
   | `ARG VERSION=1.0.0` | ❌ 인식 안 됨 (`_VERSION` 패턴 필요) |
   | `ARG CODE_SERVER_VERSION=v4.108.1` | ⚠️ `v` 제외하고 `4.108.1` |

2. **커밋 날짜** (폴백, 멱등성 보장)
   ```bash
   git log -1 --format=%cd --date=format:%Y.%m.%d -- containers/{name}/
   # 예: 2026.01.20 (언제 빌드해도 동일!)
   ```

> **참고**: Helm Chart appVersion은 Docker 버전 결정에 사용되지 않습니다.
> Docker와 Helm은 각각 독립적으로 버전을 관리합니다.

### 생성되는 태그

```
{DOCKERHUB_USERNAME}/{name}:{version}
{DOCKERHUB_USERNAME}/{name}:latest
```

### 빌드 설정

- **플랫폼**: `linux/amd64`, `linux/arm64` (멀티 아키텍처)
- **빌드 인자**: `APP_VERSION` (버전 정보 전달)
- **컨텍스트**: `./containers/{name}/`

### 새 이미지 추가 방법

1. 디렉토리 생성:
   ```bash
   mkdir -p containers/my-new-app
   ```

2. Dockerfile 작성:
   ```dockerfile
   ARG MY_NEW_APP_VERSION=1.0.0
   FROM base-image:${MY_NEW_APP_VERSION}
   # ...
   ```

3. main 브랜치에 푸시 → 자동 빌드

---

## Helm 차트 배포

### 저장소 정보

- **URL**: https://cagojeiger.github.io/auto-action
- **형식**: GitHub Pages (index.yaml + .tgz)

### 사용 방법

```bash
# 저장소 추가
helm repo add auto-action https://cagojeiger.github.io/auto-action
helm repo update

# 차트 검색
helm search repo auto-action --versions

# 설치
helm install my-release auto-action/{chart-name}
```

### 버전 관리

- 차트당 최근 **10개 버전**만 유지
- build metadata 버전 우선 정렬 (예: `3.32.0+4.108.1`)

---

## 수동 트리거

자동 트리거 외에도 수동으로 실행 가능:

```bash
# 특정 Docker 이미지 빌드
gh workflow run docker-push.yaml -f container_name=code-server

# 모든 Docker 이미지 빌드
gh workflow run docker-push.yaml

# 특정 Helm 차트 배포
gh workflow run publish-helm-charts.yaml -f chart_name=code-server

# 모든 Helm 차트 배포
gh workflow run publish-helm-charts.yaml
```
