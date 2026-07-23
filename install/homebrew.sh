#!/usr/bin/env bash
set -Eeuo pipefail

ZPROFILE_FILE="$HOME/.zprofile"

append_line_if_missing() {
  local file="$1"
  local line="$2"

  touch "$file"

  if ! grep -Fqx "$line" "$file"; then
    echo "$line" >>"$file"
  fi
}

echo "Checking Homebrew..."

if command -v brew >/dev/null 2>&1; then
  echo "Homebrew is already installed."
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

append_line_if_missing "$ZPROFILE_FILE" 'eval "$(/opt/homebrew/bin/brew shellenv)"'

eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Updating Homebrew metadata..."
brew update
