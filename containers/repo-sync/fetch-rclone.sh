#!/usr/bin/env bash
set -euo pipefail

# =============================================
# fetch-rclone.sh — rclone sync (S3, GCS, Azure 등)
# =============================================

: "${RCLONE_REMOTE_PATH:?ERROR: RCLONE_REMOTE_PATH is required (e.g. bucket/prefix)}"

DEST_PATH="${DEST_PATH:-/data}"
SYNC_MODE="${SYNC_MODE:-pull}"
RCLONE_FLAGS="${RCLONE_FLAGS:-}"

# rclone 네이티브 환경변수(RCLONE_CONFIG_REMOTE_*)가 자동으로 인증 처리
# 별도 인증 로직 불필요

echo "==> rclone: remote path = remote:${RCLONE_REMOTE_PATH}"

if [ "${SYNC_MODE}" = "pull" ]; then
  echo "==> Syncing from remote to local"
  # shellcheck disable=SC2086
  rclone sync "remote:${RCLONE_REMOTE_PATH}" "${DEST_PATH}" ${RCLONE_FLAGS}
  echo "==> rclone pull completed"
fi

if [ "${SYNC_MODE}" = "push" ]; then
  echo "==> Syncing from local to remote"
  # shellcheck disable=SC2086
  rclone sync "${DEST_PATH}" "remote:${RCLONE_REMOTE_PATH}" ${RCLONE_FLAGS}
  echo "==> rclone push completed"
fi
