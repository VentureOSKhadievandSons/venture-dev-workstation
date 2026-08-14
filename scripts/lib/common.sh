#!/usr/bin/env bash
set -Eeuo pipefail

WORKSTATION_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BREWFILE_PATH="$WORKSTATION_ROOT/Brewfile"
LOCAL_STATE_DIR="$WORKSTATION_ROOT/.local"
EXPORT_STAGE_DIR="$LOCAL_STATE_DIR/export-safe-config"
RESTORE_BACKUP_DIR="$LOCAL_STATE_DIR/restore-backups"
PLAYWRIGHT_DIR="${CODEX_BROWSER_QA_DIR:-$HOME/.codex-tools/browser-qa}"
PRIVATE_OVERLAY_MANIFEST_PATH="${PRIVATE_OVERLAY_MANIFEST_PATH:-$HOME/.config/workstation-private/projects.local.yaml}"
LOCAL_BIN_DIR="$HOME/.local/bin"
PNPM_HOME_DIR="$HOME/Library/pnpm/bin"
MIN_DISK_GB="${MIN_DISK_GB:-20}"
export BREWFILE_PATH LOCAL_STATE_DIR EXPORT_STAGE_DIR RESTORE_BACKUP_DIR
export PLAYWRIGHT_DIR PRIVATE_OVERLAY_MANIFEST_PATH LOCAL_BIN_DIR PNPM_HOME_DIR MIN_DISK_GB

log() {
	printf '%s\n' "$*"
}

warn() {
	printf 'WARN: %s\n' "$*" >&2
}

die() {
	printf 'ERROR: %s\n' "$*" >&2
	exit 1
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

append_line_if_missing() {
	local file="$1"
	local line="$2"

	touch "$file"

	if ! grep -Fqx "$line" "$file"; then
		printf '%s\n' "$line" >>"$file"
	fi
}

ensure_local_bin_path() {
	mkdir -p "$LOCAL_BIN_DIR" "$PNPM_HOME_DIR"
	append_line_if_missing "$HOME/.zshenv" "export PNPM_HOME=\"\$HOME/Library/pnpm/bin\""
	append_line_if_missing "$HOME/.zshenv" "export PATH=\"\$PNPM_HOME:\$HOME/.local/bin:\$PATH\""
	export PNPM_HOME="$PNPM_HOME_DIR"
	export PATH="$PNPM_HOME:$LOCAL_BIN_DIR:$PATH"
}

brew_shellenv() {
	if [[ -x /opt/homebrew/bin/brew ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	fi
}

ensure_brew() {
	if command_exists brew; then
		brew_shellenv
		return 0
	fi

	log "Installing Homebrew..."
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	append_line_if_missing "$HOME/.zprofile" "eval \"\$(/opt/homebrew/bin/brew shellenv)\""
	brew_shellenv
}

brew_bundle_install() {
	command_exists brew || die "Homebrew is required before brew bundle install."
	brew bundle install --file "$BREWFILE_PATH" --no-lock
}

brew_bundle_check() {
	command_exists brew || return 1
	brew bundle check --file "$BREWFILE_PATH"
}

print_status_row() {
	local name="$1"
	local status="$2"
	local detail="${3:-}"

	if [[ -n "$detail" ]]; then
		printf '%-28s %-6s %s\n' "$name" "$status" "$detail"
	else
		printf '%-28s %s\n' "$name" "$status"
	fi
}

version_or_missing() {
	local binary="$1"
	shift || true

	if command_exists "$binary"; then
		"$binary" "$@"
	else
		printf 'missing\n'
	fi
}

secret_scan_regex() {
	cat <<'EOF'
(gho_[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN (RSA|OPENSSH|EC|DSA|PGP) PRIVATE KEY-----|postgres(ql)?://[^[:space:]]+:[^[:space:]]+@|redis://:[^[:space:]]+@|authorization[[:space:]]*[:=][[:space:]]*(bearer|token)|api[_-]?key[[:space:]]*[:=][[:space:]]*["'\''][^"'\'']+["'\''])
EOF
}

contains_secret_like_content() {
	local target="$1"
	rg -n -i -f /dev/stdin "$target" >/dev/null 2>&1 <<EOF
$(secret_scan_regex)
EOF
}

sanitize_stream() {
	sed \
		-e "s|$HOME|~|g" \
		-e "s|/Users/[^/[:space:]]\\+|/Users/<USER>|g" \
		-e 's/[[:cntrl:]]//g'
}

sha256_file() {
	if command_exists shasum; then
		shasum -a 256 "$1" | awk '{print $1}'
	else
		sha256sum "$1" | awk '{print $1}'
	fi
}

assert_not_root() {
	[[ "${EUID:-$(id -u)}" -ne 0 ]] || die "Run this script as a regular user, not root."
}

macos_major_version() {
	sw_vers -productVersion | awk -F. '{print $1}'
}

check_domain() {
	local domain="$1"
	curl -fsSIL --max-time 8 "https://$domain" >/dev/null 2>&1
}

list_required_domains() {
	cat <<'EOF'
api.github.com
developers.openai.com
formulae.brew.sh
github.com
registry.npmjs.org
pypi.org
vercel.com
EOF
}

show_diff_or_note() {
	local source_file="$1"
	local target_file="$2"

	if [[ -e "$target_file" ]]; then
		diff -u "$target_file" "$source_file" || true
	else
		log "Target does not exist yet: $target_file"
	fi
}
