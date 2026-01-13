#!/bin/bash

# Entry point for custom bash additions
# This file is sourced by the main ~/.bashrc

# Get the directory where this script is located
SCRIPT_DIR="$HOME/.config/bash-additions"

# Source git commands and aliases
if [ -f "$SCRIPT_DIR/git.sh" ]; then
    source "$SCRIPT_DIR/git.sh"
fi

# Source npm configuration
if [ -f "$SCRIPT_DIR/npm.sh" ]; then
    source "$SCRIPT_DIR/npm.sh"
fi
