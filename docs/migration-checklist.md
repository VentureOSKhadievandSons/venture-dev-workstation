# Migration checklist

## Stage A: old Mac

1. Verify `git status` is clean in this repository.
2. Review `docs/old-mac-preparation.md`.
3. Run `./export-safe-config.sh --apply --confirm`.
4. Manually inspect `./.local/export-safe-config/manifest.txt`.
5. Confirm GitHub, iCloud, and ChatGPT Library content is already synced where appropriate.
6. Verify core repositories still build and test on the old Mac.
7. Backup local databases separately if needed.
8. Commit and push this repository.
9. Do not commit exported configuration, project manifests, credentials, or migration archives.

## Stage B: new Mac

1. Update macOS.
2. Install Command Line Tools.
3. Clone this repository.
4. Run `./preflight.sh`.
5. Run `./bootstrap.sh`.
6. Re-authenticate GitHub, Codex, Vercel, Docker, browsers, and editor integrations.
7. Restore reviewed safe config with `./restore-safe-config.sh --apply --force`.
8. Prepare a private overlay manifest outside this repository and run `scripts/clone-projects --manifest <PRIVATE_MANIFEST_PATH> --apply`.
9. Run `./verify.sh`.
10. Perform smoke tests in priority repositories.

## Documentation split

- Public base: the files in this repository.
- Private overlay: `docs/private-overlay.md`
- Apple migration paths: `docs/apple-migration-options.md`
