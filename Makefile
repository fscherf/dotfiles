SHELL=/bin/bash

.PHONY: cockpit


all: install

# debian ######################################################################
setup-debian:
	sudo apt install \
		vim vim-nox tmux git tig make rsync \
		python3 python3-venv \
		docker docker.io docker-compose \
		wmctrl xdotool

	sudo adduser $$USER docker

# config ######################################################################
install:
	[ -d ~/.vim/bundle/Vundle.vim ] || (git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim; vim +VundleInstall)
	[ -d ~/bin ] || mkdir ~/bin
	[ -d ~/.config/Code/User ] || mkdir ~/.config/Code/User
	[ -f ~/.bashrc.local ] || touch ~/.bashrc.local
	[ -f ~/.vimrc.local ] || touch ~/.vimrc.local
	cp .bashrc ~/.bashrc
	cp .gitconfig ~/.gitconfig
	cp .tmux.conf ~/.tmux.conf
	cp .tigrc ~/.tigrc
	cp .vimrc ~/.vimrc
	cp vscode/keybindings.json ~/.config/Code/User
	cp vscode/settings.json ~/.config/Code/User

pull:
	cp ~/.bashrc .bashrc
	cp ~/.gitconfig .gitconfig
	cp ~/.tmux.conf .tmux.conf
	cp ~/.tigrc .tigrc
	cp ~/.vimrc .vimrc
	cp ~/.config/Code/User/keybindings.json vscode
	cp ~/.config/Code/User/settings.json vscode

# cockpit #####################################################################
cockpit:
	$(MAKE) -C cockpit server

# development envs ############################################################
install-pyenv:
	[ -d ~/.pyenv ] || git clone https://github.com/pyenv/pyenv.git ~/.pyenv

	sudo apt update

	sudo apt install \
		make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
		libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev \
		libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

install-npm:
	sudo install npm
	sudo npm install --global n
	sudo n install lts
