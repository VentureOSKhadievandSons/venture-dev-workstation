#!/usr/bin/env bash
set -Eeuo pipefail

echo "Installing browsers..."

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Run install/homebrew.sh first."
  exit 1
fi

if [[ -d "/Applications/Google Chrome.app" ]]; then
  echo "Google Chrome is already installed."
  exit 0
fi

brew install --cask google-chrome

echo "Browser setup finished."
