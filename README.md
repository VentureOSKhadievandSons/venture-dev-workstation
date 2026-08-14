# venture-dev-workstation

Declarative, repeatable workstation setup for migrating from an existing Apple Silicon Mac to a new Apple Silicon MacBook Pro without publishing secrets.

## Security rules

- Never commit passwords, API keys, tokens, cookies, `.env` files, auth stores, private SSH keys, database dumps, or local session history.
- This repository only stores public-safe examples and automation.
- Account login, keychain items, SSH private keys, Vercel project links, `.vercel`, and Codex auth state are re-created manually on the new Mac.
- Do not commit exported configuration, project manifests, credentials, or migration archives.

## Repository layout

- `Brewfile`: declarative Homebrew formulas and casks.
- `preflight.sh`: validates macOS, arm64, disk, CLT, network, and home directory readiness.
- `bootstrap.sh`: orchestrates workstation setup.
- `update.sh`: refreshes Brewfile packages, shared CLI tools, and Playwright browsers.
- `verify.sh`: prints a PASS/WARN/FAIL workstation report.
- `export-safe-config.sh`: stages sanitized user config into `./.local/export-safe-config`.
- `restore-safe-config.sh`: previews and restores only safe config artifacts.
- `install/`: idempotent installers for Homebrew, Python, Node, GitHub, Codex, Vercel, Docker, databases, and Playwright.
- `config/`: sanitized example config for Codex, Cursor, and VS Code.
- `manifests/`: fictional manifest examples only.
- `scripts/`: helper commands and validation utilities.
- `tests/`: repository structure and policy checks.
- `docs/`: migration playbooks and troubleshooting.

## Migration flow

### Stage A: old Mac

1. Run a local workstation audit.
2. Review `docs/old-mac-preparation.md`.
3. Run `./export-safe-config.sh --apply --confirm`.
4. Review staged artifacts in `./.local/export-safe-config`.
5. Verify critical repositories before migration.
6. Push this repository after reviewing changes.

### Stage B: new MacBook Pro

1. Update macOS and install Command Line Tools.
2. Clone this repository.
3. Run `./preflight.sh`.
4. Run `./bootstrap.sh`.
5. Re-authenticate GitHub, Codex, Vercel, Docker, browsers, and other apps.
6. Restore reviewed safe config with `./restore-safe-config.sh --apply --force`.
7. Point `scripts/clone-projects` at a private overlay manifest stored outside this repository.
8. Run `./verify.sh`.
9. Smoke-test the highest priority repositories.

## Quick start on a new Mac

```bash
git clone <PUBLIC_REPO_URL>
cd <PUBLIC_REPO_DIR>
chmod +x \
  bootstrap.sh \
  preflight.sh \
  update.sh \
  verify.sh \
  export-safe-config.sh \
  restore-safe-config.sh \
  install/*.sh \
  scripts/*
./preflight.sh
./bootstrap.sh
./verify.sh
```

## What gets installed

- Homebrew-managed CLI: Git, GitHub CLI, Git LFS, jq, yq, ripgrep, fd, fzf, tree, watch, wget, age, gnupg, shellcheck, shfmt, pre-commit, uv, PostgreSQL, Redis, ImageMagick, ffmpeg, Node.
- Homebrew casks: Docker Desktop, Cursor, Visual Studio Code, Google Chrome, Firefox, ChatGPT.
- Shared global CLI only where useful across repositories: Codex CLI, Vercel CLI, TypeScript, tsx, ESLint, Prettier, Lighthouse, npm-check-updates.
- Shared Playwright QA workspace at `~/.codex-tools/browser-qa`.

## What does not get migrated automatically

- `~/.codex/auth.json`, sessions, logs, caches, attachments, archived conversations.
- Cursor or VS Code history, workspace storage, chat databases, OAuth state.
- `.env` files, `.vercel`, local secrets, cookies, SSH private keys, or database dumps.
- Project-specific dependencies better kept in each project’s `package.json` or `pyproject.toml`.
- Real project manifests, private overlays, and migration archives belong outside this repository.

## Daily helpers

After `./bootstrap.sh`, these commands are linked into `~/.local/bin`:

```bash
codex-browser-test https://example.com
TEST_URL=https://example.com codex-playwright-test
codex-lighthouse https://example.com
codex-healthcheck
```

## Codex and authentication

- Codex CLI install/update is handled with `npm install -g @openai/codex`, matching the official CLI quickstart: <https://developers.openai.com/codex/cli>
- Re-authentication is manual on the new Mac.
- Keep only sanitized examples in `config/codex/`.

## Documentation

Public base:
- [Migration checklist](docs/migration-checklist.md)
- [Old Mac preparation](docs/old-mac-preparation.md)
- [New Mac bootstrap](docs/new-mac-bootstrap.md)
- [Post-migration verification](docs/post-migration-verification.md)
- [Manual authentication](docs/manual-authentication.md)
- [Template journal migration](docs/template-journal-migration.md)
- [Security model](docs/security-model.md)
- [Troubleshooting](docs/troubleshooting.md)

Private overlay:
- [Private overlay model](docs/private-overlay.md)

Apple Migration Assistant / Time Machine / iCloud:
- [Apple migration options](docs/apple-migration-options.md)
