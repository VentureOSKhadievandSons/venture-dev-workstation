#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

log "Ensuring Homebrew and Brewfile packages..."
assert_not_root
ensure_brew
brew_bundle_install
