#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

failures=0
warnings=0
checks=0

report() {
	local name="$1"
	local level="$2"
	local detail="$3"

	checks=$((checks + 1))
	print_status_row "$name" "$level" "$detail"

	case "$level" in
	FAIL) failures=$((failures + 1)) ;;
	WARN) warnings=$((warnings + 1)) ;;
	esac
}

check_required_command() {
	local label="$1"
	local command_name="$2"
	shift 2
	local version_args=("$@")

	if [[ ${#version_args[@]} -eq 0 ]]; then
		version_args=(--version)
	fi

	if command_exists "$command_name"; then
		report "$label" "PASS" "$("$command_name" "${version_args[@]}" 2>&1 | head -n 1)"
	else
		report "$label" "FAIL" "missing"
	fi
}

check_optional_command() {
	local label="$1"
	local command_name="$2"
	shift 2
	local version_args=("$@")

	if [[ ${#version_args[@]} -eq 0 ]]; then
		version_args=(--version)
	fi

	if command_exists "$command_name"; then
		report "$label" "PASS" "$("$command_name" "${version_args[@]}" 2>&1 | head -n 1)"
	else
		report "$label" "WARN" "missing"
	fi
}

check_path() {
	local label="$1"
	local target="$2"

	if [[ -e "$target" ]]; then
		report "$label" "PASS" "$target"
	else
		report "$label" "WARN" "$target"
	fi
}

check_brew_bundle() {
	if brew_bundle_check >/dev/null 2>&1; then
		report "Brew bundle" "PASS" "all declared packages present"
	else
		report "Brew bundle" "WARN" "run brew bundle install --file Brewfile"
	fi
}

check_architecture() {
	if [[ "$(uname -m)" == "arm64" ]]; then
		report "Architecture" "PASS" "arm64"
	else
		report "Architecture" "FAIL" "$(uname -m)"
	fi
}

check_gh_auth() {
	if command_exists gh; then
		if gh auth status >/dev/null 2>&1; then
			report "GitHub auth" "PASS" "authenticated"
		else
			report "GitHub auth" "WARN" "run gh auth login"
		fi
	else
		report "GitHub auth" "FAIL" "gh missing"
	fi
}

check_git_lfs() {
	if command_exists git && git lfs version >/dev/null 2>&1; then
		report "Git LFS" "PASS" "$(git lfs version)"
	else
		report "Git LFS" "FAIL" "missing"
	fi
}

check_codex() {
	if command_exists codex; then
		report "Codex" "PASS" "$(codex --version 2>/dev/null | head -n 1)"
	else
		report "Codex" "FAIL" "missing"
	fi
}

check_brew_service() {
	local label="$1"
	local formula="$2"

	if ! command_exists brew; then
		report "$label service" "WARN" "brew missing"
		return 0
	fi

	local status
	status="$(brew services list 2>/dev/null | awk -v name="$formula" '$1 == name {print $2}')"
	if [[ "$status" == "started" ]]; then
		report "$label service" "PASS" "started"
	elif [[ -n "$status" ]]; then
		report "$label service" "WARN" "$status"
	else
		report "$label service" "WARN" "not registered"
	fi
}

check_playwright_workspace() {
	if [[ -f "$PLAYWRIGHT_DIR/package.json" ]]; then
		report "Playwright workspace" "PASS" "$PLAYWRIGHT_DIR"
	else
		report "Playwright workspace" "WARN" "$PLAYWRIGHT_DIR"
	fi
}

check_playwright_browsers() {
	if [[ -d "$HOME/Library/Caches/ms-playwright" ]]; then
		report "Playwright browsers" "PASS" "$HOME/Library/Caches/ms-playwright"
	else
		report "Playwright browsers" "WARN" "run install/playwright.sh"
	fi
}

check_codex_config() {
	check_path "Codex config" "$HOME/.codex/config.toml"
	check_path "Codex skills dir" "$HOME/.codex/skills"
}

check_editor_configs() {
	check_path "Cursor settings" "$HOME/Library/Application Support/Cursor/User/settings.json"
	check_path "VS Code settings" "$HOME/Library/Application Support/Code/User/settings.json"
}

echo "Environment verification"
echo
printf '%-28s %-6s %s\n' "Check" "State" "Detail"
printf '%-28s %-6s %s\n' "-----" "-----" "------"

check_architecture
report "macOS" "PASS" "$(sw_vers -productVersion)"
check_required_command "Homebrew" brew
check_brew_bundle
check_required_command "Git" git
check_gh_auth
check_git_lfs
check_required_command "Node.js" node
check_required_command "corepack" corepack
check_required_command "pnpm" pnpm
check_required_command "npm" npm
check_required_command "Python 3" python3
check_required_command "uv" uv
check_optional_command "pipx" pipx
check_codex
check_required_command "Docker" docker
check_required_command "Docker Compose" docker compose version
check_required_command "PostgreSQL" psql
check_required_command "Redis CLI" redis-cli
check_brew_service "PostgreSQL" "postgresql@17"
check_brew_service "Redis" "redis"
check_required_command "Vercel" vercel
check_optional_command "Playwright CLI" playwright
check_required_command "ripgrep" rg
check_required_command "jq" jq
check_required_command "fd" fd
check_required_command "fzf" fzf
check_required_command "ImageMagick" magick
check_required_command "ffmpeg" ffmpeg -version
check_required_command "shellcheck" shellcheck
check_required_command "shfmt" shfmt --version
check_optional_command "gitleaks" gitleaks version
check_path "Docker Desktop app" "/Applications/Docker.app"
check_path "Cursor app" "/Applications/Cursor.app"
check_path "VS Code app" "/Applications/Visual Studio Code.app"
check_path "Chrome app" "/Applications/Google Chrome.app"
check_path "Firefox app" "/Applications/Firefox.app"
check_path "ChatGPT app" "/Applications/ChatGPT.app"
check_playwright_workspace
check_playwright_browsers
check_codex_config
check_editor_configs
check_path "Zsh rc" "$HOME/.zshrc"
check_path "Zprofile" "$HOME/.zprofile"
check_path "Zshenv" "$HOME/.zshenv"

if [[ ":$PATH:" == *":$LOCAL_BIN_DIR:"* ]]; then
	report "PATH contains local bin" "PASS" "$LOCAL_BIN_DIR"
else
	report "PATH contains local bin" "WARN" "$LOCAL_BIN_DIR"
fi

echo
printf 'Summary: %s PASS, %s WARN, %s FAIL\n' "$((checks - warnings - failures))" "$warnings" "$failures"

if ((failures > 0)); then
	exit 1
fi
