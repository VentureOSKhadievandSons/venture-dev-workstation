#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

log "Checking Docker Desktop..."

if [[ -d "/Applications/Docker.app" ]]; then
	log "Docker Desktop is installed."
else
	warn "Docker Desktop is not installed yet. Brewfile includes the official cask."
fi

if command_exists docker; then
	docker --version
else
	warn "docker CLI is not available until Docker Desktop finishes installation."
fi
