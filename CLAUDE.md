# bootstrap — one-liner arch linux provisioning

<what_is_this>

fresh arch linux install → private repo access in one command and one vault password.
installs base deps, ansible, authenticates github, runs ansible playbook.

</what_is_this>

<flow>

```
bootstrap.sh
├── sudo pacman -S github-cli uv git
├── ./locale.sh             — generates en_US.UTF-8
├── uv tool install ansible-core
├── ./gh-auth.sh            — vault PAT → gh auth login (skips if already authed)
├── ansible-galaxy collection install -r .requirements.yml
└── ansible-playbook playbooks/bootstrap.yml --ask-become-pass
    ├── users    — wheel group, aur_builder, yay, pacman packages
    ├── packages — pacman + AUR packages
    ├── secrets  — SSH keys from github.com/skogai/secrets
    └── bitwarden (disabled)
```

</flow>

<structure>

```
bootstrap/
├── bootstrap.sh          # entry point
├── locale.sh             # generates en_US.UTF-8
├── gh-auth.sh            # gh auth (skips if already logged in)
├── ansible.cfg            # password file paths commented out
├── .inventory             # localhost connection
├── .requirements.yml      # ansible galaxy collections
├── pat.vault              # production PAT (real vault password)
├── playbooks/
│   └── bootstrap.yml      # main playbook
├── roles/
│   ├── users/             # groups, aur_builder, yay, packages
│   ├── packages/          # pacman + AUR package lists
│   ├── secrets/           # SSH key cloning
│   └── bitwarden/         # bitwarden integration (disabled in playbook)
├── vars/
│   ├── main.yml           # user config (user_name: skogix)
│   └── packages.yml       # package lists
├── tmp/                   # ansible collections installed here
└── .claude/skills/        # Claude Code skills (dev-test, vault-ops, ansible-check, ansible-core)
```

</structure>

<commands>

```bash
# run on fresh machine
git clone https://github.com/skogai/bootstrap.git && cd bootstrap && ./bootstrap.sh

# vault management
ansible-vault encrypt pat --output pat.vault              # encrypt PAT
ansible-vault decrypt pat.vault --output pat               # decrypt PAT
```

</commands>

