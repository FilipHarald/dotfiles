#!/bin/bash

# Git aliases
alias gp='git pull'
alias gcm='git checkout master'
alias gpm='git pull origin master'

# Create a new branch, push it to origin, and make an empty commit
function gcb() {
  git checkout -b "$@" &&
    git push --set-upstream origin "$@" &&
    git commit --allow-empty -m "empty commit"
  git push
}

# Show git status with header
function gsts() {
  echo "====== GIT STATUS ======"
  git status --ignored && echo ""
}

# Show git status and stash list
function gs() {
  gsts
  echo "====== GIT STASH ======"
  git stash list
}

# Interactive git workflow: status, pull, add all, commit, push
function g() {
  gsts &&
    echo "Would you like to add all files to current branch?" && read && echo "" &&
    echo "====== GIT PULL ======"
  git pull && echo "" &&
    echo "====== GIT ADD ======"
  git add --a && echo "" &&
    echo "====== GIT COMMIT ======"
  git commit -m "$@" && echo "" &&
    echo "====== GIT PUSH ======"
  git push
}

# Create a new worktree and branch from within current git directory.
ga() {
  if [[ -z "$1" ]]; then
    echo "Usage: ga [branch name]"
    exit 1
  fi

  local branch="$1"
  local base="$(basename "$PWD")"
  local path="../${base}--${branch}"

  git worktree add -b "$branch" "$path"
  mise trust "$path"
  cd "$path"
}

# Remove worktree and branch from within active worktree directory.
gd() {
  if gum confirm "Remove worktree and branch?"; then
    local cwd base branch root

    cwd="$(pwd)"
    worktree="$(basename "$cwd")"

    # split on first `--`
    root="${worktree%%--*}"
    branch="${worktree#*--}"

    # Protect against accidentially nuking a non-worktree directory
    if [[ "$root" != "$worktree" ]]; then
      cd "../$root"
      git worktree remove "$worktree" --force
      git branch -D "$branch"
    fi
  fi
}
