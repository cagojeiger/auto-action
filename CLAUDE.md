# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Kubernetes infrastructure deployment automation project that uses Docker images and Helm charts to deploy various infrastructure services. GitHub Actions workflows automate image building and chart deployment.

## Repository Structure

- **containers/** - Dockerfiles and scripts for container images (e.g., code-server with Kubernetes tools)
- **helm-charts/** - Helm charts collection for service deployment:
  - `casdoor`: Authentication server
  - `code-server`: Code server with Kubernetes tools
  - `monitoring`: Prometheus, Loki, Promtail stack
  - `ops-stack`: Bundle including Redis, PostgreSQL, MinIO, Harbor, Gitea, Argo CD, etc.
  - `oss-ai-stack`, `oss-data-infra`: Infrastructure for open-source AI and data operations
  - `template-deployment`: Base template for custom deployments
- **docker-composes/** - Docker Compose configurations for local testing
- **.github/workflows/** - CI/CD automation workflows

## Common Commands

### Building Container Images
```bash
cd containers/code-server
docker buildx build --platform linux/amd64,linux/arm64 -t <image>:<tag> .
```

### Working with Helm Charts
```bash
# Install dependencies and deploy a chart
helm dependency update helm-charts/ops-stack
helm install ops-stack helm-charts/ops-stack -f helm-charts/ops-stack/values.yaml

# Generate values.yaml from template (in charts with Makefile)
cd helm-charts/ops-stack
make template

# Install gomplate tool (required for templating)
make install-gomplate
```

### Testing Helm Charts
```bash
# Run helm template tests (in template-deployment)
cd helm-charts/template-deployment
make test

# Lint helm charts
make lint
```

## Architecture & Key Patterns

### Helm Chart Templating
Many charts use a templating system with:
- `values.yaml.tmpl` - Template file with placeholders
- `vars.yaml` - Variable definitions
- `make template` - Generates final `values.yaml` using gomplate

### GitHub Actions Automation
- **unified-artifact-push.yaml**: Automatically builds Docker images and publishes Helm charts when changes are pushed to main
- **update-casdoor.yaml** & **update-code-server.yaml**: Automatically update from upstream repositories, create PRs, and trigger deployments

### Version Management
- Docker image versions: Extracted from Dockerfile ARG statements
- Helm chart versions: Use `appVersion` field in Chart.yaml
- Automated workflows handle version detection and tagging

### Multi-Architecture Support
All Docker images are built for both linux/amd64 and linux/arm64 platforms using docker buildx.

## Development Guidelines

1. Follow Google Style Guide for code formatting
2. Use Conventional Commits for commit messages
3. Maintain compatibility with existing functionality
4. When modifying Helm charts with templates, run `make template` to regenerate values.yaml
5. Test Helm charts using the unittest framework in template-deployment before committing