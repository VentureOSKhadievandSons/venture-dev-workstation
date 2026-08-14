#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

log "Checking Python toolchain..."
command_exists python3 || die "python3 is missing after Brewfile install."
command_exists uv || die "uv is missing after Brewfile install."

python3 --version
uv --version

if [[ "${INSTALL_PIPX:-0}" == "1" ]]; then
	if command_exists brew; then
		brew install pipx
		pipx ensurepath
	else
		die "brew is required to install pipx."
	fi
else
	log "Skipping pipx. Set INSTALL_PIPX=1 to install it."
fi
