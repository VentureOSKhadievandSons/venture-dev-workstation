#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting workstation bootstrap..."

for script in \
  "$ROOT_DIR/install/homebrew.sh" \
  "$ROOT_DIR/install/node.sh" \
  "$ROOT_DIR/install/developer-tools.sh" \
  "$ROOT_DIR/install/docker.sh" \
  "$ROOT_DIR/install/databases.sh" \
  "$ROOT_DIR/install/browsers.sh" \
  "$ROOT_DIR/install/playwright.sh" \
  "$ROOT_DIR/install/images.sh" \
  "$ROOT_DIR/install/security.sh"
do
  echo
  echo "Running $(basename "$script")..."
  bash "$script"
done

echo
echo "Bootstrap finished."
