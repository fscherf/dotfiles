SHELL=/bin/bash

.PHONY: cockpit

install:
	[ -d ~/.vim/bundle/Vundle.vim ] || (git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim; vim +VundleInstall)
	[ -d ~/bin ] || mkdir ~/bin
	[ -f ~/.bashrc.local ] || touch ~/.bashrc.local
	[ -f ~/.vimrc.local ] || touch ~/.vimrc.local
	cp .bashrc ~/.bashrc
	cp .gitconfig ~/.gitconfig
	cp .tmux.conf ~/.tmux.conf
	cp .tigrc ~/.tigrc
	cp .vimrc ~/.vimrc

pull:
	cp ~/.bashrc .bashrc
	cp ~/.gitconfig .gitconfig
	cp ~/.tmux.conf .tmux.conf
	cp ~/.tigrc .tigrc
	cp ~/.vimrc .vimrc

cockpit:
	$(MAKE) -C cockpit server

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
