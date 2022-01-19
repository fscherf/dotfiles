# variables ###################################################################
export EDITOR="/usr/bin/vim -p"
export TERM="screen-256color"
export GIT_AUTHOR_NAME="Florian Scherf"
export GIT_COMMITTER_NAME="Florian Scherf"

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
# debian
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# ~/bin
export PATH="$PATH:$HOME/bin"

# tmenu
export PATH="$PATH:$HOME/.tmenu:$HOME/.tmenu/bin"

# completion ##################################################################
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# aliases #####################################################################
alias ..='cd ..'
alias l='ls -hlF --color=auto'
alias ll='ls -hAlF --color=auto'
alias tree='tree -C'
alias grep='grep -n'
alias rgrep='grep -rnI'
alias feh='feh --scale-down'
alias vim='vim -p'
alias kw='date +%V'

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
fi

# prompt command ##############################################################
prompt_command() {
    # exitcode
    if [ $? == 0 ]; then
        LAST_STATUS=" \[\e[1;32m\]\$\[\e[0m\]"
        export PS2="\[\e[1;32m\]\$\[\e[0m\] "
    else
        LAST_STATUS=" \[\e[1;31m\]$? \$\[\e[0m\]"
        export PS2="\[\e[1;31m\]\$\[\e[0m\] "
    fi

    # git
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    if [ $? == 0 ]; then
        BRANCH=" \[\e[1;36m\]$BRANCH\[\e[0m\]"
    else
        BRANCH=
    fi

    # flags
    FLAGS=
    if [ -n "$SSH_CONNECTION" ]; then
        FLAGS="ssh "
    fi

    if [ -n "$VIRTUAL_ENV" ]; then
        FLAGS="$FLAGS""env "
    fi

    FLAGS="\[\e[1;31m\]$FLAGS\[\e[0m\]"

    # PS1
    if [ "$PWD" == "$HOME" ]; then
        export PS1="$FLAGS\[\e[1;32m\]\u@\h\[\e[0m\] \[\e[1;34m\]~\[\e[0m\]$BRANCH$LAST_STATUS "
    else
        export PS1="\[\e[1;34m\]\w\[\e[0m\]\n$FLAGS\[\e[1;32m\]\u@\h\[\e[0m\]$BRANCH$LAST_STATUS "
    fi
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

git-reset-date() {
    GIT_COMMITTER_DATE="$(date)" git commit --amend --no-edit --date "$(date)"
}

# local bashrc ################################################################
source ~/.bashrc.local

