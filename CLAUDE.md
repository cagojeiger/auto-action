# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository automates the deployment of infrastructure services using Docker images and Helm charts. It features GitHub Actions workflows that automatically build images and deploy charts when changes are detected.

## Key Architecture Patterns

### 1. Automated Update System
The repository implements an automated dependency update system:
- **Update workflows** fetch latest versions from upstream repositories (Casdoor, Code-server)
- Changes are committed via auto-merged PRs
- Docker images are built via `docker-push` workflow
- Helm charts are deployed to GitHub Pages via `publish-helm-charts` workflow
- Updates run on schedules (daily/weekly) or can be triggered manually

### 2. Helm Chart Organization

#### Active Charts (`helm-charts/`)
- Production-ready individual service charts
- Simplified structure for direct deployment
- Charts: 
  - `casdoor`: 인증 서버 배포
  - `code-server`: Kubernetes 도구가 포함된 코드 서버

#### Archived Charts (`helm-charts-archive/`)
- Advanced charts with comprehensive tooling and testing infrastructure
- Bundle charts with complex dependencies and templating
- Advanced features: template inheritance, Gomplate templating, helm-unittest testing
- Charts:
  - `template-deployment`: 사용자 정의 배포를 위한 템플릿 (고급 테스트 포함)
  - `monitoring`: Prometheus, Loki, Promtail 패키지
  - `ops-stack`: Redis, PostgreSQL, MinIO, Harbor, Gitea, Argo CD 등이 포함된 번들
  - `oss-ai-stack`: 오픈소스 AI 작업을 위한 인프라
  - `oss-data-infra`: 오픈소스 데이터 작업을 위한 인프라

#### Key Chart Types
- **template-deployment**: A reusable base chart that provides template inheritance functionality
  - Supports type-based configuration inheritance (e.g., `web`, `api`, `database`)
  - Reduces boilerplate by allowing templates to inherit common configurations
  - Enables multi-type inheritance with priority ordering
- **Bundle charts**: Pre-configured service stacks with dependencies
- **Service charts**: Individual service deployments

### 3. Value Templating Pattern
Charts use Gomplate for value templating:
- `values.yaml.tmpl`: Template with placeholders
- `vars.yaml`: Variable definitions
- `make template`: Generates final values.yaml
- `values.schema.json`: JSON schema validation for chart values (template-deployment)

## Common Development Commands

### Build and Deploy
```bash
# Build Docker image (multi-platform)
cd containers/<name>
docker buildx build --platform linux/amd64,linux/arm64 -t <image>:<tag> .

# Update Helm dependencies
helm dependency update helm-charts/<chart-name>

# Install Helm chart
helm install <release-name> helm-charts/<chart-name> -f helm-charts/<chart-name>/values.yaml

# Generate values.yaml from template (archive charts)
cd helm-charts-archive/<chart-name>
make template

# Install Gomplate for templating
cd helm-charts-archive/<chart-with-templates>
make install-gomplate  # macOS automated installation
# For other platforms, check https://github.com/hairyhenderson/gomplate
```

### Testing and Validation
```bash
# Install helm-unittest plugin (archive charts only)
cd helm-charts-archive/<chart-name>
make install-plugin  # 헬름 unittest 플러그인 설치

# Run comprehensive Helm unit tests (template-deployment archive chart)
cd helm-charts-archive/template-deployment
make lint  # 헬름 차트 린트 검사
make test  # 모든 테스트 실행 (통합 테스트 + 기능 테스트)
make help  # 사용 가능한 명령어 확인

# Run specific test suites manually
helm unittest -f 'tests/integration/*_test.yaml' .      # 통합 테스트만
helm unittest -f 'tests/features/**/*_test.yaml' .      # 기능 테스트만

# Basic testing (active charts)
helm lint helm-charts/<chart-name>
helm template <release-name> helm-charts/<chart-name> -f values.yaml
```

### Helm Repository (GitHub Pages)
```bash
# Helm Repository 추가
helm repo add auto-action https://cagojeiger.github.io/auto-action
helm repo update

# 차트 검색
helm search repo auto-action

# 차트 설치
helm install code-server auto-action/code-server
helm install my-app auto-action/quick-deploy -f values.yaml

# 특정 버전 설치
helm install code-server auto-action/code-server --version 1.0.0
```

### Workflow Management
```bash
# Helm 차트 배포 (GitHub Pages)
gh workflow run publish-helm-charts.yaml -f chart_name=<chart-name>

# Docker 이미지 빌드 및 푸시
gh workflow run docker-push.yaml -f container_name=<container-name>

# Check workflow status
gh run list --workflow=publish-helm-charts.yaml
gh run list --workflow=docker-push.yaml

# View PR status
gh pr view <pr-number> --json state -q .state

# Slack notifications are automatically triggered on workflow failures
# Requires SLACK_WEBHOOK_URL secret to be configured
```

## Version Management

### Docker Images
Version is determined from a single source:
- **Required**: `ARG *_VERSION` in Dockerfile (e.g., `ARG CODE_SERVER_VERSION=4.108.1`)
- Build fails if ARG is not found (no fallback to ensure explicit versioning)

### Helm Charts
- Chart versions use semantic versioning
- Dependencies locked via Chart.lock files
- Update dependencies: `helm dependency update`

## CI/CD Matrix Strategy

The `docker-push` workflow uses dynamic matrix generation:
- Automatically detects changed containers on push to main
- Supports manual selection via workflow_dispatch parameters
- Builds Docker images in parallel for efficiency

The `publish-helm-charts` workflow handles Helm chart deployment:
- Deploys charts to GitHub Pages for easy `helm repo add` access
- Triggered automatically when `helm-charts/**` changes are pushed to main

## Required Secrets

- `DOCKERHUB_USERNAME`: Docker Hub username for image pushing
- `DOCKERHUB_TOKEN`: Docker Hub access token with push permissions
- `SLACK_WEBHOOK_URL`: Slack webhook URL for failure notifications (optional)

## Working with Template-Deployment Chart

When creating new deployments using template-deployment:
1. Define template types in `templateDefaults` section
2. Assign types to templates for configuration inheritance
3. Override inherited values as needed in individual templates

Example:
```yaml
templateDefaults:
  web:
    service:
      port: 80
      type: ClusterIP

templates:
  - name: my-app
    type: web  # Inherits web defaults
    image:
      repository: myapp
      tag: latest
```

## Container Development Tools

### Code-Server Container Utilities
The code-server container includes minimal helper scripts located in the source directory `containers/code-server/`:

```bash
# Available utility scripts (copied to /tmp/ in container)
containers/code-server/setup-npm-global.sh      # Set npm prefix (required - user-specific config)
containers/code-server/install-claude-code.sh   # Install Claude Code CLI
containers/code-server/gen_kube_config.sh       # Generate kubeconfig from Service Account
```

### Pre-configured Environment Variables
The container image comes with these environment variables pre-configured:
```bash
NPM_CONFIG_PREFIX="/home/coder/.npm-global"
PIPX_HOME="/home/coder/.local/pipx"
PIPX_BIN_DIR="/home/coder/.local/bin"
PATH="/home/coder/.local/bin:/home/coder/.npm-global/bin:${PATH}"
```

### Lifecycle Configuration Example
```yaml
lifecycle:
  enabled: true
  postStart:
    exec:
      command:
        - /bin/bash
        - -c
        - |
          # Generate kubeconfig if running in Kubernetes
          if [ -f "/var/run/secrets/kubernetes.io/serviceaccount/token" ]; then
            /tmp/gen_kube_config.sh
          fi

          # Setup npm global prefix (user-specific, always required)
          if [ ! -d "/home/coder/.npm-global" ]; then
            /tmp/setup-npm-global.sh
          fi

          # Install Claude CLI if not already installed
          if [ ! -f "/home/coder/.npm-global/bin/claude" ]; then
            /tmp/install-claude-code.sh
          fi
          
          # pipx works out-of-the-box - no setup needed!
          # Example: pipx install poetry
```

**Note**: The environment variables in `extraVars` are now optional - they're already built into the image. Override them only if you need custom paths.

## Local Development

### Docker Compose
Local development configurations available in `docker-composes/`:
```bash
cd docker-composes/open-hands/
docker-compose up -d
```