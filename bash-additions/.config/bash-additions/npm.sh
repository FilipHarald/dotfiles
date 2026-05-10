#!/bin/bash

# NPM configuration
# Set up user-level global npm packages directory (XDG-compliant)
# Skip when using nvm, which manages its own global prefix
NVM_HOME="${NVM_DIR:-$HOME/.nvm}"
if [ ! -s "$NVM_HOME/nvm.sh" ]; then
    export PATH="$HOME/.local/npm/bin:$PATH"
fi
