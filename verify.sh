#!/usr/bin/env bash
set -Eeuo pipefail

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
check_command "Google Chrome" open
check_command "Playwright" playwright
check_command "Lighthouse" lighthouse
check_command "TypeScript" tsc
check_command "ESLint" eslint
check_command "Prettier" prettier
