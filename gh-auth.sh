#!/usr/bin/env bash
# gh-auth.sh — Authenticate gh via the vaulted PAT, skipping if already logged in
set -euo pipefail

log() { printf '\033[0;32m[+]\033[0m %s\n' "$*"; }

if gh auth status &>/dev/null; then
    log "gh already authenticated, skipping"
    exit 0
fi

log "Authenticating gh..."
# VAULT_PASSWORD_FILE=./pat.password ansible-vault view ./pat.vault | gh auth login --with-token
ansible-vault view ./pat.vault --ask-vault-password | gh auth login --with-token
gh auth setup-git
gh auth status
