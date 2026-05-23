SHELL=/bin/bash

FONT_NAME=SourceCodePro
FONT_URL=https://github.com/adobe-fonts/source-code-pro/archive/1.017R.tar.gz
FONT_DIRECTORY=/usr/share/fonts/truetype/$(FONT_NAME)


all: install

# debian ######################################################################
setup-debian:
	sudo apt install \
		vim vim-nox tmux git tig make mc rsync fd-find htop tree fzf \
		universal-ctags \
		python3 python3-venv

setup-debian-desktop:
	sudo apt install \
		terminator ssh-askpass virt-manager \
		wmctrl xdotool xclip suckless-tools \
		mplayer v4l-utils feh vlc \
		flameshot

# font
uninstall-font:
	sudo rm -rf $(FONT_DIRECTORY)
	fc-cache -f -v

install-font:
	sudo mkdir $(FONT_DIRECTORY)
	sudo wget $(FONT_URL) -O "$(FONT_DIRECTORY)/$(FONT_NAME).tar.gz"
	sudo tar -xf "$(FONT_DIRECTORY)/$(FONT_NAME).tar.gz" -C $(FONT_DIRECTORY)
	fc-cache -f -v

# config ######################################################################
install:
	# directories
	[ -d ~/.vim/bundle/Vundle.vim ] || (git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim; vim +VundleInstall)
	[ -d ~/bin ] || mkdir ~/bin
	[ -d ~/.config/terminator ] || mkdir -p ~/.config/terminator
	[ -d ~/.config/mc ] || mkdir -p ~/.config/mc
	# local configs
	[ -f ~/.bashrc.local ] || touch ~/.bashrc.local
	[ -f ~/.vimrc.local ] || touch ~/.vimrc.local
	# symlinks
	[ -L ~/.bashrc ] || ln -s $$PWD/.bashrc ~/.bashrc
	[ -L ~/.profile ] || ln -s $$PWD/.profile ~/.profile
	[ -L ~/.vimrc ] || ln -s $$PWD/.vimrc ~/.vimrc
	[ -L ~/.tmux.conf ] || ln -s $$PWD/.tmux.conf ~/.tmux.conf
	[ -L ~/.gitconfig ] || ln -s $$PWD/.gitconfig ~/.gitconfig
	[ -L ~/.gitignore ] || ln -s $$PWD/.gitignore.global ~/.gitignore
	[ -L ~/.tigrc ] || ln -s $$PWD/.tigrc ~/.tigrc
	[ -L ~/.config/terminator/config ] || ln -s $$PWD/terminator.cfg ~/.config/terminator/config
	[ -L ~/.config/mc/mc.keymap ] || ln -s $$PWD/mc.keymap ~/.config/mc/mc.keymap

root-install:
	[ -f ~/.bashrc.local ] || touch ~/.bashrc.local
	[ -f ~/.vimrc.local ] || touch ~/.vimrc.local
	cp .bashrc ~/.bashrc
	cp .vimrc.minimal ~/.vimrc
	cp .tmux.conf ~/.tmux.conf

# development envs ############################################################
install-pyenv:
	[ -d ~/.pyenv ] || git clone https://github.com/pyenv/pyenv.git ~/.pyenv
	sudo apt install \
		make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
		libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev \
		libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

install-npm:
	sudo apt install npm
	sudo npm install --global n
	sudo n install lts

install-docker:
	sudo apt install docker docker.io docker-compose
	sudo adduser $$USER docker

# vim #########################################################################
install-vim9:
	sudo add-apt-repository ppa:jonathonf/vim
	sudo apt update

# cinnamon ####################################################################
dconf-dump:
	dconf dump / > dconf.dump

dconf-load:
	dconf load / < dconf.dump
