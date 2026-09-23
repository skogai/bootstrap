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

<users>

two local users matter here: `skogix` (you) and `aur_builder` (build relay, created by the `users` role).

`sudo -l` shows `Defaults targetpw` — sudo prompts for the **target** user's password, not the caller's. So plain `become: true` (target = root) always needs root's own password, no matter who's asking. This is why a become-password-file that isn't literally root's password (e.g. one meant for something else entirely) fails identically on every root task regardless of which playbook or user invokes it — it's not a permissions/guardrail thing, it's just the wrong password for the target.

both of the relevant sudoers rules are group-scoped, not per-user:

```
/etc/sudoers.d/10-wheel:                %wheel ALL=(ALL:ALL) ALL
/etc/sudoers.d/12-wheel-to-aur_builder: %wheel ALL=(aur_builder) NOPASSWD: ALL
/etc/sudoers.d/11-install-aur_builder:  aur_builder ALL=(ALL) NOPASSWD: /usr/bin/pacman
```

so any member of `wheel` — not just `skogix` — can become `aur_builder` with no password, and `aur_builder` can then run `/usr/bin/pacman` as any target, including root, with no password either. That's why every task in the `packages` role uses `become_user: aur_builder` + `use: yay` instead of `become: true` directly: it's a passwordless path to root, scoped to one binary.

`NOPASSWD: pacman` is functionally unrestricted root, not a narrow scope — pacman runs arbitrary ALPM hooks/install scripts as root, so anything installable (including from AUR, which `aur_builder` can already build freely) can escalate further. That's intentional here, not an oversight: it's the deliberate line between "runs freely" (package management, via `aur_builder`) and "needs a real root password" (everything else — `users`' group/account setup, and anything not routed through a relay user).

this is precisely the lesson learned from an earlier, removed `claude` role (`1e3c1bf`): it created a dedicated `claude` user with its own bespoke `claude ALL=(ALL) NOPASSWD:ALL` line — unrestricted passwordless root. Since the relay grants above are already on `%wheel`, that bespoke line was pure redundancy layered on top of unnecessary danger: simply adding `claude` to `wheel` — `groups: [wheel]`, nothing else — gets it the exact same safe split every other wheel member gets for free, real root gated behind `targetpw`, package management free via the `aur_builder` relay. No per-user sudoers entry needed, ever, for this shape of agent account.

</users>

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

