#!/usr/bin/env bash
set -euo pipefail

# =============================================
# entrypoint.sh — SOURCE_TYPE + SYNC_MODE 라우팅
# =============================================

: "${SOURCE_TYPE:?ERROR: SOURCE_TYPE is required (git / rclone / rsync)}"

SYNC_MODE="${SYNC_MODE:-pull}"
SYNC_INTERVAL="${SYNC_INTERVAL:-0}"
DEST_PATH="${DEST_PATH:-/data}"

# SOURCE_TYPE 검증
case "${SOURCE_TYPE}" in
  git|rclone|rsync) ;;
  *)
    echo "ERROR: Unsupported SOURCE_TYPE '${SOURCE_TYPE}'. Must be git, rclone, or rsync." >&2
    exit 1
    ;;
esac

# SYNC_MODE 검증
case "${SYNC_MODE}" in
  pull|push) ;;
  *)
    echo "ERROR: Unsupported SYNC_MODE '${SYNC_MODE}'. Must be pull or push." >&2
    exit 1
    ;;
esac

# DEST_PATH 디렉토리 생성
mkdir -p "${DEST_PATH}"

echo "==> repo-sync: SOURCE_TYPE=${SOURCE_TYPE}, SYNC_MODE=${SYNC_MODE}, DEST_PATH=${DEST_PATH}"

# 핸들러 디스패치
if [ "${SYNC_INTERVAL}" -le 0 ]; then
  # ── Init container 모드: 한 번 실행 후 종료 ──
  exec "/usr/local/bin/fetch-${SOURCE_TYPE}.sh"
else
  # ── Sidecar 모드: 주기적 반복 실행 ──
  echo "==> Sidecar mode: syncing every ${SYNC_INTERVAL}s"

  RUNNING=true
  trap 'RUNNING=false; echo "==> Received shutdown signal"' SIGTERM SIGINT

  while ${RUNNING}; do
    "/usr/local/bin/fetch-${SOURCE_TYPE}.sh" || \
      echo "WARN: sync failed (exit $?), retrying in ${SYNC_INTERVAL}s"

    # 인터럽트 가능한 sleep (SIGTERM 시 즉시 종료)
    sleep "${SYNC_INTERVAL}" &
    wait $! || true
  done

  echo "==> Sidecar stopped"
fi
