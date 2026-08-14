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

- Next.js and Vercel projects: install deps, run dev/build/test flows, verify browser QA.
- FastAPI projects: `uv sync`, run unit tests, confirm PostgreSQL and Redis connectivity.
- Dockerized services: `docker compose up` for local stacks only.

## If something fails

- Compare against the old Mac.
- Review `docs/troubleshooting.md`.
- Re-run only the narrow installer that covers the missing tool.
