#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYWRIGHT_DIR="$HOME/.codex-tools/browser-qa"

echo "Updating Homebrew..."
if command -v brew >/dev/null 2>&1; then
  brew update
  brew upgrade
else
  echo "Homebrew not found. Skipping."
fi

echo
echo "Updating pnpm..."
if command -v pnpm >/dev/null 2>&1; then
  pnpm self-update || true
else
  echo "pnpm not found. Skipping."
fi

echo
echo "Updating global Node packages..."
if command -v pnpm >/dev/null 2>&1; then
  pnpm add -g \
    lighthouse \
    @lhci/cli \
    typescript \
    tsx \
    eslint \
    prettier \
    npm-check-updates \
    serve \
    autocannon \
    vercel
else
  echo "pnpm not found. Skipping global packages."
fi

echo
echo "Updating Playwright workspace..."
if [[ -d "$PLAYWRIGHT_DIR" ]] && command -v pnpm >/dev/null 2>&1; then
  cd "$PLAYWRIGHT_DIR"
  pnpm add -D playwright @playwright/test @playwright/mcp axe-playwright
  pnpm exec playwright install chromium firefox webkit
else
  echo "Playwright workspace not found. Skipping."
fi

echo
echo "Update finished."
