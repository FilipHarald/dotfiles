shopt -s histappend
export HISTFILESIZE=
export HISTSIZE=

promptFunc() {
  if [[ -x $(realpath "$HOME/bin/rstrt") ]]
  then
    WD=`pwd | $HOME/bin/rstrt --ps1-escape`
    COLORIZED_DIR=`echo "${WD}" | awk -F/ '{print $NF}'`
    PS1="\`echo -e \"\[\a\]\[\033[01;32m\]\h\[\033[01;34m\] ${COLORIZED_DIR} \$ \"\`"
  else
    PS1='\[\a\]\[\033[01;32m\]\h\[\033[01;34m\] \W \$ \[\033[00m\]'
  fi
}
PROMPT_COMMAND="promptFunc"

export TERM=xterm-256color

# Aliases
alias ls='ls --color'
alias grep='grep --color=auto'
alias gp='git pull'
alias gd='git diff'
alias gcm='git checkout master'
alias gpm='git pull origin master'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.RunningFor}}\t{{.Status}}\t{{.Ports}}"'

function gcb() {
  git checkout -b "$@" && \
  git push --set-upstream origin "$@" && \
  git commit --allow-empty -m "empty commit"
  git push
}
function gsts() {
  echo "====== GIT STATUS ======"
  git status --ignored && echo ""
}
function gs() {
  gsts
  echo "====== GIT STASH ======"
  git stash list
}
function g() {
  gsts && \
  echo "Would you like to add all files to current branch?" && read && echo "" && \
  echo "====== GIT PULL ======"
  git pull && echo "" && \
  echo "====== GIT ADD ======"
  git add --a && echo "" && \
  echo "====== GIT COMMIT ======"
  git commit -m "$@" && echo "" && \
  echo "====== GIT PUSH ======"
  git push
}

# i3 - for displaying shell window names
function rei3cont() {
  echo -ne "\033]0;$@\007"
}

# shell vars
export EDITOR=vim
export PATH=$PATH:/usr/local/bin/
export BAT_THEME="gruvbox-light"

# yarn global without sudo
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# npm global without sudo
NPM_PACKAGES="${HOME}/.npm-packages"
PATH="$NPM_PACKAGES/bin:$PATH"
unset MANPATH
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

[ -f  /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
[ -f  /usr/share/doc/fzf/examples/completion.bash ] && source /usr/share/doc/fzf/examples/completion.bash

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:${HOME}/go/bin

. "$HOME/.cargo/env"

# This is taken from Ubuntu default
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

source <(kubectl completion bash)

export PATH="$PATH:/home/filip/.foundry/bin"
export PATH=$PATH:/home/filip/.aztec/bin
export KUBE_EDITOR=nvim
