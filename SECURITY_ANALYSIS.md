# Security Analysis Report

## Overview
이 문서는 auto-action 저장소의 보안 분석 결과를 요약합니다.

---

## 1. Docker Container Security

### 1.1 Code-Server Dockerfile (`containers/code-server/Dockerfile`)

#### Positive Findings
- **Multi-stage build**: Builder 스테이지에서 도구 설치 후 final 스테이지로 복사하여 이미지 크기 최소화
- **Non-root user**: 최종 컨테이너는 `coder` 사용자(UID 1000)로 실행
- **Official base image**: `codercom/code-server` 공식 이미지 사용

#### Security Concerns

| Severity | Issue | Location | Recommendation |
|----------|-------|----------|----------------|
| **HIGH** | 버전 고정 없는 도구 설치 | Line 13-157 | 모든 도구에 특정 버전 고정 (e.g., `KUBECTL_VERSION=1.29.0`) |
| **MEDIUM** | curl to shell 패턴 | Line 188 | `curl ... \| bash` 대신 패키지 매니저 사용 |
| **MEDIUM** | Root 권한 빌드 | Line 10 | Builder에서 root 필요하지만 최종 이미지는 non-root |
| **LOW** | 최신 버전 자동 fetch | Multiple | API 응답 검증 및 체크섬 확인 추가 |

#### High-Risk Tools Included
```
kubectl, helm, terraform, vault, argocd, docker CLI, aws CLI, sops
```
이 도구들은 클러스터/클라우드 리소스에 접근할 수 있어 적절한 RBAC 필요.

### 1.2 Docker Compose (`docker-composes/open-hands/docker-compose.yaml`)

| Severity | Issue | Recommendation |
|----------|-------|----------------|
| **CRITICAL** | Docker socket 마운트 | Line 20: `/var/run/docker.sock` - 컨테이너 탈출 가능 |
| **MEDIUM** | Pull policy: always | 네트워크 의존성, 이미지 digest 고정 권장 |

---

## 2. Helm Chart Security

### 2.1 Code-Server Chart (`helm-charts/code-server/`)

#### Positive Findings
- SecurityContext 기본 활성화 (runAsUser: 1000, fsGroup: 1000)
- ServiceAccount 생성 지원
- 기존 Secret 참조 지원 (`existingSecret`)
- 24자 랜덤 비밀번호 자동 생성

#### Security Concerns

| Severity | Issue | File | Recommendation |
|----------|-------|------|----------------|
| **CRITICAL** | Cluster-admin 옵션 | `templates/clusterrole.yaml:13-15` | 최소 권한 RBAC 규칙 정의 |
| **HIGH** | privileged 컨테이너 예시 | `values.yaml:169` | dind 사용 시 rootless Docker 권장 |
| **MEDIUM** | hostPath 볼륨 지원 | `values.yaml:135` | hostPath 사용 제한 정책 |
| **MEDIUM** | Resource limits 미설정 | `values.yaml:102-112` | 기본 limits 설정 |
| **LOW** | NetworkPolicy 없음 | - | NetworkPolicy 템플릿 추가 |

#### ClusterRole Analysis (`templates/clusterrole.yaml`)
```yaml
# 현재 구현 - 위험!
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
```
**권장**: 필요한 리소스에 대해서만 최소 권한 부여

### 2.2 Casdoor Chart (`helm-charts-archive/casdoor/`)

| Severity | Issue | File | Recommendation |
|----------|-------|------|----------------|
| **HIGH** | DB 자격증명 평문 | `values.yaml:45-46` | External Secret Operator 사용 |
| **MEDIUM** | SSL 기본 비활성화 | `values.yaml:53` | sslMode: require 기본값 |
| **MEDIUM** | runmode: dev | `values.yaml:18` | Production에서 runmode: prod |
| **LOW** | securityContext 미설정 | `values.yaml:78` | runAsNonRoot: true 기본 활성화 |

---

## 3. GitHub Actions Workflow Security

### 3.1 unified-artifact-push.yaml

#### Positive Findings
- Secret을 통한 Docker Hub 인증
- Matrix strategy로 병렬 빌드
- 변경 감지 기반 선택적 배포

#### Security Concerns

| Severity | Issue | Line | Recommendation |
|----------|-------|------|----------------|
| **MEDIUM** | 외부 Actions 버전 고정 필요 | 32, 150-151 | SHA 기반 고정 (e.g., `actions/checkout@a5ac7e...`) |
| **LOW** | PR 권한 미선언 | - | 명시적 `permissions` 블록 추가 |

### 3.2 update-code-server.yaml

#### Positive Findings
- 명시적 permissions 블록
- Docker Hub 이미지 존재 확인
- 변경 감지 후 PR 생성

#### Security Concerns

| Severity | Issue | Line | Recommendation |
|----------|-------|------|----------------|
| **HIGH** | Auto-merge 활성화 | Line 141 | Branch protection rule과 함께 사용 |
| **MEDIUM** | github.token 광범위 권한 | Line 9-11 | contents: read에서 필요시만 write |
| **MEDIUM** | 외부 저장소 체크아웃 | Line 52-57 | 신뢰할 수 있는 소스 확인 |

### 3.3 slack-notifications.yaml

| Severity | Issue | Recommendation |
|----------|-------|----------------|
| **LOW** | Webhook URL 노출 가능성 | Environment secret으로 변경 |

---

## 4. Secrets Management

### 4.1 .gitignore Analysis
```
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
```
환경 파일 제외 설정됨 - 양호

### 4.2 Required GitHub Secrets

| Secret | Purpose | Security Note |
|--------|---------|---------------|
| `DOCKERHUB_USERNAME` | Docker Hub 인증 | Read/Write 권한 필요 |
| `DOCKERHUB_TOKEN` | Docker Hub 인증 | PAT with limited scope 권장 |
| `SLACK_WEBHOOK_URL` | 알림 | Organization secret으로 관리 |

---

## 5. Security Score Summary

| Category | Score | Status |
|----------|-------|--------|
| Container Security | 6/10 | Needs Improvement |
| Helm Chart Security | 5/10 | Needs Improvement |
| CI/CD Security | 7/10 | Acceptable |
| Secrets Management | 8/10 | Good |
| **Overall** | **6.5/10** | **Needs Improvement** |

---

## 6. Priority Recommendations

### Critical (즉시 조치)
1. **ClusterRole 권한 축소**: `cluster-admin` 옵션 제거 또는 최소 권한 규칙으로 교체
2. **Docker socket 마운트 제거**: 개발 환경에서만 사용하거나 rootless 대안 검토

### High (1주 내 조치)
3. **도구 버전 고정**: Dockerfile의 모든 바이너리에 특정 버전 명시
4. **Auto-merge 정책 강화**: Branch protection rule 필수 적용
5. **DB 자격증명 외부화**: External Secrets Operator 또는 Vault 연동

### Medium (1개월 내 조치)
6. **Resource limits 기본값**: 모든 Helm 차트에 기본 limits 설정
7. **Actions 버전 SHA 고정**: 모든 외부 Actions를 commit SHA로 고정
8. **NetworkPolicy 추가**: Helm 차트에 NetworkPolicy 템플릿 포함
9. **SSL 기본 활성화**: DB 연결 시 SSL 기본 활성화

### Low (분기 내 조치)
10. **Checksum 검증**: 다운로드하는 모든 바이너리에 checksum 검증 추가
11. **PodSecurityPolicy/PSS**: Pod Security Standards 적용

---

## 7. Compliance Considerations

### SOC 2 관련
- [ ] Audit logging 활성화 필요
- [ ] Access control 문서화

### CIS Kubernetes Benchmark
- [ ] 4.1.1: Ensure that the cluster-admin role is only used where required
- [ ] 5.1.3: Minimize wildcard use in Roles and ClusterRoles

---

*Report generated: 2026-01-09*
*Branch: claude/analyze-dev-security-emsV8*
