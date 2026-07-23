#!/usr/bin/env bash
set -Eeuo pipefail

echo "Installing PostgreSQL and Redis..."

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Run install/homebrew.sh first."
  exit 1
fi

brew install postgresql@17 redis

brew services start postgresql@17
brew services start redis

echo "Database setup finished."
