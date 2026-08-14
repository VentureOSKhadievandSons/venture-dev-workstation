#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
	"Brewfile"
	"preflight.sh"
	"bootstrap.sh"
	"update.sh"
	"verify.sh"
	"export-safe-config.sh"
	"restore-safe-config.sh"
	"config/codex/config.toml.example"
	"config/codex/AGENTS.example.md"
	"config/cursor/settings.json.example"
	"config/cursor/mcp.json.example"
	"config/vscode/settings.json.example"
	"manifests/projects.example.yaml"
	"docs/migration-checklist.md"
	"docs/old-mac-preparation.md"
	"docs/new-mac-bootstrap.md"
	"docs/post-migration-verification.md"
	"docs/manual-authentication.md"
	"docs/template-journal-migration.md"
	"docs/private-overlay.md"
	"docs/apple-migration-options.md"
	"docs/security-model.md"
	"tests/check-public-surface.sh"
)

for path in "${required[@]}"; do
	[[ -e "$ROOT_DIR/$path" ]] || {
		echo "Missing required path: $path" >&2
		exit 1
	}
done
