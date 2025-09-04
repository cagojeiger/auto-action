# Bitnami Legacy Migration Guide

## Overview

This LiteLLM Helm chart has been migrated from Bitnami repositories to `bitnamilegacy` repositories due to Bitnami's commercialization policy effective August 28, 2025 (postponed to September 29, 2025).

## ⚠️ Important Notice

- **Legacy images receive NO security updates after August 28, 2025**
- **Plan alternative solution within 6-12 months**
- **Images are frozen at current versions**

## Migration Details

### Changed Components

| Component | Original | Legacy Repository |
|-----------|----------|-------------------|
| PostgreSQL | `bitnami/postgresql` | `bitnamilegacy/postgresql:17.6.0-debian-12-r4` |
| Redis | `bitnami/redis` | `bitnamilegacy/redis:8.2.1-debian-12-r0` |
| OS Shell | `bitnami/os-shell` | `bitnamilegacy/os-shell:12-debian-12-r51` |
| PostgreSQL Exporter | `bitnami/postgres-exporter` | `bitnamilegacy/postgres-exporter:0.17.1-debian-12-r16` |
| Redis Exporter | `bitnami/redis-exporter` | `bitnamilegacy/redis-exporter:1.76.0-debian-12-r0` |

### Configuration Changes

#### 1. Global Security Setting
```yaml
litellm-helm:
  global:
    security:
      allowInsecureImages: true  # Required for legacy repositories
```

#### 2. PostgreSQL Configuration
```yaml
litellm-helm:
  postgresql:
    image:
      repository: bitnamilegacy/postgresql
      tag: "17.6.0-debian-12-r4"
    volumePermissions:
      image:
        repository: bitnamilegacy/os-shell
        tag: "12-debian-12-r51"
```

#### 3. Redis Configuration (when enabled)
```yaml
litellm-helm:
  redis:
    enabled: true
    image:
      repository: bitnamilegacy/redis
      tag: "8.2.1-debian-12-r0"
```

## Installation

### Method 1: Using values.yaml (Recommended)
```bash
helm install litellm .
```

### Method 2: Command Line Override
```bash
helm install litellm . \\
  --set "litellm-helm.global.security.allowInsecureImages=true" \\
  --set "litellm-helm.postgresql.image.repository=bitnamilegacy/postgresql" \\
  --set "litellm-helm.postgresql.image.tag=17.6.0-debian-12-r4" \\
  --set "litellm-helm.redis.image.repository=bitnamilegacy/redis" \\
  --set "litellm-helm.redis.image.tag=8.2.1-debian-12-r0"
```

*Note: Method 2 is redundant as these settings are already included in values.yaml*

## Upgrade from Previous Version

```bash
# Backup current deployment
helm get values litellm > current-values.yaml

# Upgrade with legacy images
helm upgrade litellm . -f values.yaml

# Verify deployment
kubectl get pods -l app.kubernetes.io/instance=litellm
```

## Alternative Solutions (Long-term)

### 1. Managed Database Services
- **AWS RDS PostgreSQL** (~$15-30/month)
- **Google Cloud SQL** (~$10-25/month)
- **Azure Database for PostgreSQL** (~$12-28/month)

### 2. Official Docker Images
```yaml
postgresql:
  image:
    repository: postgres  # Official PostgreSQL
    tag: "16-bookworm"   # Debian-based for better performance
```

### 3. CloudNative PostgreSQL Operator
```bash
# Install operator
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.22/releases/cnpg-1.22.0.yaml

# Create PostgreSQL cluster
kubectl apply -f - <<EOF
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: litellm-postgres
spec:
  instances: 3
  postgresql:
    parameters:
      max_connections: "200"
  storage:
    size: 10Gi
EOF
```

### 4. Alternative Container Images
- **Chainguard Images**: `cgr.dev/chainguard/postgres:latest`
- **Google Distroless**: Custom build required
- **Debian Slim**: `postgres:16-bookworm-slim`

## Timeline & Action Plan

### Immediate (✅ Completed)
- [x] Migrate to bitnamilegacy repositories
- [x] Test deployment functionality
- [x] Document changes

### Short-term (1-3 months)
- [ ] Evaluate alternative solutions
- [ ] Test migration to official PostgreSQL images
- [ ] Consider managed database services

### Medium-term (3-6 months)  
- [ ] Implement chosen alternative solution
- [ ] Migrate production deployments
- [ ] Update CI/CD pipelines

### Long-term (6-12 months)
- [ ] Complete migration away from legacy images
- [ ] Remove legacy configuration
- [ ] Update documentation

## Troubleshooting

### Common Issues

#### 1. Security Warning about Unrecognized Images
```
⚠ ERROR: Unrecognized images: docker.io/bitnamilegacy/postgresql:17.6.0-debian-12-r4
```
**Solution**: Ensure `global.security.allowInsecureImages: true` is set

#### 2. Image Pull Errors
```
ImagePullBackOff: Failed to pull image "bitnamilegacy/postgresql:17.6.0-debian-12-r4"
```
**Solution**: Legacy repository may not be available yet. Wait until August 28, 2025

#### 3. Pod Startup Issues
**Solution**: Check resource limits and persistent volume claims

### Verification Commands

```bash
# Check image repositories in use
kubectl get pods -o yaml | grep -E "image.*bitnamilegacy"

# Check PostgreSQL status
kubectl exec -it $(kubectl get pods -l app.kubernetes.io/name=postgresql -o name | head -1) -- psql -U litellm -d litellm -c "SELECT version();"

# Check Redis status (if enabled)
kubectl exec -it $(kubectl get pods -l app.kubernetes.io/name=redis -o name | head -1) -- redis-cli ping
```

## Support & Feedback

For issues with this migration:
1. Check this documentation
2. Review Helm template output: `helm template litellm . --debug`
3. Create GitHub issue with migration-related problems

## References

- [Bitnami Migration Announcement](https://github.com/bitnami/charts/issues/35164)
- [LiteLLM Helm Chart](https://github.com/BerriAI/litellm)
- [CloudNative PostgreSQL](https://cloudnative-pg.io/)
- [PostgreSQL Official Images](https://hub.docker.com/_/postgres)

---

**Last Updated**: January 4, 2025  
**Migration Deadline**: September 29, 2025  
**Status**: ✅ Completed - Ready for deployment