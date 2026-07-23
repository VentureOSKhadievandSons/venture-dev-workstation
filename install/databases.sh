#!/usr/bin/env bash
set -Eeuo pipefail

echo "Installing PostgreSQL and Redis..."

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Run install/homebrew.sh first."
  exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
  brew install postgresql@17
else
  echo "PostgreSQL command is already available."
fi

if ! brew list redis >/dev/null 2>&1; then
  brew install redis
else
  echo "Redis is already installed."
fi

if brew list postgresql@17 >/dev/null 2>&1; then
  brew services start postgresql@17
fi

brew services start redis

echo "Database setup finished."
