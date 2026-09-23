---
name: vault-ops
description: Reference for Ansible Vault operations in this repo — encrypt, decrypt, view, and verify the PAT vault. Use when working with pat.vault or pat.password.
---

# Vault Operations

## Vault Files in This Repo

| File | Purpose | Password |
|------|---------|----------|
| `pat.vault` | Production GitHub PAT, used by `gh-auth.sh` to run `gh auth login --with-token` | Real vault password, entered interactively (`--ask-vault-password`) |
| `pat.password` | ⚠️ Needs attention — see below | Not currently usable as-is |
| `pat` | Decrypted plaintext PAT (only exists transiently if you `decrypt --output pat`) | n/a — never commit this |

**Never commit the unencrypted `pat` file.** It's in `.gitignore`.

There is no test/CI vault in this repo right now. The old `pat.vault.test` + `pat.password.example` pair (non-interactive, password `password1`) was removed in `50d5fa6` along with the dolt/dev-container infra. If a non-interactive test path is needed again, recreate that pair rather than pointing anything at `pat.vault`.

## ⚠️ `pat.password` needs cleanup

Its current committed content is itself vault-encrypted bytes (`$ANSIBLE_VAULT;1.1;AES256...`), not a plaintext password. A `--vault-password-file` must contain a plaintext password (or be an executable script that prints one) — an encrypted blob can't unlock `pat.vault`. Nothing in the active flow reads it: `gh-auth.sh` uses `--ask-vault-password` instead, and the one line that would read it is commented out:

```bash
# VAULT_PASSWORD_FILE=./pat.password ansible-vault view ./pat.vault | gh auth login --with-token
```

It's also tracked in git despite `pat.password` being listed in `.gitignore` — the ignore rule was added after the file was already committed, so it currently does nothing for it.

Before treating `pat.password` as live, decide and fix one of:
- Regenerate it as an actual plaintext vault-password file (then un-ignore + wire it into `gh-auth.sh`, or keep it ignored and untrack it with `git rm --cached pat.password`).
- Or drop it entirely and keep the interactive `--ask-vault-password` flow as the only path.

## PAT scope

The vaulted PAT only needs to authenticate `gh` for one private repo: `skogai/secrets`, cloned into `~/.ssh` by `roles/secrets` (currently disabled in `playbooks/bootstrap.yml`). Use a fine-grained PAT scoped to just that repo (read-only contents) rather than a classic/broad-scope token — least privilege for what bootstrap actually needs.

## Common Commands

```bash
# View the production vault (prompts for the vault password)
ansible-vault view pat.vault --ask-vault-password

# What gh-auth.sh actually runs
ansible-vault view ./pat.vault --ask-vault-password | gh auth login --with-token

# Encrypt a new PAT into the production vault (prompts for password)
ansible-vault encrypt pat --output pat.vault

# Decrypt production vault to a file (careful — unencrypted, matches .gitignore)
ansible-vault decrypt pat.vault --output pat

# Re-key (change password on) the vault file
ansible-vault rekey pat.vault
```

## Notes

- `ansible.cfg` has `vault_password_file` commented out (`;vault_password_file=/home/skogix/.ssh/ansible-vault-password`) — intentional, so a fresh machine always prompts interactively rather than expecting a password file to already exist.
- `gh-auth.sh` skips vault/auth entirely if `gh auth status` already succeeds — safe to re-run.
- After `gh auth login --with-token`, `gh-auth.sh` runs `gh auth setup-git` so the token also works for plain `git clone`/`git pull` over HTTPS (what `roles/secrets` relies on).
