#!/usr/bin/env bash
set -Eeuo pipefail

echo "Installing developer CLI tools..."

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Run install/homebrew.sh first."
  exit 1
fi

brew install git gh jq ripgrep fd fzf

if command -v pnpm >/dev/null 2>&1; then
  pnpm add -g vercel
else
  echo "pnpm not found. Skipping Vercel CLI install."
fi

echo "Developer tools setup finished."
