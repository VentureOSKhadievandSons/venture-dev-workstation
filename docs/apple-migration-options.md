# Apple migration options

## Scope

Apple Migration Assistant, Time Machine restore, and iCloud sync can reduce setup time, but they do not replace the public-safe bootstrap in this repository.

## Migration Assistant / Time Machine

- Useful for large app bundles, local caches, and non-sensitive convenience data.
- Treat the result as a starting point, not as proof that development tooling is correct.
- Re-run `./preflight.sh`, `./bootstrap.sh`, and `./verify.sh` after the new Mac is available.

## iCloud

- Suitable for private overlay data, notes, and reviewed personal templates that stay outside public Git.
- Keep real project manifests and exported safe config in private iCloud locations if you do not use a private overlay repository.

## Still manual after any Apple-assisted migration

- GitHub, Codex, Vercel, Docker, and editor re-authentication
- SSH key generation and public key upload
- validation of local databases and local-only service data
- smoke tests for priority repositories

Do not assume Apple migration tools make credential transfer safe for public version control.
