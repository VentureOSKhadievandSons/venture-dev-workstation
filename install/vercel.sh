#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

log "Installing or updating Vercel CLI..."
ensure_local_bin_path
command_exists pnpm || die "pnpm is required."

pnpm add -g vercel
vercel --version
