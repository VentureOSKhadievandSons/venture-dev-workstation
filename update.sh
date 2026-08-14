#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

echo "Updating workstation packages..."

ensure_brew
brew update
brew bundle install --file "$BREWFILE_PATH" --no-lock

ensure_local_bin_path

if command_exists corepack; then
	corepack enable
fi

if command_exists pnpm; then
	pnpm add -g \
		@openai/codex \
		@lhci/cli \
		eslint \
		lighthouse \
		npm-check-updates \
		prettier \
		tsx \
		typescript \
		vercel
fi

if [[ -d "$PLAYWRIGHT_DIR" ]] && command_exists pnpm; then
	(
		cd "$PLAYWRIGHT_DIR"
		pnpm install --frozen-lockfile=false
		pnpm exec playwright install chromium firefox webkit
	)
fi

if command_exists gitleaks; then
	gitleaks version >/dev/null
fi

echo "Update finished."
