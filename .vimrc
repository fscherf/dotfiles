" variables -------------------------------------------------------------------
syn on
set title
set autoindent
set ignorecase
set nowrap
set smartindent
set number
set listchars=eol:$,tab:>-,trail:~
set hlsearch
set foldmethod=indent
set foldlevel=99
set timeoutlen=200
set colorcolumn=80
set cursorline
set clipboard=unnamedplus
set mouse=a

let mapleader = " "

" theme -----------------------------------------------------------------------
set background=dark

" cursor
hi clear CursorLine
hi clear CursorLineNR
hi CursorLine cterm=NONE ctermbg=black
hi ColorColumn cterm=NONE ctermbg=black

" spell
hi clear SpellBad
hi SpellBad cterm=underline

" tabs
hi clear TabLine
hi clear TabLineSel
hi clear TabLineFill
hi TabLine ctermfg=grey ctermbg=none
hi TabLineSel ctermfg=white ctermbg=none
hi TabLineFill ctermfg=none ctermbg=none

" NERDTree
hi clear VertSplit
highlight VertSplit ctermfg=grey ctermbg=none

hi clear StatusLine
hi StatusLine ctermfg=white ctermbg=none

hi clear StatusLineNC
hi StatusLineNC ctermfg=grey ctermbg=none

" mappings --------------------------------------------------------------------
nnoremap Q <nop>

" dvorak movement keys
map h <Left>
map t <Down>
map n <Up>
map s <Right>

map T <PageDown>
map N <PageUp>

" search
nnoremap <Enter> n
nnoremap <BS> N

" toggles
map <silent> <Leader>l :set invlist<CR>
map <silent> <Leader>p :set invpaste<CR>
map <silent> <leader>n :set invnumber<CR>

" close
map <silent> q :q!<CR>
map <silent> w :w<CR>:redraw!<CR>
map <silent> x :x<CR>
map <silent> e :e<CR>

" completion
map <silent> <C-o> i<C-x><C-o>
map <silent> <C-f> i<C-x><C-f>
imap <silent> <C-o> <C-x><C-o>
imap <silent> <C-f> <C-x><C-f>

" hlsearch
map <silent> <leader>h :nohl<CR>

" macros ----------------------------------------------------------------------
iab yybs #!/bin/bash
iab yyps #!/usr/bin/env python<CR># -*- coding: utf-8 -*-
iab yyap # Author: Florian Scherf <mail@florianscherf.de>

" tabs ------------------------------------------------------------------------
map <silent> H :tabprevious<CR>
map <silent> S :tabnext<CR>

map <silent> ! :tabmove -1<CR>
map <silent> @ :tabmove +1<CR>
map <silent> + :tabnew<CR>

" filetype settings
filetype plugin indent on

autocmd FileType rst,python,sh,javascript,css,scss,yaml,typescript,markdown setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType *html*                                                     setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType gitcommit                                                  setlocal paste spell
autocmd FileType gitrebase                                                  setlocal spell

" functions -------------------------------------------------------------------
" Trim
highlight WhitespaceEOL ctermbg=red guibg=red
call matchadd('WhitespaceEOL', '\s\+$')

function! Trim()
  let lineNumber = line('.')
  %s/\s*$//
  call cursor(lineNumber, 0)
endfunction

command! -nargs=0 Trim :call Trim()

" Vundle ----------------------------------------------------------------------
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'sjl/badwolf'
Plugin 'scrooloose/nerdtree'
Plugin 'Valloric/MatchTagAlways'
Plugin 'ervandew/supertab'
Plugin 'airblade/vim-gitgutter'

call vundle#end()
filetype plugin indent on

" Syntastic
hi SignColumn ctermbg=None
let g:syntastic_check_on_open = 1
let g:syntastic_python_python_exec = '/usr/bin/env python'
let g:syntastic_python_checkers = ["flake8"]

" gitgutter
map <silent> <C-g> :GitGutterToggle<CR>
imap <silent> <C-g> <Esc>:GitGutterToggle<CR><insert>

" NERDTree
map <Leader>t :NERDTreeToggle<CR>:redraw!<CR>
map <silent> <Leader>t :NERDTreeToggle<CR>

let NERDTreeQuitOnOpen=1
let NERDTreeIgnore = ['\.pyc$', '__pycache__', '\.egg-info$']
let NERDTreeMapOpenInTab='T'
let NERDTreeMapToggleHidden='i'
let NERDTreeMapToggleFilters='i'
let NERDTreeMapUpdirKeepOpen='A'
let NERDTreeMapActivateNode='u'
let NERDTreeMapChangeRoot='U'
let NERDTreeMapToggleZoom = 'f'
let NERDTreeMapOpenVSplit=''
let NERDTreeMapOpenSplit=''
let NERDTreeMapPreviewSplit=''
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" local vimrc -----------------------------------------------------------------
source ~/.vimrc.local

