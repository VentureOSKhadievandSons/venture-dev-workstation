#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

supported_macos() {
	local major
	major="$(macos_major_version)"
	[[ "$major" -ge 12 ]]
}

has_free_space() {
	local available_kb
	available_kb="$(df -Pk "$HOME" | awk 'NR==2 {print $4}')"
	[[ -n "$available_kb" ]] || return 1
	((available_kb >= MIN_DISK_GB * 1024 * 1024))
}

check_connectivity() {
	local failures=0
	local domain

	while IFS= read -r domain; do
		[[ -n "$domain" ]] || continue
		if check_domain "$domain"; then
			print_status_row "domain:$domain" "PASS"
		else
			print_status_row "domain:$domain" "WARN"
			failures=$((failures + 1))
		fi
	done < <(list_required_domains)

	return "$failures"
}

echo "Preflight checks"
echo
printf '%-28s %-6s %s\n' "Check" "State" "Detail"
printf '%-28s %-6s %s\n' "-----" "-----" "------"

assert_not_root
print_status_row "not-root" "PASS"

if supported_macos; then
	print_status_row "macOS version" "PASS" "$(sw_vers -productVersion)"
else
	print_status_row "macOS version" "FAIL" "$(sw_vers -productVersion)"
	exit 1
fi

if [[ "$(uname -m)" == "arm64" ]]; then
	print_status_row "architecture" "PASS" "arm64"
else
	print_status_row "architecture" "FAIL" "$(uname -m)"
	exit 1
fi

if xcode-select -p >/dev/null 2>&1; then
	print_status_row "Command Line Tools" "PASS" "$(xcode-select -p)"
else
	print_status_row "Command Line Tools" "FAIL" "Run xcode-select --install"
	exit 1
fi

if has_free_space; then
	print_status_row "free disk" "PASS" ">= ${MIN_DISK_GB} GB"
else
	print_status_row "free disk" "FAIL" "< ${MIN_DISK_GB} GB"
	exit 1
fi

if [[ -d "$HOME" && -w "$HOME" ]]; then
	print_status_row "home directory" "PASS" "$HOME"
else
	print_status_row "home directory" "FAIL" "$HOME"
	exit 1
fi

if command_exists brew; then
	print_status_row "Homebrew" "PASS" "$(brew --version | head -n 1)"
else
	print_status_row "Homebrew" "WARN" "bootstrap will install it"
fi

if command_exists git; then
	print_status_row "Git" "PASS" "$(git --version)"
else
	print_status_row "Git" "FAIL" "git is required"
	exit 1
fi

if check_connectivity; then
	:
else
	warn "Some domains were unreachable. Bootstrap may still proceed, but package installs can fail."
fi

echo
log "Rosetta 2 is not installed automatically here. Install it only if a required tool has no Apple Silicon build."
