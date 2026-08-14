# Old Mac preparation

## Goals

- Inventory the old workstation without publishing machine-specific secrets.
- Export only safe config, examples, prompts, and instructions.
- Keep production data, tokens, and local history out of Git.

## Read-only audit

Run these locally and review the output before migration:

```bash
sw_vers
uname -m
system_profiler SPHardwareDataType
xcode-select -p
brew --version
brew bundle dump --file /tmp/Brewfile.current --force
brew leaves
brew list --cask
git --version
gh --version
gh auth status
node --version
npm --version
pnpm --version
python3 --version
uv --version
docker --version
docker compose version
psql --version
redis-cli --version
codex --version
vercel --version
```

## Safe export

```bash
./export-safe-config.sh
./export-safe-config.sh --apply --confirm
```

Review the staged output before you commit or move anything.

## Do not export through this repository

- `~/.codex/auth.json`
- Codex sessions, logs, archived conversations, attachments, caches
- Cursor and VS Code history or workspace storage
- `.env` files
- `.vercel`
- SSH private keys
- database dumps unless handled separately and privately
