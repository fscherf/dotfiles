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
set mouse=a
set clipboard=unnamedplus

" theme -----------------------------------------------------------------------
set background=dark

" cursor and linenr
hi clear LineNr
hi clear CursorLine
hi clear CursorLineNR
hi LineNr ctermfg=darkgrey
hi CursorLine cterm=NONE ctermbg=black
hi ColorColumn cterm=NONE ctermbg=black
hi CursorLineNR cterm=NONE ctermfg=white ctermbg=black

" spell
hi clear SpellBad
hi SpellBad cterm=underline

" tabs
hi clear TabLine
hi clear TabLineSel
hi clear TabLineFill
hi TabLine ctermfg=darkgrey ctermbg=none
hi TabLineSel ctermfg=white ctermbg=none
hi TabLineFill ctermfg=none ctermbg=none

" pmenu
hi Pmenu ctermbg=gray ctermfg=black
hi PmenuSel ctermbg=darkgray ctermfg=white
hi PmenuSbar ctermbg=gray ctermfg=None
hi PmenuThumb ctermbg=black ctermfg=None

" trailing whitespace
highlight WhitespaceEOL ctermbg=red guibg=red
call matchadd('WhitespaceEOL', '\s\+$')

" NERDTree
hi clear VertSplit
highlight VertSplit ctermfg=grey ctermbg=none

hi clear StatusLine
hi StatusLine ctermfg=white ctermbg=none

hi clear StatusLineNC
hi StatusLineNC ctermfg=grey ctermbg=none

" Syntastic
hi SyntasticErrorSign ctermfg=red ctermbg=None
hi SyntasticWarningSign ctermfg=yellow ctermbg=None

hi clear SignColumn
hi GitGutterAdd ctermfg=green
hi GitGutterChange ctermfg=blue
hi GitGutterDelete ctermfg=red
hi GitGutterChangeDelete ctermfg=red

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

" toggles
map <silent> l :nohl<CR>
map <silent> L :set invlist<CR>

" macros ----------------------------------------------------------------------
iab yybs #!/bin/bash
iab yyps #!/usr/bin/env python<CR># -*- coding: utf-8 -*-
iab yyap # Author: Florian Scherf <mail@florianscherf.de>
iab yyae ä
iab yyue ü
iab yyoe ö
iab yyss ß

" tabs ------------------------------------------------------------------------
map <silent> H :tabprevious<CR>
map <silent> S :tabnext<CR>
map <silent> ! :tabmove -1<CR>
map <silent> @ :tabmove +1<CR>
map <silent> + :tabnew<CR>

" filetype settings -----------------------------------------------------------
filetype plugin indent on

autocmd FileType rst,python,sh,javascript,css,scss,yaml,typescript,markdown setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType *html*                                                     setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType yaml,yml,json,typescript,css                               setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType gitcommit                                                  setlocal paste spell
autocmd FileType gitrebase                                                  setlocal spell

" functions -------------------------------------------------------------------
" Trim
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
Plugin 'scrooloose/nerdtree'
Plugin 'Valloric/MatchTagAlways'
Plugin 'ervandew/supertab'
Plugin 'airblade/vim-gitgutter'
Plugin 'vim-syntastic/syntastic'
Plugin 'davidhalter/jedi-vim'
Plugin 'junegunn/fzf'
Plugin 'cespare/vim-toml'
Plugin 'preservim/tagbar'
Plugin 'preservim/vim-markdown'

call vundle#end()
filetype plugin indent on

" plugins ---------------------------------------------------------------------
" Syntastic
let g:syntastic_check_on_open = 1
let syntastic_style_error_symbol = '>>'
let syntastic_style_warning_symbol = '>>'

let g:syntastic_python_checkers = ['flake8']

" gitgutter
let g:gitgutter_override_sign_column_highlight = 0

autocmd BufWritePost * GitGutter

map <silent> <C-g> :GitGutterToggle<CR>
imap <silent> <C-g> <Esc>:GitGutterToggle<CR><insert>

" NERDTree
map <silent>F :NERDTreeToggle<CR>:redraw!<CR>

let NERDTreeIgnore = ['\.pyc$', '__pycache__', '\.egg-info$']

let NERDTreeQuitOnOpen = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

let NERDTreeMapOpenInTab = 'T'
let NERDTreeMapToggleHidden = 'i'
let NERDTreeMapToggleFilters = 'i'
let NERDTreeMapUpdirKeepOpen = 'A'
let NERDTreeMapActivateNode = 'u'
let NERDTreeMapChangeRoot = 'U'
let NERDTreeMapToggleZoom = 'f'
let NERDTreeMapJumpRoot = 'g'
let NERDTreeMapQuit = '<Esc>'

let NERDTreeMapPreview = ''
let NERDTreeMapPreviewSplit = ''
let NERDTreeMapPreviewVSplit = ''
let NERDTreeMapOpenVSplit = ''
let NERDTreeMapOpenSplit = ''

" Jedi
let g:jedi#use_tabs_not_buffers = 1
let g:jedi#rename_command_keep_name = '<F2>'
let g:jedi#goto_definitions_command = '<F3>'
let g:jedi#usages_command = '<F4>'

" FZF
map <silent>f :FZF<CR>

let $FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git || git ls-files'
let g:fzf_action = {'enter': 'tab split'}

" tagbar
nmap <F8> :TagbarToggle fj<CR>

let g:tagbar_autoclose = 1
let g:tagbar_map_togglepause = ''
let g:tagbar_map_togglesort = ''

" local vimrc -----------------------------------------------------------------
source ~/.vimrc.local
