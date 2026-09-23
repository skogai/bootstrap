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
    ├── users    — wheel group, aur_builder, yay (needs real root once, via --ask-become-pass)
    ├── packages — pacman + AUR packages, installed via yay as aur_builder (no root needed)
    ├── secrets  (disabled)
    └── bitwarden (disabled)
```

`playbooks/packages.yml` runs just the `packages` role on its own — handy for iterating on the package list without touching users/secrets. All its tasks run as `aur_builder` via `yay`, never as root, so it needs no become-password flag at all: `ansible-playbook playbooks/packages.yml`.

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
│   ├── bootstrap.yml      # main playbook
│   └── packages.yml       # packages role only
├── roles/
│   ├── users/             # groups, aur_builder, yay
│   ├── packages/          # pacman + AUR packages, all installed via yay as aur_builder
│   ├── secrets/           # SSH key cloning (disabled in playbook)
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

