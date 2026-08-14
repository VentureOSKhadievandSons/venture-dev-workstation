#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for test_script in "$ROOT_DIR"/tests/*.sh; do
	[[ "$test_script" == "$ROOT_DIR/tests/run.sh" ]] && continue
	bash "$test_script"
done
