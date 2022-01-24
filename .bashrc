PS1='\[\a\]\[\033[01;32m\]\u@\h \[\033[01;34m\]\W \$ \[\033[00m\]'

# Some random background colors for every new terminal
echo -ne "\e]11;$(printf '#%02x%02x%02x\n' $[RANDOM%50] $[RANDOM%50] $[RANDOM%50])\a"

export TERM=xterm-256color

# Aliases
alias ls='ls --color'
alias grep='grep --color=auto'
alias gp='git pull'
alias gd='git diff'
alias gcm='git checkout master'
alias gpm='git pull origin master'
alias ydir='cd ~/code/yggio'

# functions
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
shopt -s histappend
export HISTFILESIZE=
export PATH=$PATH:/usr/local/bin/
export HISTSIZE=

if [ -n "$DESKTOP_SESSION" ];then
  eval $(gnome-keyring-daemon --start)
  export SSH_AUTH_SOCK
fi

# yarn global without sudo
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
if [ -f /home/filip/code/yggio/tools/dev-scripts/yggiorc.sh ]; then
  source /home/filip/code/yggio/tools/dev-scripts/yggiorc.sh
fi

# npm global without sudo
NPM_PACKAGES="${HOME}/.npm-packages"
PATH="$NPM_PACKAGES/bin:$PATH"
unset MANPATH
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# BEGIN ANSIBLE MANAGED BLOCK
export PATH=:~/bin:$HOME/istio/bin:$PATH
export KUBECONFIG=$HOME/.kube/config:/home/filip/code/dev-ops/kubeconfigs/kube_config_kna.yml:/home/filip/code/dev-ops/kubeconfigs/kube_config_sto.yml:$KUBECONFIG
# END ANSIBLE MANAGED BLOCK

# This is taken from Ubuntu default
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
