# nfs-server

Alpine Linux 기반 경량 NFSv4 서버 컨테이너입니다.

## 사용법

```bash
docker run -d --privileged --net=host \
  -v /path/to/data:/export \
  cagojeiger/nfs-server:latest
```

## 환경변수

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `NFS_EXPORT_DIR` | `/export` | NFS export 경로 |
| `NFS_ALLOWED_CLIENTS` | `*` | 접근 허용 클라이언트 |
| `NFS_OPTIONS` | `rw,sync,no_subtree_check,no_root_squash,fsid=0` | NFS export 옵션 |

## 요구사항

- 호스트 커널에 `nfsd` 모듈 필요
- `privileged: true` 필요

## 지원 아키텍처

- linux/amd64
- linux/arm64
