# Security model

## Core principle

This is a public migration repository. It automates reproducible setup and holds only public-safe examples.

## Allowed in Git

- declarative package manifests
- shell scripts
- sanitized editor and Codex examples
- fictional manifest examples
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
- It refuses to write if the staging directory is not ignored or if any `.local` content is tracked by Git.
- Sanitization redacts `$HOME`-style paths.
- Secret scanning runs before a text artifact is retained.
- `restore-safe-config.sh` is dry-run by default, shows diffs, and creates backups before overwrite.
- Do not commit exported configuration, project manifests, credentials, or migration archives.

## Authentication model

- GitHub, Codex, Vercel, Docker, browsers, editors, and plugins are re-authenticated manually.
- No credentials are migrated through this repository.
