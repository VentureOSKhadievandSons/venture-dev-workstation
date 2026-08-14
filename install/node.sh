#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

log "Configuring Node.js toolchain..."
ensure_local_bin_path

command_exists node || die "node is missing after Brewfile install."
command_exists npm || die "npm is missing after Brewfile install."

if command_exists corepack; then
	corepack enable
fi

if ! command_exists pnpm; then
	npm install -g pnpm
fi

pnpm add -g \
	@lhci/cli \
	eslint \
	lighthouse \
	npm-check-updates \
	prettier \
	tsx \
	typescript

log "Node.js: $(node --version)"
log "pnpm: $(pnpm --version)"
