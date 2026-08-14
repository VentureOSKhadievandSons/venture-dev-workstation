#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

log "Installing or updating Codex CLI..."
ensure_local_bin_path
command_exists npm || die "npm is required to install Codex CLI."

npm install -g @openai/codex
codex --version
