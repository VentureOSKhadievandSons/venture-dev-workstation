#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting workstation bootstrap..."
echo
bash "$ROOT_DIR/preflight.sh"

for script in \
	"$ROOT_DIR/install/homebrew.sh" \
	"$ROOT_DIR/install/python.sh" \
	"$ROOT_DIR/install/node.sh" \
	"$ROOT_DIR/install/github.sh" \
	"$ROOT_DIR/install/codex.sh" \
	"$ROOT_DIR/install/vercel.sh" \
	"$ROOT_DIR/install/docker.sh" \
	"$ROOT_DIR/install/databases.sh" \
	"$ROOT_DIR/install/playwright.sh"; do
	echo
	echo "Running $(basename "$script")..."
	bash "$script"
done

echo
echo "Bootstrap finished."
