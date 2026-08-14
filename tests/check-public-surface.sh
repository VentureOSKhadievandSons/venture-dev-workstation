#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "$ROOT_DIR" <<'PY'
import pathlib
import re
import subprocess
import sys
from urllib.parse import urlparse

root = pathlib.Path(sys.argv[1])
files = subprocess.run(
    ["git", "-C", str(root), "ls-files"],
    check=True,
    capture_output=True,
    text=True,
).stdout.splitlines()

allowed_domains = {
    "api.github.com",
    "developers.openai.com",
    "example.com",
    "formulae.brew.sh",
    "github.com",
    "pypi.org",
    "raw.githubusercontent.com",
    "registry.npmjs.org",
    "vercel.com",
}
allowed_repo_urls = {
    "https://github.com/VentureOSKhadievandSons/venture-dev-workstation",
    "https://github.com/VentureOSKhadievandSons/venture-dev-workstation.git",
}
allowed_example_repo_prefixes = (
    "https://github.com/example/",
)
web_tlds = {
    "ai",
    "app",
    "cloud",
    "co",
    "com",
    "dev",
    "io",
    "me",
    "net",
    "org",
    "ru",
    "sh",
    "us",
}
ignored_suffixes = {
    "json",
    "toml",
    "yaml",
    "yml",
    "md",
    "txt",
    "png",
    "jpg",
    "jpeg",
    "gif",
    "svg",
    "log",
    "sh",
    "ts",
    "tsx",
    "js",
    "mjs",
    "py",
    "sql",
    "git",
    "bak",
    "tmp",
}

user_path_re = re.compile(r"/Users/(?!<USER>|Shared|example(?:-user)?\b)([A-Za-z0-9._-]+)")
email_re = re.compile(r"\b[A-Za-z0-9._%+-]+@([A-Za-z0-9.-]+\.[A-Za-z]{2,})\b")
url_re = re.compile(r"https?://[^\s)>\]\"']+")
repo_url_re = re.compile(r"^https://github\.com/[^/\s]+/[^/\s]+(?:\.git)?$")
bare_domain_re = re.compile(r"(?<![@/])\b(?:[a-z0-9-]+\.)+[a-z]{2,10}\b", re.IGNORECASE)

violations = []

for relative_path in files:
    path = root / relative_path
    content = path.read_text(encoding="utf-8", errors="ignore")

    for match in user_path_re.finditer(content):
        violations.append(f"{relative_path}: real user path {match.group(0)}")

    for match in email_re.finditer(content):
        domain = match.group(1).lower()
        if domain != "example.com":
            violations.append(f"{relative_path}: non-example email {match.group(0)}")

    for match in url_re.finditer(content):
        url = match.group(0).rstrip(".,;:")
        if "$" in url or "{" in url:
            continue
        parsed = urlparse(url)
        host = (parsed.hostname or "").lower()
        if host not in allowed_domains:
            violations.append(f"{relative_path}: URL host outside allowlist {url}")
            continue

        trimmed = url.rstrip("/")
        if repo_url_re.match(trimmed):
            if trimmed in allowed_repo_urls:
                continue
            if trimmed.startswith(allowed_example_repo_prefixes):
                continue
            violations.append(f"{relative_path}: repository URL outside allowlist {url}")

    for match in bare_domain_re.finditer(content):
        raw_token = match.group(0)
        if raw_token != raw_token.lower():
            continue
        token = raw_token.lower()
        labels = token.split(".")
        if labels[-1] not in web_tlds:
            continue
        if token in allowed_domains:
            continue
        if any(allowed.endswith(f".{token}") for allowed in allowed_domains):
            continue
        if token.endswith(tuple(f".{suffix}" for suffix in ignored_suffixes)):
            continue
        if any(label in ignored_suffixes for label in labels[1:]):
            continue
        if token.endswith(".example.com"):
            continue
        violations.append(f"{relative_path}: bare domain outside allowlist {token}")

if violations:
    for item in violations:
        print(item, file=sys.stderr)
    raise SystemExit(1)
PY
