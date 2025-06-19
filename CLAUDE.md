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
- **template-deployment**: A reusable base chart that provides template inheritance functionality
  - Supports type-based configuration inheritance (e.g., `web`, `api`, `database`)
  - Reduces boilerplate by allowing templates to inherit common configurations
  - Enables multi-type inheritance with priority ordering
- **Bundle charts** (ops-stack, oss-ai-stack, monitoring): Pre-configured service stacks with dependencies
- **Service charts** (casdoor, code-server): Individual service deployments

### 3. Value Templating Pattern
Charts use Gomplate for value templating:
- `values.yaml.tmpl`: Template with placeholders
- `vars.yaml`: Variable definitions
- `make template`: Generates final values.yaml

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

# Generate values.yaml from template
cd helm-charts/<chart-name>
make template
```

### Testing and Validation
```bash
# Run Helm unit tests
cd helm-charts/template-deployment
make test

# Lint Helm chart
helm lint helm-charts/<chart-name>

# Preview Helm deployment
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