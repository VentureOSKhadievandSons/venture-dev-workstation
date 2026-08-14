# Post-migration verification

## Workstation

Run:

```bash
./verify.sh
```

Check for:

- `arm64` architecture
- Homebrew and Brewfile packages present
- Git/GitHub CLI/Git LFS available
- Node, corepack, pnpm, Python, uv, Codex, Vercel available
- Docker, PostgreSQL, Redis available
- Browser and editor apps installed
- Safe config files in expected locations

## Project smoke tests

- For each repository in your private overlay, run the repository's own install, test, and local run commands.
- Confirm any local services required by those repositories start against local-only data.
- Verify browser QA only against approved non-production targets.

## If something fails

- Compare against the old Mac.
- Review `docs/troubleshooting.md`.
- Re-run only the narrow installer that covers the missing tool.
