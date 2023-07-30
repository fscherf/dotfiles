# variables ###################################################################
export EDITOR="/usr/bin/vim -p"
export TERM="screen-256color"

if [ $UID -gt 0 ]; then
    export GIT_AUTHOR_NAME="Florian Scherf"
    export GIT_COMMITTER_NAME="Florian Scherf"
fi

# bindings ####################################################################
set -o vi
bind -m vi-command ".":insert-last-argument
bind -m vi-insert "\C-l.":clear-screen
bind -m vi "H":backward-word
bind -m vi "S":forward-word
bind -m vi "h":backward-char
bind -m vi "n":history-search-backward
bind -m vi "t":history-search-forward
bind -m vi "s":forward-char

# path ########################################################################
# dotfiles, local
if [ $UID -gt 0 ]; then
    export PATH="$HOME/bin:$HOME/.dotfiles/bin"
fi

# debian
export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# completion ##################################################################
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# aliases #####################################################################
alias ..='cd ..'
alias l='ls -hlF --color=auto'
alias ll='ls -hAlF --color=auto'
alias tree='tree -C'
alias rgrep='grep -rnI'
alias feh='feh --scale-down'
alias vim='vim -p'
alias kw='date +%V'

# tmenu
alias tfs='eval $(tmux show-env -s |grep "^SSH_")'

# sudo
if [ $UID -gt 0 ]; then
    alias ++='sudo -s'
    alias umount='sudo umount'
    alias apt='sudo apt'
    alias apt-get='sudo apt-get'
    alias aptitude='sudo aptitude'
    alias reboot='sudo reboot'
    alias service='sudo service'
    alias systemctl='sudo systemctl'
    alias journalctl='sudo journalctl'
    alias dmesg='sudo dmesg'
fi

# prompt command ##############################################################
prompt_command() {
    export LAST_STATUS=$?
    export PS1=$(bash-prompt)
}

export PROMPT_COMMAND=prompt_command

# functions ###################################################################
apt-cache() {
    if [ "$1" == "search" ]; then
        unset $1
        command apt-cache $@ | sed 's/ - / | /' | column -t -s '|'
    else
        command apt-cache $@
    fi
}

mount() {
    if [ "$1" == "" ]; then
        (echo "DEVICE 0 MOUNTPOINT 0 TYPE OPTIONS"; command mount ) | awk '{printf("%s %s %s %s\n", $1, $3, $5, $6)}' | column -t
    else
        sudo command $@
    fi
}

abspath() {
    echo $(cd $(dirname $1); pwd)/$(basename $1)
}

gi() {
    curl -L -s https://www.gitignore.io/api/$@ > .gitignore
}

dd-progress() {
    if [ $1 ]; then
        sudo kill -USR1 $1
    else
        for i in $(pgrep '^dd$'); do
            sudo kill -USR1 $i
        done
    fi
}

start-ssh-agent() {
    if [ ! -S $SSH_AUTH_SOCK ]; then
        ssh-agent -a $SSH_AUTH_SOCK
    fi

    find ~/.ssh/ -type f -exec grep -l "PRIVATE" {} \; | xargs ssh-add
}

# pyenv #######################################################################
if [ -d ~/.pyenv ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"

    unset PYENV_VERSION
fi

# cargo #######################################################################
if [ -d ~/.cargo ]; then
    source ~/.cargo/env
fi

# local bashrc ################################################################
source ~/.bashrc.local
