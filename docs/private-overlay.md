# Private overlay

## Purpose

Keep repository-specific manifests, internal prompts, private templates, and other non-public migration inputs outside this public repository.

## Recommended storage locations

- a separate private overlay repository
- a local directory outside this repository
- an iCloud-backed private directory that is not synced into public Git

## What belongs in the private overlay

- real project manifests
- internal bootstrap notes
- private prompt libraries
- internal documentation with private URLs or customer context
- any safe config artifacts you choose to retain outside the public repository

## What must not come back into this repository

- exported configuration
- real project manifests
- credentials or auth state
- migration archives

Do not commit exported configuration, project manifests, credentials, or migration archives.
