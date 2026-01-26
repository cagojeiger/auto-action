# repo-sync

Kubernetes init container / sidecar for bidirectional data synchronization. Supports Git, rclone (cloud storage), and rsync (local/SSH) with pull/push modes controlled via environment variables.

## Quick Start

```bash
# Git: Clone a public repository
docker run --rm \
  -e SOURCE_TYPE=git \
  -e GIT_REPO_URL=https://github.com/octocat/Hello-World.git \
  -e GIT_BRANCH=master \
  -v /tmp/data:/data \
  cagojeiger/repo-sync:latest
```

## Environment Variables

### Common

| Variable | Description | Default |
|----------|-------------|---------|
| `SOURCE_TYPE` | `git` / `rclone` / `rsync` | **(required)** |
| `SYNC_MODE` | `pull` / `push` | `pull` |
| `SYNC_INTERVAL` | Sync interval in seconds. `0` = run once (init container), `>0` = repeat (sidecar) | `0` |
| `DEST_PATH` | Local destination path | `/data` |

### Git (`SOURCE_TYPE=git`)

| Variable | Description | Default |
|----------|-------------|---------|
| `GIT_REPO_URL` | Repository URL (HTTPS or SSH) | **(required)** |
| `GIT_BRANCH` | Branch name | `main` |
| `GIT_TOKEN` | HTTPS authentication token | - |
| `GIT_SSH_KEY` | SSH private key content (for `git@` URLs) | - |
| `GIT_DEPTH` | Shallow clone depth | `1` |
| `GIT_SPARSE_PATH` | Sparse checkout path(s) | - |
| `GIT_USER_NAME` | Commit author name (push mode) | `repo-sync` |
| `GIT_USER_EMAIL` | Commit author email (push mode) | `repo-sync@auto` |
| `GIT_COMMIT_MESSAGE` | Commit message (push mode) | `auto sync by repo-sync` |

### rclone (`SOURCE_TYPE=rclone`)

| Variable | Description | Default |
|----------|-------------|---------|
| `RCLONE_REMOTE_PATH` | Remote path (e.g. `bucket/prefix`) | **(required)** |
| `RCLONE_CONFIG_REMOTE_TYPE` | rclone backend type (e.g. `s3`) | **(required)** |
| `RCLONE_CONFIG_REMOTE_*` | rclone native env vars (auth included) | varies by backend |
| `RCLONE_FLAGS` | Additional rclone flags | - |

### rsync (`SOURCE_TYPE=rsync`)

| Variable | Description | Default |
|----------|-------------|---------|
| `RSYNC_SOURCE` | Source path (local or `user@host:/path`) | **(required)** |
| `RSYNC_FLAGS` | rsync flags | `-avz` |
| `RSYNC_SSH_KEY` | SSH private key content (for remote) | - |
| `RSYNC_DELETE` | `true` enables `--delete` (mirror mode) | `false` |

## Usage Examples

### Git: Public repo pull

```bash
docker run --rm \
  -e SOURCE_TYPE=git \
  -e GIT_REPO_URL=https://github.com/octocat/Hello-World.git \
  -e GIT_BRANCH=master \
  -v /tmp/data:/data \
  cagojeiger/repo-sync:latest
```

### Git: Private repo (HTTPS token)

```bash
docker run --rm \
  -e SOURCE_TYPE=git \
  -e GIT_REPO_URL=https://github.com/org/private-repo.git \
  -e GIT_TOKEN=ghp_xxxxxxxxxxxx \
  -v /tmp/data:/data \
  cagojeiger/repo-sync:latest
```

### Git: Private repo (SSH key)

```bash
docker run --rm \
  -e SOURCE_TYPE=git \
  -e GIT_REPO_URL=git@github.com:org/private-repo.git \
  -e GIT_SSH_KEY="$(cat ~/.ssh/id_rsa)" \
  -v /tmp/data:/data \
  cagojeiger/repo-sync:latest
```

### Git: Auto commit & push

```bash
docker run --rm \
  -e SOURCE_TYPE=git \
  -e SYNC_MODE=push \
  -e GIT_REPO_URL=https://github.com/org/repo.git \
  -e GIT_TOKEN=ghp_xxxxxxxxxxxx \
  -e GIT_BRANCH=main \
  -e GIT_USER_NAME="bot" \
  -e GIT_USER_EMAIL="bot@example.com" \
  -e GIT_COMMIT_MESSAGE="chore: auto sync" \
  -v /tmp/data:/data \
  cagojeiger/repo-sync:latest
```

### S3/MinIO: Pull from bucket

```bash
docker run --rm \
  -e SOURCE_TYPE=rclone \
  -e RCLONE_REMOTE_PATH=my-bucket/data \
  -e RCLONE_CONFIG_REMOTE_TYPE=s3 \
  -e RCLONE_CONFIG_REMOTE_PROVIDER=Minio \
  -e RCLONE_CONFIG_REMOTE_ACCESS_KEY_ID=minioadmin \
  -e RCLONE_CONFIG_REMOTE_SECRET_ACCESS_KEY=minioadmin \
  -e RCLONE_CONFIG_REMOTE_ENDPOINT=http://minio:9000 \
  -v /tmp/data:/data \
  cagojeiger/repo-sync:latest
```

### S3/MinIO: Push to bucket

```bash
docker run --rm \
  -e SOURCE_TYPE=rclone \
  -e SYNC_MODE=push \
  -e RCLONE_REMOTE_PATH=my-bucket/backup \
  -e RCLONE_CONFIG_REMOTE_TYPE=s3 \
  -e RCLONE_CONFIG_REMOTE_PROVIDER=AWS \
  -e RCLONE_CONFIG_REMOTE_ACCESS_KEY_ID=AKIAXXXXXXXX \
  -e RCLONE_CONFIG_REMOTE_SECRET_ACCESS_KEY=secret \
  -e RCLONE_CONFIG_REMOTE_REGION=ap-northeast-2 \
  -v /tmp/data:/data \
  cagojeiger/repo-sync:latest
```

### rsync: Local volume copy

```bash
docker run --rm \
  -e SOURCE_TYPE=rsync \
  -e RSYNC_SOURCE=/src/ \
  -v /tmp/source:/src:ro \
  -v /tmp/dest:/data \
  cagojeiger/repo-sync:latest
```

### rsync: Remote SSH sync

```bash
docker run --rm \
  -e SOURCE_TYPE=rsync \
  -e RSYNC_SOURCE=user@remote-host:/path/to/data/ \
  -e RSYNC_SSH_KEY="$(cat ~/.ssh/id_rsa)" \
  -e RSYNC_DELETE=true \
  -v /tmp/data:/data \
  cagojeiger/repo-sync:latest
```

## Kubernetes Examples

### Init container: Clone repo before app starts

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  initContainers:
    - name: repo-sync
      image: cagojeiger/repo-sync:latest
      env:
        - name: SOURCE_TYPE
          value: "git"
        - name: GIT_REPO_URL
          value: "https://github.com/org/config-repo.git"
        - name: GIT_TOKEN
          valueFrom:
            secretKeyRef:
              name: git-credentials
              key: token
      volumeMounts:
        - name: data
          mountPath: /data
  containers:
    - name: app
      image: my-app:latest
      volumeMounts:
        - name: data
          mountPath: /app/config
  volumes:
    - name: data
      emptyDir: {}
```

### Sidecar: Continuous git sync alongside app

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: app
          image: my-app:latest
          volumeMounts:
            - name: data
              mountPath: /app/config
        - name: repo-sync
          image: cagojeiger/repo-sync:latest
          env:
            - name: SOURCE_TYPE
              value: "git"
            - name: GIT_REPO_URL
              value: "https://github.com/org/config-repo.git"
            - name: GIT_TOKEN
              valueFrom:
                secretKeyRef:
                  name: git-credentials
                  key: token
            - name: SYNC_INTERVAL
              value: "60"
          volumeMounts:
            - name: data
              mountPath: /data
      volumes:
        - name: data
          emptyDir: {}
```

### Sidecar: Periodic S3 sync with CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: s3-backup
spec:
  schedule: "0 */6 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: repo-sync
              image: cagojeiger/repo-sync:latest
              env:
                - name: SOURCE_TYPE
                  value: "rclone"
                - name: SYNC_MODE
                  value: "push"
                - name: RCLONE_REMOTE_PATH
                  value: "backup-bucket/daily"
                - name: RCLONE_CONFIG_REMOTE_TYPE
                  value: "s3"
                - name: RCLONE_CONFIG_REMOTE_PROVIDER
                  value: "Minio"
                - name: RCLONE_CONFIG_REMOTE_ACCESS_KEY_ID
                  valueFrom:
                    secretKeyRef:
                      name: s3-credentials
                      key: access-key
                - name: RCLONE_CONFIG_REMOTE_SECRET_ACCESS_KEY
                  valueFrom:
                    secretKeyRef:
                      name: s3-credentials
                      key: secret-key
                - name: RCLONE_CONFIG_REMOTE_ENDPOINT
                  value: "https://minio.internal:9000"
              volumeMounts:
                - name: data
                  mountPath: /data
          volumes:
            - name: data
              persistentVolumeClaim:
                claimName: app-data
```

### Secret configuration examples

```yaml
# Git HTTPS token
apiVersion: v1
kind: Secret
metadata:
  name: git-credentials
type: Opaque
stringData:
  token: "ghp_xxxxxxxxxxxx"
---
# Git SSH key
apiVersion: v1
kind: Secret
metadata:
  name: git-ssh-key
type: Opaque
stringData:
  id_rsa: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    ...
    -----END OPENSSH PRIVATE KEY-----
---
# S3/MinIO credentials
apiVersion: v1
kind: Secret
metadata:
  name: s3-credentials
type: Opaque
stringData:
  access-key: "minioadmin"
  secret-key: "minioadmin"
```

## Supported rclone Backends

### AWS S3

```bash
RCLONE_CONFIG_REMOTE_TYPE=s3
RCLONE_CONFIG_REMOTE_PROVIDER=AWS
RCLONE_CONFIG_REMOTE_ACCESS_KEY_ID=AKIA...
RCLONE_CONFIG_REMOTE_SECRET_ACCESS_KEY=...
RCLONE_CONFIG_REMOTE_REGION=ap-northeast-2
```

### MinIO

```bash
RCLONE_CONFIG_REMOTE_TYPE=s3
RCLONE_CONFIG_REMOTE_PROVIDER=Minio
RCLONE_CONFIG_REMOTE_ACCESS_KEY_ID=minioadmin
RCLONE_CONFIG_REMOTE_SECRET_ACCESS_KEY=minioadmin
RCLONE_CONFIG_REMOTE_ENDPOINT=http://minio:9000
```

### Google Cloud Storage

```bash
RCLONE_CONFIG_REMOTE_TYPE=google cloud storage
RCLONE_CONFIG_REMOTE_PROJECT_NUMBER=123456789
RCLONE_CONFIG_REMOTE_SERVICE_ACCOUNT_FILE=/path/to/sa.json
```

### Azure Blob Storage

```bash
RCLONE_CONFIG_REMOTE_TYPE=azureblob
RCLONE_CONFIG_REMOTE_ACCOUNT=myaccount
RCLONE_CONFIG_REMOTE_KEY=base64key...
```

## Build

```bash
# Local build
docker build -t repo-sync:test containers/repo-sync/

# Multi-architecture build
docker buildx build --platform linux/amd64,linux/arm64 -t repo-sync:test containers/repo-sync/
```
