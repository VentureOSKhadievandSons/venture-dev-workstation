# Troubleshooting

## Homebrew not found

Run `install/homebrew.sh` directly and then restart the terminal.

## pnpm global tools are missing

Check that `PNPM_HOME` is exported and included in `PATH`.

## Playwright browsers are missing

Run `install/playwright.sh` or `pnpm exec playwright install chromium firefox webkit`.

## PostgreSQL version conflicts

If another PostgreSQL version is already installed, the bootstrap will not replace it.
If you want `postgresql@17` specifically, install or link it manually after reviewing your local setup.
