#!/usr/bin/env bash
set -Eeuo pipefail

echo "Installing security tooling..."

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Run install/homebrew.sh first."
  exit 1
fi

brew install gnupg age

echo "Security tooling setup finished."
