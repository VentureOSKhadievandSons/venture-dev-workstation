#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

DRY_RUN=1
FORCE=0
SOURCE_DIR="${1:-$EXPORT_STAGE_DIR}"

usage() {
	cat <<'EOF'
Usage: ./restore-safe-config.sh [SOURCE_DIR] [--apply] [--force]

Dry-run is the default. Existing files are backed up before overwrite, and
diffs are shown for each target. Only sanitized safe-config artifacts are restored.
EOF
}

if [[ $# -gt 0 && "$1" == -* ]]; then
	SOURCE_DIR="$EXPORT_STAGE_DIR"
fi

while [[ $# -gt 0 ]]; do
	case "$1" in
	--apply)
		DRY_RUN=0
		shift
		;;
	--force)
		FORCE=1
		shift
		;;
	--help | -h)
		usage
		exit 0
		;;
	*)
		if [[ -d "$1" ]]; then
			SOURCE_DIR="$1"
			shift
		else
			die "Unknown argument: $1"
		fi
		;;
	esac
done

[[ -d "$SOURCE_DIR" ]] || die "Source directory does not exist: $SOURCE_DIR"

timestamp="$(date +%Y%m%d-%H%M%S)"
backup_root="$RESTORE_BACKUP_DIR/$timestamp"
mkdir -p "$backup_root"

map_target() {
	case "$1" in
	codex/config.toml.safe) printf '%s\n' "$HOME/.codex/config.toml" ;;
	cursor/mcp.json.safe) printf '%s\n' "$HOME/.cursor/mcp.json" ;;
	shell/.zshrc.safe) printf '%s\n' "$HOME/.zshrc" ;;
	shell/.zprofile.safe) printf '%s\n' "$HOME/.zprofile" ;;
	shell/.zshenv.safe) printf '%s\n' "$HOME/.zshenv" ;;
	skills/*) printf '%s\n' "$HOME/${1#skills/}" ;;
	*) return 1 ;;
	esac
}

while IFS= read -r source_file; do
	rel="${source_file#"$SOURCE_DIR"/}"
	target_file="$(map_target "$rel")" || {
		warn "Skipping unmapped file: $rel"
		continue
	}

	log "restore $rel -> $target_file"
	show_diff_or_note "$source_file" "$target_file"

	if ((DRY_RUN == 1)); then
		continue
	fi

	if [[ -e "$target_file" ]]; then
		mkdir -p "$backup_root/$(dirname "${target_file#"$HOME"/}")"
		cp "$target_file" "$backup_root/${target_file#"$HOME"/}"
		if ((FORCE == 0)); then
			warn "Skipping existing file without --force: $target_file"
			continue
		fi
	fi

	mkdir -p "$(dirname "$target_file")"
	cp "$source_file" "$target_file"
done < <(find "$SOURCE_DIR" -type f ! -name manifest.txt | sort)

if ((DRY_RUN == 1)); then
	log "Dry-run complete. Re-run with --apply to restore files."
else
	log "Restore complete. Backups stored in $backup_root"
fi
