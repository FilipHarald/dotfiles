#!/bin/bash
set -euo pipefail

# Idempotently connect the user shell to the bash-additions entrypoint.
# Safe to re-run on hosts where ~/.config/bash-additions is symlinked to this
# dotfiles package.

BASHRC="${HOME}/.bashrc"
ENTRY='if [ -f "$HOME/.config/bash-additions/entry.sh" ]; then
    source "$HOME/.config/bash-additions/entry.sh"
fi'

touch "$BASHRC"

if grep -Fq '.config/bash-additions/entry.sh' "$BASHRC"; then
    exit 0
fi

{
    printf '\n'
    printf '# Source user-managed shell additions\n'
    printf '%s\n' "$ENTRY"
} >> "$BASHRC"
