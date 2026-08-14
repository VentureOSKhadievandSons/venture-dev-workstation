#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

DRY_RUN=1
CONFIRM=0

usage() {
	cat <<'EOF'
Usage: ./export-safe-config.sh [--apply] [--confirm]

Dry-run is the default. The script stages sanitized config into ./.local/export-safe-config
and writes a manifest with SHA-256 checksums. It never exports auth.json, tokens, logs,
sessions, caches, database dumps, or private keys.
Do not commit exported configuration, project manifests, credentials, or migration archives.
EOF
}

assert_export_stage_is_local_only() {
	local tracked_entries

	[[ "$EXPORT_STAGE_DIR" == "$ROOT_DIR/.local/export-safe-config" ]] || {
		die "EXPORT_STAGE_DIR must stay at $ROOT_DIR/.local/export-safe-config"
	}

	git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
		die "This script must run inside the workstation Git repository."
	}

	tracked_entries="$(git -C "$ROOT_DIR" ls-files -- .local)"
	[[ -z "$tracked_entries" ]] || {
		die ".local contains tracked files. Refusing to write exported configuration."
	}

	git -C "$ROOT_DIR" check-ignore -q -- .local || {
		die ".local is not ignored by Git. Refusing to write exported configuration."
	}

	git -C "$ROOT_DIR" check-ignore -q -- .local/export-safe-config || {
		die ".local/export-safe-config is not ignored by Git. Refusing to write exported configuration."
	}
}

sanitize_codex_config() {
	local source_file="$1"
	local target_file="$2"

	awk '
    /^\[projects\./ {skip=1; next}
    /^\[model_providers\./ {skip=1; next}
    /^\[marketplaces\./ {skip=1; next}
    /^\[mcp_servers\./ {skip=1; next}
    /^\[shell_environment_policy\./ {skip=1; next}
    /^\[/ {skip=0}
    skip {next}
    /^notify[[:space:]]*=/ {next}
    /^service_tier[[:space:]]*=/ {next}
    /^model_provider[[:space:]]*=/ {next}
    /^BROWSER_USE_/ {next}
    /^NODE_REPL_/ {next}
    /^CODEX_/ {next}
    {print}
  ' "$source_file" | sanitize_stream >"$target_file"
}

sanitize_json_file() {
	local source_file="$1"
	local target_file="$2"
	sanitize_stream <"$source_file" >"$target_file"
}

copy_text_file() {
	local source_file="$1"
	local target_file="$2"

	sanitize_stream <"$source_file" >"$target_file"
	if contains_secret_like_content "$target_file"; then
		rm -f "$target_file"
		warn "Skipped secret-like file: $source_file"
		return 1
	fi
}

stage_file() {
	local source_file="$1"
	local target_file="$2"
	local mode="$3"

	mkdir -p "$(dirname "$target_file")"

	case "$mode" in
	codex-config) sanitize_codex_config "$source_file" "$target_file" ;;
	json) sanitize_json_file "$source_file" "$target_file" ;;
	text) copy_text_file "$source_file" "$target_file" ;;
	*) die "Unknown export mode: $mode" ;;
	esac
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--apply)
		DRY_RUN=0
		shift
		;;
	--confirm)
		CONFIRM=1
		shift
		;;
	--help | -h)
		usage
		exit 0
		;;
	*)
		die "Unknown argument: $1"
		;;
	esac
done

assert_export_stage_is_local_only
warn "Do not commit exported configuration, project manifests, credentials, or migration archives."

if ((DRY_RUN == 0)); then
	((CONFIRM == 1)) || die "Refusing to write export staging without --confirm."
	mkdir -p "$EXPORT_STAGE_DIR"
	find "${EXPORT_STAGE_DIR:?}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
fi

declare -a entries=(
	"$HOME/.codex/config.toml|$EXPORT_STAGE_DIR/codex/config.toml.safe|codex-config"
	"$HOME/.cursor/mcp.json|$EXPORT_STAGE_DIR/cursor/mcp.json.safe|json"
	"$HOME/.zshrc|$EXPORT_STAGE_DIR/shell/.zshrc.safe|text"
	"$HOME/.zprofile|$EXPORT_STAGE_DIR/shell/.zprofile.safe|text"
	"$HOME/.zshenv|$EXPORT_STAGE_DIR/shell/.zshenv.safe|text"
)

for entry in "${entries[@]}"; do
	IFS='|' read -r source_file target_file mode <<<"$entry"
	if [[ -f "$source_file" ]]; then
		log "stage $source_file -> $target_file"
		if ((DRY_RUN == 0)); then
			stage_file "$source_file" "$target_file" "$mode"
		fi
	else
		warn "Missing optional file: $source_file"
	fi
done

for skill_root in "$HOME/.agents/skills" "$HOME/.codex/skills"; do
	if [[ -d "$skill_root" ]]; then
		while IFS= read -r file; do
			rel="${file#"$HOME"/}"
			target="$EXPORT_STAGE_DIR/skills/$rel"
			log "candidate skill file $file"
			if ((DRY_RUN == 0)); then
				mkdir -p "$(dirname "$target")"
				copy_text_file "$file" "$target" || true
			fi
		done < <(find "$skill_root" \
			\( -path "$HOME/.codex/skills/.system" -o -path "$HOME/.codex/skills/.system/*" -o -path "$HOME/.codex/skills/cache" -o -path "$HOME/.codex/skills/cache/*" \) -prune \
			-o \( -name 'AGENTS.md' -o -name 'SKILL.md' -o -name '*.md' -o -name '*.txt' -o -name '*.yaml' -o -name '*.yml' -o -name '*.json' \) -type f -print)
	fi
done

if ((DRY_RUN == 1)); then
	log "Dry-run complete. Re-run with --apply --confirm to write sanitized files."
	exit 0
fi

manifest_file="$EXPORT_STAGE_DIR/manifest.txt"
: >"$manifest_file"

while IFS= read -r file; do
	[[ -f "$file" ]] || continue
	printf '%s  %s\n' "$(sha256_file "$file")" "${file#"$EXPORT_STAGE_DIR"/}" >>"$manifest_file"
done < <(find "$EXPORT_STAGE_DIR" -type f ! -name manifest.txt | sort)

log "Export staging written to $EXPORT_STAGE_DIR"
log "Manifest written to $manifest_file"
