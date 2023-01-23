SHELL=/bin/bash

FONT_NAME=SourceCodePro
FONT_URL=https://github.com/adobe-fonts/source-code-pro/archive/1.017R.tar.gz
FONT_DIRECTORY=/usr/share/fonts/truetype/$(FONT_NAME)

.PHONY: cockpit


all: install

# debian ######################################################################
setup-debian:
	sudo apt install \
		vim vim-nox tmux git tig make rsync \
		python3 python3-venv \
		docker docker.io docker-compose \
		wmctrl xdotool xclip feh flameshot

	sudo adduser $$USER docker

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

root-install:
	[ -f ~/.bashrc.local ] || touch ~/.bashrc.local
	[ -f ~/.vimrc.local ] || touch ~/.vimrc.local
	cp .bashrc ~/.bashrc
	cp .vimrc.minimal ~/.vimrc
	cp .tmux.conf ~/.tmux.conf

# vscode ######################################################################
setup-vscode:
	code --install-extension vscodevim.vim
	code --install-extension GitHub.github-vscode-theme
	code --install-extension shardulm94.trailing-spaces
	code --install-extension streetsidesoftware.code-spell-checker

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
