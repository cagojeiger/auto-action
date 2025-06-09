# ArgoCD PJ Helm Chart

이 차트는 Bitnami ArgoCD를 기반으로 하여 자동 시크릿 관리 기능을 추가한 우산 패턴(Umbrella Pattern) Helm 차트입니다. PJ는 Project Jelly의 약어로, 이 프로젝트의 고유한 식별자입니다.

## 주요 특징

- **자동 시크릿 생성**: 첫 설치 시 ArgoCD 서버 시크릿 키를 자동으로 생성
- **시크릿 영속성**: Helm hook과 resource policy를 사용하여 업그레이드/롤백 시에도 시크릿 유지
- **간편한 설치**: 한 번의 명령으로 ArgoCD와 모든 설정을 배포
- **리소스 최적화**: 개발/테스트 환경에 맞춰 사전 구성된 리소스 제한

## 사용된 기술

### Helm 3 기능
- **Helm Hooks**: `pre-install` hook으로 초기 설정 자동화
- **Resource Policy**: `keep` 정책으로 시크릿 영속성 보장
- **Helm Lookup Function**: 기존 리소스 존재 여부 확인
- **Helm Dependencies**: Bitnami ArgoCD 차트를 의존성으로 활용

### 해결된 문제
- ❌ **기존 문제**: Helm 업그레이드/롤백 시마다 시크릿이 재생성되어 ArgoCD가 재시작됨
- ✅ **해결책**: Pre-install hook과 keep 정책으로 시크릿이 첫 설치 시에만 생성되고 이후 유지됨

## 설치 방법

### 기본 설치
```bash
# 차트 의존성 업데이트
helm dependency update helm-charts/argocd-pj

# ArgoCD 설치
helm install argocd helm-charts/argocd-pj \
  --namespace argocd \
  --create-namespace
```

### 커스텀 값으로 설치
```bash
helm install argocd helm-charts/argocd-pj \
  --namespace argocd \
  --create-namespace \
  --set argo-cd.server.ingress.hostname=my-argocd.example.com \
  --set argo-cd.server.resources.limits.memory=2Gi
```

### 로컬 개발 환경
```bash
# /etc/hosts 파일에 추가
echo "127.0.0.1 argocd.localhost" | sudo tee -a /etc/hosts

# 설치
helm install argocd helm-charts/argocd-pj \
  --namespace argocd \
  --create-namespace
```

### 업그레이드
```bash
# 시크릿은 유지되면서 다른 설정만 업데이트됨
helm upgrade argocd helm-charts/argocd-pj \
  --namespace argocd
```

## ArgoCD로 관리하기

이 차트는 ArgoCD Application으로 관리할 수 있습니다:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-repo/auto-action
    path: helm-charts/argocd-pj
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=false
```

## 설정 값

주요 설정값들:

| 파라미터 | 설명 | 기본값 |
|----------|------|--------|
| `serverSecretKey` | ArgoCD 서버 시크릿 키 (비어있으면 자동 생성) | `""` |
| `argo-cd.server.insecure` | HTTP 사용 여부 | `true` |
| `argo-cd.server.ingress.enabled` | Ingress 활성화 | `true` |
| `argo-cd.server.ingress.hostname` | ArgoCD 도메인 | `argocd.localhost` |
| `argo-cd.server.resources.limits.memory` | 서버 메모리 제한 | `1024Mi` |
| `argo-cd.redis.master.persistence.enabled` | Redis 영속성 | `false` |

전체 설정값은 [values.yaml](values.yaml) 파일을 참조하세요.

## 저장소 설정

이 차트는 Git 저장소, Helm 차트 저장소(OCI 포함), Docker 레지스트리를 설치 시 자동으로 설정할 수 있습니다. 저장소 타입은 URL에서 자동으로 감지되지만, 명시적으로 지정할 수도 있습니다.

### Git 저장소 추가

```bash
# GitHub 저장소 (자동 감지)
helm install argocd helm-charts/argocd-pj \
  --set repositories[0].name=private-repo \
  --set repositories[0].url=https://github.com/org/private-repo \
  --set repositories[0].username=myuser \
  --set repositories[0].password="$GITHUB_TOKEN"
```

### Helm 차트 저장소 추가

```bash
# 일반 Helm 저장소 (자동 감지)
helm install argocd helm-charts/argocd-pj \
  --set repositories[0].name=bitnami \
  --set repositories[0].url=https://charts.bitnami.com/bitnami

# OCI Helm 저장소 (oci:// 프리픽스로 자동 감지)
helm install argocd helm-charts/argocd-pj \
  --set repositories[0].name=my-oci \
  --set repositories[0].url=oci://ghcr.io/my-org/charts \
  --set repositories[0].username=myuser \
  --set repositories[0].password="$GITHUB_TOKEN"
```

### Docker 레지스트리 추가

```bash
# Docker Hub (type 명시 필요)
helm install argocd helm-charts/argocd-pj \
  --set repositories[0].name=dockerhub \
  --set repositories[0].url=https://index.docker.io/v1/ \
  --set repositories[0].type=docker \
  --set repositories[0].username=myuser \
  --set repositories[0].password="$DOCKER_PASSWORD"

# GitHub Container Registry (자동 감지)
helm install argocd helm-charts/argocd-pj \
  --set repositories[0].name=ghcr \
  --set repositories[0].url=ghcr.io \
  --set repositories[0].username=myuser \
  --set repositories[0].password="$GITHUB_TOKEN"
```

### 여러 저장소 동시 설정

```bash
helm install argocd helm-charts/argocd-pj \
  --namespace argocd --create-namespace \
  --set repositories[0].name=backend-repo \
  --set repositories[0].url=https://github.com/org/backend \
  --set repositories[0].username=git-user \
  --set repositories[0].password="$GITHUB_TOKEN" \
  --set repositories[1].name=bitnami-oci \
  --set repositories[1].url=oci://registry-1.docker.io/bitnamicharts \
  --set repositories[2].name=dockerhub \
  --set repositories[2].url=https://index.docker.io/v1/ \
  --set repositories[2].type=docker \
  --set repositories[2].username=docker-user \
  --set repositories[2].password="$DOCKER_PASSWORD"
```

### 안전한 패스워드 전달 (권장)

특수 문자가 포함된 패스워드나 토큰을 안전하게 전달하려면 `--set-string`을 사용하세요:

```bash
helm install argocd helm-charts/argocd-pj \
  --set-string repositories[0].password="${GITHUB_TOKEN}" \
  --set-string repositories[0].username="${GITHUB_USER}"
```

또는 values 파일을 사용하는 방법:

```bash
# values-secret.yaml 파일 생성
cat > values-secret.yaml <<EOF
repositories:
  - name: private-repo
    url: https://github.com/org/repo
    username: ${GITHUB_USER}
    password: ${GITHUB_TOKEN}
EOF

# 설치
helm install argocd helm-charts/argocd-pj -f values-secret.yaml
```

### 자동 타입 감지 규칙

| URL 패턴 | 감지되는 타입 |
|----------|--------------|
| `https://github.com/*`, `https://gitlab.com/*` | git |
| `oci://*` | helm-oci |
| `*charts*` (URL에 'charts' 포함) | helm |
| `ghcr.io`, `index.docker.io`, `*registry*` | docker |
| 기타 | git (기본값) |

### 저장소 시크릿 관리

모든 저장소 시크릿은 다음과 같은 특성을 가집니다:
- **영속성**: `helm.sh/resource-policy: keep`으로 삭제 방지
- **ArgoCD 동기화 제외**: `argocd.argoproj.io/sync-options: Prune=false`
- **Hook 기반 생성**: post-install, post-upgrade 시에만 생성/업데이트

## 접속 정보 확인

설치 후 다음 명령으로 접속 정보를 확인할 수 있습니다:

```bash
# 초기 admin 패스워드 확인
kubectl -n argocd get secret argocd-argo-cd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Ingress가 활성화된 경우
echo "ArgoCD URL: https://$(kubectl get ingress -n argocd -o jsonpath='{.items[0].spec.rules[0].host}')"

# 로컬 환경에서는
echo "ArgoCD URL: https://argocd.localhost"
```

## 문제 해결

### 시크릿이 생성되지 않는 경우
```bash
# 기존 시크릿 확인
kubectl get secret argocd-secret -n argocd

# 수동으로 시크릿 생성
kubectl create secret generic argocd-secret \
  --from-literal=server.secretkey=$(openssl rand -base64 32) \
  -n argocd
```

### 차트 의존성 업데이트
```bash
# Bitnami 차트의 최신 버전으로 업데이트
helm dependency update helm-charts/argocd-pj
```

## 라이선스

이 프로젝트는 Apache 2.0 라이선스를 따릅니다.