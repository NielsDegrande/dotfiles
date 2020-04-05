" Not VI compatible.
set nocompatible

" Disable startup message.
set shortmess+=I 

" Code formatting.
syntax on
set scrolloff=5
set showmatch
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

" UI tweaks.
set backspace=indent,eol,start
set laststatus=2
set showcmd

" Search options.
set hlsearch
set ignorecase
set incsearch
set smartcase

" Line numbers and ruler.
set number
set relativenumber
set ruler

" Manage undo history.
set undodir=~/.vim/undodir
set undofile

" Configure plugins.
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

" Integrate FZF with VIM.
set rtp+=/usr/local/opt/fzf
