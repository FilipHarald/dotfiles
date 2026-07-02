#!/bin/bash

# Override Omarchy default shell settings.

# Keep SSH/tmux shells aligned with the graphical Omarchy session.
export EDITOR=nvim
export VISUAL=nvim

# Keep all Bash history and sync it between open terminals promptly.
shopt -s histappend
HISTSIZE=-1
HISTFILESIZE=-1
HISTFILE="$HOME/.bash_history"

__bash_additions_history_sync() {
  history -a
  history -n
}

if [[ ";${PROMPT_COMMAND:-};" != *";__bash_additions_history_sync;"* ]]; then
  if [[ -n ${PROMPT_COMMAND:-} ]]; then
    PROMPT_COMMAND="__bash_additions_history_sync;${PROMPT_COMMAND}"
  else
    PROMPT_COMMAND="__bash_additions_history_sync"
  fi
fi
