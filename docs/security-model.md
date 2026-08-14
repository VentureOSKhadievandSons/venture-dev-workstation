# Security model

## Core principle

This is a public migration repository. It automates reproducible setup and holds only public-safe examples.

## Allowed in Git

- declarative package manifests
- shell scripts
- sanitized editor and Codex examples
- project manifest examples
- migration documentation

## Not allowed in Git

- passwords, API keys, tokens, cookies
- `.env` or `.env.*`
- auth stores such as `auth.json`
- SSH private keys
- private MCP configuration
- personal data
- database dumps
- local session history, logs, caches, or chat transcripts

## Export and restore model

- `export-safe-config.sh` is dry-run by default.
- It stages files only into `./.local/export-safe-config`.
- Sanitization redacts `$HOME`-style paths.
- Secret scanning runs before a text artifact is retained.
- `restore-safe-config.sh` is dry-run by default, shows diffs, and creates backups before overwrite.

## Authentication model

- GitHub, Codex, Vercel, Docker, browsers, editors, and plugins are re-authenticated manually.
- No credentials are migrated through this repository.
