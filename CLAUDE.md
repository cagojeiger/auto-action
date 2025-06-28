# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository automates the deployment of infrastructure services using Docker images and Helm charts. It features GitHub Actions workflows that automatically build images and deploy charts when changes are detected.

## Key Architecture Patterns

### 1. Automated Update System
The repository implements an automated dependency update system:
- **Update workflows** fetch latest versions from upstream repositories (Casdoor, Code-server)
- Changes are committed via auto-merged PRs
- The `unified-artifact-push` workflow is triggered automatically after merges
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

### Workflow Management
```bash
# Manually trigger artifact push
gh workflow run unified-artifact-push.yaml -f artifact_type=helm -f artifact_name=<chart-name>

# Check workflow status
gh run list --workflow=unified-artifact-push.yaml

# View PR status
gh pr view <pr-number> --json state -q .state

# Slack notifications are automatically triggered on workflow failures
# Requires SLACK_WEBHOOK_URL secret to be configured
```

## Version Management

### Docker Images
Version resolution order:
1. Check corresponding `helm-charts/{name}/Chart.yaml` appVersion
2. Fallback to ARG *_VERSION in Dockerfile
3. Default to date-based version (YYYY.MM.DD)

### Helm Charts
- Chart versions use semantic versioning
- Dependencies locked via Chart.lock files
- Update dependencies: `helm dependency update`

## CI/CD Matrix Strategy

The `unified-artifact-push` workflow uses dynamic matrix generation:
- Automatically detects changed artifacts on push to main
- Supports manual selection via workflow_dispatch parameters
- Builds artifacts in parallel for efficiency

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
The code-server container includes several helper scripts located in the source directory `containers/code-server/`:

```bash
# Available utility scripts (to be copied into container)
containers/code-server/setup-npm-global.sh      # Configure npm global packages
containers/code-server/setup-python-pipx.sh     # Setup pipx for Python tools (improved for container environments)
containers/code-server/install-claude-code.sh   # Install Claude Code CLI
containers/code-server/gen_kube_config.sh       # Generate kubeconfig from Service Account

# Enhanced setup-python-pipx.sh features:
# - Uses $HOME environment variable (no hardcoded paths)
# - Creates shell config files if they don't exist
# - Robust duplicate checking with improved grep patterns
# - Verification of pipx installation
# - Better error handling and progress logging

# Install development tools via pipx (after running setup-python-pipx.sh)
pipx install poetry black ruff
```

## Local Development

### Docker Compose
Local development configurations available in `docker-composes/`:
```bash
cd docker-composes/open-hands/
docker-compose up -d
```