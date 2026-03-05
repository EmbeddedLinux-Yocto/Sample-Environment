#!/usr/bin/env bash
# =============================================================================
# run_yocto_env.sh — Start the Yocto build container
#
# Usage:
#   ./run_yocto_env.sh          # Opens interactive shell inside container
#   ./run_yocto_env.sh build    # Passes 'build' arg (reserved for future use)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Export host UID/GID so Dockerfile ARGs match the owner of mounted volumes
export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"

# Create local workspace directory at project root if it doesn't exist yet
mkdir -p "${SCRIPT_DIR}/../yocto-workspace"

echo "================================================================"
echo "  Yocto Build Environment — Jetson Nano Orin"
echo "  UID: ${HOST_UID}  |  GID: ${HOST_GID}"
echo "================================================================"

# Build the image if it doesn't exist, then start the container
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" run --rm yocto-build /bin/bash
