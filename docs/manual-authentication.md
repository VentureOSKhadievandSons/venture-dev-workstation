# Manual authentication

## GitHub

```bash
gh auth login
gh auth status
```

- If you use SSH, generate a new key on the new Mac:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

- Upload only the public key to GitHub.
- Do not move private SSH keys through this public repository.

## Codex

- Install/update with `install/codex.sh`.
- Confirm:

```bash
codex --version
```

- Re-authenticate inside the Codex CLI or ChatGPT desktop app.
- Do not copy `auth.json`, logs, cache, or sessions.

## Vercel

```bash
vercel --version
vercel login
```

- Re-link each project only after cloning that project locally.
- Keep `.vercel` and `.env*` out of Git.

## Cursor / VS Code / ChatGPT desktop

- Reconnect plugins and accounts through each app UI.
- Restore only reviewed settings and safe snippets.
- Do not migrate editor history, chat databases, or OAuth storage through Git.
