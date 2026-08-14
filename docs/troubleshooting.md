# Troubleshooting

## Homebrew install failed

- Confirm `xcode-select -p` works.
- Re-run `./preflight.sh`.
- Run `install/homebrew.sh` directly.

## Brewfile check warns about missing packages

- Run `brew bundle install --file Brewfile --no-lock`.
- Re-run `./verify.sh`.

## `pnpm` or global CLI are missing

- Confirm `~/.zshenv` exports `PNPM_HOME` and `PATH`.
- Open a new shell.
- Run `install/node.sh`, then `install/vercel.sh` or `install/codex.sh` if needed.

## Codex CLI installed but not authenticated

- Run `codex --version` to confirm the binary exists.
- Re-authenticate manually following `docs/manual-authentication.md`.
- Do not copy `auth.json` or session history from the old Mac.

## GitHub CLI is not authenticated

- Run `gh auth login`.
- If you use SSH, generate a new key on the new Mac and upload only the public key to GitHub.

## Docker CLI exists but Docker Desktop is not ready

- Open Docker Desktop once and complete any first-run prompts.
- Re-run `docker --version` and `docker compose version`.

## PostgreSQL or Redis service state is wrong

- Inspect with `brew services list`.
- Start explicitly with `brew services start postgresql@17` and `brew services start redis`.
- Keep production data migration separate from this repository.

## Playwright browsers are missing

- Run `install/playwright.sh`.
- Verify `~/Library/Caches/ms-playwright` exists.

## Secret scan fails

- Run `scripts/check-no-secrets`.
- Remove or redact offending content before commit.
- Never suppress a real credential finding inside this public repository.

## Project manifest location is wrong

- Keep real project manifests outside this repository.
- Use a private overlay repository or a local/iCloud path such as `~/.config/workstation-private/projects.local.yaml`.
- Re-run `scripts/clone-projects --manifest <PRIVATE_MANIFEST_PATH>`.
