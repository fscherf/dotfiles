#!/bin/bash

export PATH="$HOME/.local/bin:$PATH"

# install Claude if necessary
# source: https://code.claude.com/docs/en/quickstart#step-1-install-claude-code
if [ ! -d ~/.claude ]; then
    echo "run-agent: installing claude..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

cd $PROJECT_ROOT

exec claude
