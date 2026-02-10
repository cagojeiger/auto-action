# file-fetcher

Kubernetes/OpenShift init container로 사용하는 경량 파일 전송 이미지입니다. rclone 기반으로 S3, SFTP, HTTP 등 70+ 스토리지 백엔드를 지원합니다.

## 보안 특성

- Alpine 버전 고정 + multi-stage 빌드 (빌드 도구 미포함)
- SHA256 체크섬 검증으로 바이너리 무결성 보장
- setuid/setgid 비트 전량 제거
- non-root 실행 (UID 1001)
- OpenShift arbitrary UID 호환 (group-root 소유 + group writable)

## 지원 백엔드

| 백엔드 | 설정 방식 | 비고 |
|--------|----------|------|
| S3 (AWS, MinIO, Ceph) | 환경변수 | `RCLONE_CONFIG_<REMOTE>_*` |
| SFTP | 환경변수 | SSH 기반, 추가 패키지 불필요 |
| HTTP/HTTPS | 환경변수 | 파일 다운로드용 |
| NFS/NAS | PVC 마운트 | K8s가 마운트 → `local` copy |
| WebDAV | 환경변수 | NextCloud 등 |

## 사용법

ENTRYPOINT가 `rclone`이므로, pod spec에서 `args`로 rclone 커맨드를 직접 전달합니다. 리모트 인증 정보는 rclone 네이티브 환경변수(`RCLONE_CONFIG_<REMOTE>_*`)로 설정합니다.

### S3에서 파일 가져오기

```yaml
initContainers:
  - name: fetch-config
    image: cagojeiger/file-fetcher:1.73.0
    args: ["copy", "s3remote:my-bucket/config/", "/data", "--progress"]
    env:
      - name: RCLONE_CONFIG_S3REMOTE_TYPE
        value: "s3"
      - name: RCLONE_CONFIG_S3REMOTE_PROVIDER
        value: "AWS"
      - name: RCLONE_CONFIG_S3REMOTE_ENDPOINT
        value: "https://s3.amazonaws.com"
      - name: RCLONE_CONFIG_S3REMOTE_ACCESS_KEY_ID
        valueFrom:
          secretKeyRef: { name: s3-creds, key: access-key }
      - name: RCLONE_CONFIG_S3REMOTE_SECRET_ACCESS_KEY
        valueFrom:
          secretKeyRef: { name: s3-creds, key: secret-key }
    volumeMounts:
      - name: shared-data
        mountPath: /data
```

### SFTP에서 파일 가져오기

```yaml
initContainers:
  - name: fetch-from-sftp
    image: cagojeiger/file-fetcher:1.73.0
    args: ["copy", "sftpremote:/remote/path/", "/data", "--progress"]
    env:
      - name: RCLONE_CONFIG_SFTPREMOTE_TYPE
        value: "sftp"
      - name: RCLONE_CONFIG_SFTPREMOTE_HOST
        value: "sftp.example.com"
      - name: RCLONE_CONFIG_SFTPREMOTE_USER
        valueFrom:
          secretKeyRef: { name: sftp-creds, key: username }
      - name: RCLONE_CONFIG_SFTPREMOTE_PASS
        valueFrom:
          secretKeyRef: { name: sftp-creds, key: password }
    volumeMounts:
      - name: shared-data
        mountPath: /data
```

### NFS/NAS에서 파일 가져오기

NFS는 K8s PVC로 마운트한 뒤 local copy로 처리합니다:

```yaml
volumes:
  - name: nfs-source
    persistentVolumeClaim:
      claimName: nfs-data
  - name: shared-data
    emptyDir: {}

initContainers:
  - name: fetch-from-nfs
    image: cagojeiger/file-fetcher:1.73.0
    args: ["copy", "/nfs-mount/source-files/", "/data"]
    volumeMounts:
      - name: nfs-source
        mountPath: /nfs-mount
        readOnly: true
      - name: shared-data
        mountPath: /data
```

## 로컬 빌드

```bash
cd containers/file-fetcher
docker buildx build --platform linux/amd64,linux/arm64 -t file-fetcher:1.73.0 .
```

## 지원 아키텍처

- linux/amd64
- linux/arm64
