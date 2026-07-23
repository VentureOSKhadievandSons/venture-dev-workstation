#!/usr/bin/env bash
set -Eeuo pipefail

echo "Installing Docker Desktop..."

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Run install/homebrew.sh first."
  exit 1
fi

if [[ -d "/Applications/Docker.app" ]]; then
  echo "Docker Desktop is already installed."
  exit 0
fi

brew install --cask docker

echo "Docker setup finished."
