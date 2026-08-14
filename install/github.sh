#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

log "Configuring GitHub tooling..."
command_exists git || die "git is required."
command_exists gh || die "gh is missing after Brewfile install."

git lfs install

if gh auth status >/dev/null 2>&1; then
	log "GitHub CLI is already authenticated."
else
	warn "GitHub CLI is not authenticated yet. Run: gh auth login"
fi

warn "Do not copy private SSH keys through this repository. Generate a new SSH key on the new Mac and add the public key to GitHub."
