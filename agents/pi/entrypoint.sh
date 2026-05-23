#!/bin/bash

export PATH="$HOME/.local/bin:$PATH"

# install pi if necessary
# source: https://pi.dev/docs/latest#quick-start
if [ ! -f ~/.local/bin/pi ]; then
    curl -fsSL https://pi.dev/install.sh | sh
fi

cd $PROJECT_ROOT

exec pi
