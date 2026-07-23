#!/usr/bin/env bash
set -Eeuo pipefail

PLAYWRIGHT_DIR="$HOME/.codex-tools/browser-qa"

print_result() {
  local name="$1"
  local status="$2"

  printf '%-28s %s\n' "$name" "$status"
}

check_command() {
  local label="$1"
  local command_name="$2"

  if command -v "$command_name" >/dev/null 2>&1; then
    print_result "$label" "PASS"
  else
    print_result "$label" "FAIL"
  fi
}

check_path() {
  local label="$1"
  local target_path="$2"

  if [[ -e "$target_path" ]]; then
    print_result "$label" "PASS"
  else
    print_result "$label" "FAIL"
  fi
}

check_playwright_workspace() {
  if [[ -f "$PLAYWRIGHT_DIR/package.json" ]] && [[ -f "$PLAYWRIGHT_DIR/tests/basic.spec.ts" ]]; then
    print_result "Playwright workspace" "PASS"
  else
    print_result "Playwright workspace" "FAIL"
  fi
}

check_playwright_browsers() {
  if [[ -d "$HOME/Library/Caches/ms-playwright" ]]; then
    print_result "Playwright browsers" "PASS"
  else
    print_result "Playwright browsers" "FAIL"
  fi
}

echo "Environment verification"
echo
printf '%-28s %s\n' "Check" "Result"
printf '%-28s %s\n' "-----" "------"

check_command "Homebrew" brew
check_command "Node.js" node
check_command "pnpm" pnpm
check_command "GitHub CLI" gh
check_command "Vercel CLI" vercel
check_command "Docker" docker
check_command "PostgreSQL" psql
check_command "Redis" redis-cli
check_path "Docker Desktop app" "/Applications/Docker.app"
check_path "Google Chrome app" "/Applications/Google Chrome.app"
check_playwright_workspace
check_playwright_browsers
check_command "Lighthouse" lighthouse
check_command "TypeScript" tsc
check_command "ESLint" eslint
check_command "Prettier" prettier
check_command "codex-browser-test" codex-browser-test
check_command "codex-lighthouse" codex-lighthouse
check_command "codex-playwright-test" codex-playwright-test
