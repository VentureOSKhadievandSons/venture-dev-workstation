# macOS setup notes

- Target platform: macOS 12+ on Apple Silicon `arm64`.
- Preferred shell: `zsh`.
- Package manager: Homebrew with `brew bundle`.
- Python workflow: `uv` plus the Brewfile `python3`.
- Node workflow: Homebrew `node`, `corepack`, `pnpm`, minimal global CLI, project-local dependencies first.

Run `./preflight.sh` before `./bootstrap.sh`, and `./verify.sh` after each significant workstation change.
