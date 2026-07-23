#!/usr/bin/env bash
set -Eeuo pipefail

PNPM_HOME_DIR="$HOME/Library/pnpm/bin"
ZSHENV_FILE="$HOME/.zshenv"

append_line_if_missing() {
  local file="$1"
  local line="$2"

  touch "$file"

  if ! grep -Fqx "$line" "$file"; then
    echo "$line" >>"$file"
  fi
}

echo "Installing Node.js and pnpm..."

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Run install/homebrew.sh first."
  exit 1
fi

brew install node pnpm

mkdir -p "$PNPM_HOME_DIR" "$HOME/.local/bin"

append_line_if_missing "$ZSHENV_FILE" 'export PNPM_HOME="$HOME/Library/pnpm/bin"'
append_line_if_missing "$ZSHENV_FILE" 'export PATH="$PNPM_HOME:$HOME/.local/bin:$PATH"'

export PNPM_HOME="$PNPM_HOME_DIR"
export PATH="$PNPM_HOME:$HOME/.local/bin:$PATH"

if ! pnpm bin -g >/dev/null 2>&1; then
  echo "Running pnpm setup..."
  SHELL="${SHELL:-/bin/zsh}" pnpm setup
fi

echo "Installing global Node tools..."
pnpm add -g \
  lighthouse \
  @lhci/cli \
  typescript \
  tsx \
  eslint \
  prettier \
  npm-check-updates \
  serve \
  autocannon

echo "Node.js and pnpm setup finished."
