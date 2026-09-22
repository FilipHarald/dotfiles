#!/bin/bash

if [ -f "$HOME/.config/bash-additions/opencode-secrets.sh" ]; then
    source "$HOME/.config/bash-additions/opencode-secrets.sh"
fi

if [ -n "$GBRAIN_DECEM_MCP_TOKEN" ]; then
    GBRAIN_DECEM_MCP_TOKEN="${GBRAIN_DECEM_MCP_TOKEN#Bearer }"
    export GBRAIN_DECEM_MCP_TOKEN
fi
