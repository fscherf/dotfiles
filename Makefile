SHELL=/bin/bash


install:
	[ -d ~/.vim/bundle/Vundle.vim ] || git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	[ -d ~/.tmenu ] || git clone https://github.com/fscherf/tmenu ~/.tmenu
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
