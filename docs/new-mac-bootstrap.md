# New Mac bootstrap

## Prerequisites

1. Finish macOS updates.
2. Install Command Line Tools:

```bash
xcode-select --install
```

3. Clone this repository:

```bash
git clone <PUBLIC_REPO_URL>
cd <PUBLIC_REPO_DIR>
```

## Bootstrap

```bash
chmod +x \
  bootstrap.sh \
  preflight.sh \
  update.sh \
  verify.sh \
  export-safe-config.sh \
  restore-safe-config.sh \
  install/*.sh \
  scripts/*
./preflight.sh
./bootstrap.sh
./verify.sh
```

## After bootstrap

1. Re-authenticate accounts and apps.
2. Restore reviewed safe config.
3. Clone repositories from a private manifest outside this repository.
4. Run smoke tests in each critical repository.
