#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

log "Checking PostgreSQL and Redis..."
command_exists psql || die "psql is missing after Brewfile install."
command_exists redis-cli || die "redis-cli is missing after Brewfile install."

if [[ "${ENABLE_BREW_SERVICES:-1}" == "1" ]]; then
	brew services start postgresql@17
	brew services start redis
else
	warn "Skipping brew services start. Set ENABLE_BREW_SERVICES=1 to enable."
fi

psql --version
redis-cli --version
