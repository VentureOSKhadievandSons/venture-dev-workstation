#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

ensure_local_bin_path
command_exists pnpm || die "pnpm is required for the shared Playwright workspace."

mkdir -p "$PLAYWRIGHT_DIR/tests" "$PLAYWRIGHT_DIR/scripts" "$LOCAL_BIN_DIR"

if [[ ! -f "$PLAYWRIGHT_DIR/package.json" ]]; then
	cat >"$PLAYWRIGHT_DIR/package.json" <<'EOF'
{
  "name": "browser-qa",
  "private": true,
  "type": "module",
  "packageManager": "pnpm@11.17.0",
  "devDependencies": {
    "@playwright/mcp": "^0.0.84",
    "@playwright/test": "^1.62.1",
    "axe-playwright": "^2.2.2",
    "playwright": "^1.62.1"
  }
}
EOF
fi

cat >"$PLAYWRIGHT_DIR/playwright.config.ts" <<'EOF'
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./tests",
  timeout: 60_000,
  retries: 1,
  reporter: [["list"], ["html", { outputFolder: "playwright-report", open: "never" }]],
  use: {
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    { name: "firefox", use: { ...devices["Desktop Firefox"] } },
    { name: "webkit", use: { ...devices["Desktop Safari"] } }
  ]
});
EOF

cat >"$PLAYWRIGHT_DIR/tests/basic.spec.ts" <<'EOF'
import { expect, test } from "@playwright/test";

const target = process.env.TEST_URL ?? "https://example.com";

test("page loads successfully", async ({ page }) => {
  const response = await page.goto(target, { waitUntil: "networkidle" });
  expect(response?.ok()).toBeTruthy();
  await expect(page).toHaveTitle(/.+/);
});
EOF

cat >"$PLAYWRIGHT_DIR/scripts/browser-smoke.mjs" <<'EOF'
import { chromium } from "playwright";

const url = process.argv[2];

if (!url) {
  console.error("Usage: node browser-smoke.mjs https://example.com");
  process.exit(1);
}

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } });

try {
  const response = await page.goto(url, { waitUntil: "networkidle", timeout: 60_000 });
  console.log(JSON.stringify({
    status: response?.status() ?? null,
    title: await page.title(),
    url: page.url()
  }, null, 2));
  await page.screenshot({ path: "browser-smoke.png", fullPage: true });
} finally {
  await browser.close();
}
EOF

(
	cd "$PLAYWRIGHT_DIR"
	pnpm install
	pnpm exec playwright install chromium firefox webkit
)

ln -sfn "$ROOT_DIR/scripts/codex-browser-test" "$LOCAL_BIN_DIR/codex-browser-test"
ln -sfn "$ROOT_DIR/scripts/codex-healthcheck" "$LOCAL_BIN_DIR/codex-healthcheck"
ln -sfn "$ROOT_DIR/scripts/codex-lighthouse" "$LOCAL_BIN_DIR/codex-lighthouse"
ln -sfn "$ROOT_DIR/scripts/codex-playwright-test" "$LOCAL_BIN_DIR/codex-playwright-test"

log "Playwright workspace is ready at $PLAYWRIGHT_DIR."
