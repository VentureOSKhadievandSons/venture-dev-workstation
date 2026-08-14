#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GITIGNORE_FILE="$ROOT_DIR/.gitignore"

required_patterns=(
	".env"
	".env.*"
	"auth.json"
	"credentials*"
	"secrets*"
	"*.pem"
	"*.key"
	"id_rsa*"
	"id_ed25519*"
	".vercel/"
	"manifests/projects.local.yaml"
	".local/"
)

for pattern in "${required_patterns[@]}"; do
	grep -Fqx "$pattern" "$GITIGNORE_FILE" || {
		echo "Missing .gitignore pattern: $pattern" >&2
		exit 1
	}
done
