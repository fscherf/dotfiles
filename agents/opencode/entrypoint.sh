#!/bin/bash

export PATH="$HOME/.opencode/bin:$PATH"

# install opencode if necessary
# source: https://opencode.ai/download
if [ ! -d ~/.opencode ]; then
    curl -fsSL https://opencode.ai/install | bash
fi

cd $PROJECT_ROOT

exec opencode
