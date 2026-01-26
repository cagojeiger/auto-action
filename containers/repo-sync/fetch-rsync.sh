#!/usr/bin/env bash
set -euo pipefail

# =============================================
# fetch-rsync.sh — rsync (로컬/SSH)
# =============================================

: "${RSYNC_SOURCE:?ERROR: RSYNC_SOURCE is required (local path or user@host:/path)}"

DEST_PATH="${DEST_PATH:-/data}"
SYNC_MODE="${SYNC_MODE:-pull}"
RSYNC_FLAGS="${RSYNC_FLAGS:--avz}"
RSYNC_DELETE="${RSYNC_DELETE:-false}"

SSH_KEY_FILE="${HOME}/.ssh/repo-sync-key"
SSH_CLEANUP=false
SSH_CMD=""

# ─── SSH 키 설정 ─────────────────────────────

setup_ssh_key() {
  if [ -n "${RSYNC_SSH_KEY:-}" ]; then
    echo "==> Setting up SSH key for rsync"
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
    echo "${RSYNC_SSH_KEY}" > "${SSH_KEY_FILE}"
    chmod 600 "${SSH_KEY_FILE}"
    SSH_CLEANUP=true
    SSH_CMD="-e ssh -i ${SSH_KEY_FILE} -o StrictHostKeyChecking=no"
  fi
}

cleanup_ssh_key() {
  if [ "${SSH_CLEANUP}" = true ] && [ -f "${SSH_KEY_FILE}" ]; then
    rm -f "${SSH_KEY_FILE}"
    echo "==> SSH key cleaned up"
  fi
}

trap cleanup_ssh_key EXIT

setup_ssh_key

# ─── rsync 플래그 구성 ──────────────────────

RSYNC_ARGS="${RSYNC_FLAGS}"

if [ "${RSYNC_DELETE}" = "true" ]; then
  RSYNC_ARGS="${RSYNC_ARGS} --delete"
fi

if [ -n "${SSH_CMD}" ]; then
  RSYNC_ARGS="${RSYNC_ARGS} ${SSH_CMD}"
fi

# ─── Pull 모드 ───────────────────────────────

if [ "${SYNC_MODE}" = "pull" ]; then
  echo "==> rsync pull: ${RSYNC_SOURCE} -> ${DEST_PATH}/"
  # shellcheck disable=SC2086
  rsync ${RSYNC_ARGS} "${RSYNC_SOURCE}" "${DEST_PATH}/"
  echo "==> rsync pull completed"
fi

# ─── Push 모드 ───────────────────────────────

if [ "${SYNC_MODE}" = "push" ]; then
  echo "==> rsync push: ${DEST_PATH}/ -> ${RSYNC_SOURCE}"
  # shellcheck disable=SC2086
  rsync ${RSYNC_ARGS} "${DEST_PATH}/" "${RSYNC_SOURCE}"
  echo "==> rsync push completed"
fi
