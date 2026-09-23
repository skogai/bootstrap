#!/usr/bin/env bash
# locale.sh — Generate en_US.UTF-8 on fresh Arch installs
# Arch ships with no locales generated. Anything that exports LANG=en_US.UTF-8
# before this runs prints "Cannot set LC_CTYPE/LC_MESSAGES/LC_ALL" warnings.
set -euo pipefail

log() { printf '\033[0;32m[+]\033[0m %s\n' "$*"; }

log "Generating en_US.UTF-8 locale..."
sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
