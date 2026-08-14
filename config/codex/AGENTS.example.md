# Global Agent Notes

## Safe Defaults

- Work inside the current repository unless explicitly told otherwise.
- Never commit secrets, tokens, `.env` files, auth stores, session history, or database dumps.
- Prefer reproducible project commands that already exist in the repository.
- Ask before destructive actions such as deleting files, resetting Git state, or overwriting local databases.

## Default Checks

- Run the smallest verification command that proves the change.
- Prefer local project package managers (`uv`, `pnpm`, `npm`) over ad-hoc global installs.
- Keep machine-specific paths out of shared instructions.
