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

# Source shell overrides (history, etc.)
if [ -f "$SCRIPT_DIR/shell.sh" ]; then
    source "$SCRIPT_DIR/shell.sh"
fi

# Source opencode telemetry environment
if [ -f "$SCRIPT_DIR/opencode.sh" ]; then
    source "$SCRIPT_DIR/opencode.sh"
fi

# Source Linear API credentials if available
if [ -f "$HOME/linear/api.env" ]; then
    source "$HOME/linear/api.env"
fi

set -h
