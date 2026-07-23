#!/usr/bin/env bash
set -Eeuo pipefail

WORKSPACE_DIR="$HOME/.codex-tools/browser-qa"

echo "Preparing Playwright workspace..."

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm is required. Run install/node.sh first."
  exit 1
fi

mkdir -p "$WORKSPACE_DIR/tests" "$WORKSPACE_DIR/scripts"

if [[ ! -f "$WORKSPACE_DIR/package.json" ]]; then
  cat >"$WORKSPACE_DIR/package.json" <<'EOF'
{
  "name": "browser-qa",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "devEngines": {
    "packageManager": {
      "name": "pnpm",
      "version": "^11.17.0",
      "onFail": "download"
    }
  },
  "devDependencies": {
    "@playwright/mcp": "^0.0.78",
    "@playwright/test": "^1.61.1",
    "axe-playwright": "^2.2.2",
    "playwright": "^1.61.1"
  }
}
EOF
fi

cat >"$WORKSPACE_DIR/playwright.config.ts" <<'EOF'
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./tests",
  timeout: 60_000,
  expect: {
    timeout: 10_000,
  },
  fullyParallel: false,
  retries: 1,
  reporter: [
    ["list"],
    ["html", { outputFolder: "playwright-report", open: "never" }],
  ],
  use: {
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
    {
      name: "firefox",
      use: { ...devices["Desktop Firefox"] },
    },
    {
      name: "webkit",
      use: { ...devices["Desktop Safari"] },
    },
  ],
});
EOF

cat >"$WORKSPACE_DIR/tests/basic.spec.ts" <<'EOF'
import { expect, test } from "@playwright/test";

const target =
  process.env.TEST_URL ??
  "https://turkey-real-estate-site.vercel.app/ru/";

test("page loads successfully", async ({ page }) => {
  const response = await page.goto(target, {
    waitUntil: "networkidle",
  });

  expect(response?.ok()).toBeTruthy();
  await expect(page).toHaveTitle(/.+/);
});
EOF

cat >"$WORKSPACE_DIR/scripts/browser-smoke.mjs" <<'EOF'
import { chromium } from "playwright";

const url = process.argv[2];

if (!url) {
  console.error("Usage: node browser-smoke.mjs https://example.com");
  process.exit(1);
}

const browser = await chromium.launch({
  headless: true,
});

const context = await browser.newContext({
  viewport: { width: 1440, height: 1000 },
  ignoreHTTPSErrors: false,
});

const page = await context.newPage();
const consoleErrors = [];
const failedRequests = [];
const analyticsRequests = [];

page.on("console", (message) => {
  if (message.type() === "error") {
    consoleErrors.push(message.text());
  }
});

page.on("request", (request) => {
  const requestUrl = request.url();

  if (
    requestUrl.includes("googletagmanager.com") ||
    requestUrl.includes("google-analytics.com") ||
    requestUrl.includes("mc.yandex.ru")
  ) {
    analyticsRequests.push(requestUrl);
  }
});

page.on("requestfailed", (request) => {
  failedRequests.push({
    url: request.url(),
    error: request.failure()?.errorText ?? "unknown",
  });
});

try {
  const response = await page.goto(url, {
    waitUntil: "networkidle",
    timeout: 60_000,
  });

  await page.waitForTimeout(2_000);

  const runtime = await page.evaluate(() => ({
    title: document.title,
    url: location.href,
    dataLayerExists: Array.isArray(window.dataLayer),
    dataLayerLength: Array.isArray(window.dataLayer)
      ? window.dataLayer.length
      : null,
    yandexMetrikaExists: typeof window.ym === "function",
    gtmScripts: [...document.scripts]
      .map((script) => script.src)
      .filter((src) => src.includes("googletagmanager.com")),
    yandexScripts: [...document.scripts]
      .map((script) => script.src)
      .filter((src) => src.includes("mc.yandex.ru")),
  }));

  const result = {
    status: response?.status() ?? null,
    ...runtime,
    analyticsRequests: [...new Set(analyticsRequests)],
    consoleErrors,
    failedRequests,
  };

  console.log(JSON.stringify(result, null, 2));

  await page.screenshot({
    path: "browser-smoke.png",
    fullPage: true,
  });
} finally {
  await browser.close();
}
EOF

cd "$WORKSPACE_DIR"

pnpm install
pnpm add -D playwright @playwright/test @playwright/mcp axe-playwright
pnpm exec playwright install chromium firefox webkit

echo "Playwright workspace is ready at $WORKSPACE_DIR."
