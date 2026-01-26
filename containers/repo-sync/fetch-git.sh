#!/usr/bin/env bash
set -euo pipefail

# =============================================
# fetch-git.sh — Git clone / commit+push
# =============================================

: "${GIT_REPO_URL:?ERROR: GIT_REPO_URL is required}"

GIT_BRANCH="${GIT_BRANCH:-main}"
GIT_DEPTH="${GIT_DEPTH:-1}"
GIT_SPARSE_PATH="${GIT_SPARSE_PATH:-}"
GIT_USER_NAME="${GIT_USER_NAME:-repo-sync}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-repo-sync@auto}"
GIT_COMMIT_MESSAGE="${GIT_COMMIT_MESSAGE:-auto sync by repo-sync}"
DEST_PATH="${DEST_PATH:-/data}"
SYNC_MODE="${SYNC_MODE:-pull}"

SSH_KEY_FILE="${HOME}/.ssh/id_rsa"
SSH_CLEANUP=false

# ─── 인증 설정 ───────────────────────────────

setup_ssh_key() {
  if [ -n "${GIT_SSH_KEY:-}" ]; then
    echo "==> Setting up SSH key authentication"
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
    echo "${GIT_SSH_KEY}" > "${SSH_KEY_FILE}"
    chmod 600 "${SSH_KEY_FILE}"
    SSH_CLEANUP=true

    # known_hosts 설정 — 호스트 추출
    local git_host
    git_host=$(echo "${GIT_REPO_URL}" | sed -n 's/.*@\([^:]*\):.*/\1/p')
    if [ -n "${git_host}" ]; then
      ssh-keyscan -H "${git_host}" >> "${HOME}/.ssh/known_hosts" 2>/dev/null
    fi

    export GIT_SSH_COMMAND="ssh -i ${SSH_KEY_FILE} -o StrictHostKeyChecking=no"
  fi
}

build_auth_url() {
  local url="${GIT_REPO_URL}"

  # SSH URL이면 그대로 반환 (SSH 키로 인증)
  if echo "${url}" | grep -q "^git@"; then
    echo "${url}"
    return
  fi

  # HTTPS URL + 토큰 → URL에 토큰 삽입
  if [ -n "${GIT_TOKEN:-}" ] && echo "${url}" | grep -q "^https://"; then
    echo "${url}" | sed "s|https://|https://${GIT_TOKEN}@|"
    return
  fi

  echo "${url}"
}

cleanup_ssh_key() {
  if [ "${SSH_CLEANUP}" = true ] && [ -f "${SSH_KEY_FILE}" ]; then
    rm -f "${SSH_KEY_FILE}"
    echo "==> SSH key cleaned up"
  fi
}

# URL 로깅 시 토큰 마스킹
mask_url() {
  echo "$1" | sed 's|https://[^@]*@|https://****@|'
}

trap cleanup_ssh_key EXIT

# ─── SSH 키 설정 ─────────────────────────────
setup_ssh_key

# ─── 인증 URL 생성 ──────────────────────────
AUTH_URL=$(build_auth_url)
echo "==> Git repo: $(mask_url "${AUTH_URL}"), branch: ${GIT_BRANCH}"

# ─── Pull 모드 ───────────────────────────────
if [ "${SYNC_MODE}" = "pull" ]; then
  if [ -d "${DEST_PATH}/.git" ]; then
    echo "==> Existing repo found, fetching updates"
    cd "${DEST_PATH}"
    git remote set-url origin "${AUTH_URL}"
    git fetch origin "${GIT_BRANCH}" --depth="${GIT_DEPTH}"
    git reset --hard "origin/${GIT_BRANCH}"
  else
    echo "==> Cloning repository"
    CLONE_ARGS=(
      --depth "${GIT_DEPTH}"
      --branch "${GIT_BRANCH}"
      --single-branch
    )

    if [ -n "${GIT_SPARSE_PATH}" ]; then
      CLONE_ARGS+=(--sparse)
      git clone "${CLONE_ARGS[@]}" "${AUTH_URL}" "${DEST_PATH}"
      cd "${DEST_PATH}"
      git sparse-checkout set ${GIT_SPARSE_PATH}
    else
      git clone "${CLONE_ARGS[@]}" "${AUTH_URL}" "${DEST_PATH}"
    fi
  fi

  echo "==> Git pull completed"
fi

# ─── Push 모드 ───────────────────────────────
if [ "${SYNC_MODE}" = "push" ]; then
  if [ ! -d "${DEST_PATH}/.git" ]; then
    echo "ERROR: ${DEST_PATH} is not a git repository. Cannot push." >&2
    exit 1
  fi

  cd "${DEST_PATH}"
  git remote set-url origin "${AUTH_URL}"
  git config user.name "${GIT_USER_NAME}"
  git config user.email "${GIT_USER_EMAIL}"

  git add -A
  if git diff --cached --quiet; then
    echo "==> No changes to commit, skipping push"
  else
    git commit -m "${GIT_COMMIT_MESSAGE}"
    git push origin "${GIT_BRANCH}"
    echo "==> Git push completed"
  fi
fi
