# Template journal migration

## Likely source locations

### A. Already synced elsewhere

- `~/Library/Application Support/Cursor/User/settings.json`
- `~/Library/Application Support/Cursor/User/snippets/`
- `~/Library/Application Support/Code/User/settings.json`
- `~/Library/Application Support/Code/User/snippets/`
- iCloud-backed files under `~/Library/Mobile Documents/` when they already exist there

### B. Local and worth reviewing for safe export

- `~/.codex/config.toml`
- `~/.cursor/mcp.json`
- `~/.zshrc`, `~/.zprofile`, `~/.zshenv`
- user-created `AGENTS.md`, prompts, templates, and skill files in `~/Developer` and `~/Documents`

### C. Contains secrets or history and must not go into public Git

- `~/.codex/auth.json`
- `~/.codex/archived_sessions/`, `attachments/`, `logs/`, `ambient-suggestions/`
- Cursor and VS Code `History/`, `workspaceStorage/`, `globalStorage/`, chat databases, OAuth attempts

### D. Better moved via private repository or private workspace

- internal prompt libraries
- internal template journals
- documents with customer data or internal URLs
- private skills or plugins that mention credentials, private hosts, or personal paths

## Recommended migration plan

1. Export safe config with `./export-safe-config.sh --apply --confirm`.
2. Review every staged file manually.
3. Move internal prompt/template collections into a private overlay repository or another private knowledge store.
4. Reconnect public-safe snippets and templates on the new Mac only after review.
