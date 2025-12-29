#!/bin/bash

# Entry point for custom bash additions
# This file is sourced by the main ~/.bashrc

# Get the directory where this script is located
SCRIPT_DIR="$HOME/bash-additions"

# Source git commands and aliases
if [ -f "$SCRIPT_DIR/git.sh" ]; then
    source "$SCRIPT_DIR/git.sh"
fi

# Source foundry configuration
if [ -f "$SCRIPT_DIR/foundry.sh" ]; then
    source "$SCRIPT_DIR/foundry.sh"
fi
