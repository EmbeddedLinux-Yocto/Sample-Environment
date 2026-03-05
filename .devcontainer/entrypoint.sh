#!/bin/bash
# =============================================================================
# Container entrypoint — runs as user 'yocto' on every container start
#
# Responsibilities:
#   1. Clone Poky into the workspace if it is not already present.
#   2. Hand off to the command passed to the container (default: /bin/bash).
# =============================================================================
set -e

# ---------------------------------------------------------------------------
# Configuration (can be overridden via docker-compose environment variables)
# ---------------------------------------------------------------------------
WORKSPACE="/home/yocto/yocto-workspace"
POKY_DIR="${WORKSPACE}/poky"
POKY_URL="https://git.yoctoproject.org/poky"
POKY_BRANCH="${POKY_BRANCH:-kirkstone}"

# ---------------------------------------------------------------------------
# Clone Poky if not already present
# ---------------------------------------------------------------------------
if [ ! -d "${POKY_DIR}/.git" ]; then
    echo "[entrypoint] Poky not found — cloning branch '${POKY_BRANCH}' into ${POKY_DIR} ..."
    git clone \
        --branch  "${POKY_BRANCH}" \
        --depth   1 \
        "${POKY_URL}" \
        "${POKY_DIR}"
    echo "[entrypoint] Poky cloned successfully."
    echo "[entrypoint] To start a build run:  source poky/oe-init-build-env build"
else
    echo "[entrypoint] Poky already present at ${POKY_DIR} — skipping clone."
fi

# ---------------------------------------------------------------------------
# Hand off to the command passed to the container (default: /bin/bash)
# ---------------------------------------------------------------------------
exec "$@"
