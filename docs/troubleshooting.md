# Troubleshooting

## Homebrew not found

Run `install/homebrew.sh` directly and then restart the terminal.

## pnpm global tools are missing

Check that `PNPM_HOME` is exported and included in `PATH`.

## Playwright browsers are missing

Run `install/playwright.sh` or `pnpm exec playwright install chromium firefox webkit`.
