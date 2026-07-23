# venture-dev-workstation

Reference workstation setup for a new Apple Silicon Mac used for VentureOS, AI Sales Copilot, and related AI product development.

## Goals

- Simple, readable shell scripts
- Safe to run more than once
- One file per task
- No secrets or private data
- Clear verification after setup

## Quick start

```bash
git clone https://github.com/VentureOSKhadievandSons/venture-dev-workstation.git
cd venture-dev-workstation
chmod +x bootstrap.sh verify.sh update.sh install/*.sh scripts/*
./bootstrap.sh
./verify.sh
./update.sh
```

## Repository layout

- `bootstrap.sh`: runs each installer in sequence
- `verify.sh`: prints a PASS/FAIL environment report
- `update.sh`: refreshes package managers, Playwright browsers, and global Node tools
- `install/*.sh`: one installer per tool group
- `scripts/*`: small daily helper commands
- `cursor/*`: sample Cursor configuration files
- `docs/*`: platform notes and troubleshooting

## Notes

- These scripts only change local workstation state.
- No project repositories are modified.
- Review each installer before running on a new machine if you want to trim the default toolset.
