" Not VI compatible.
set nocompatible

" Disable startup message.
set shortmess+=I 

" Code formatting.
syntax on
set scrolloff=5
set showmatch
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab

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

" Integrate FZF with VIM.
set rtp+=/usr/local/opt/fzf

" Add shortcut for commenting.
map <C-C> :norm 0i# <Esc> 
map <C-T> :norm 02x<Esc>

" Install vim-plug if not found.
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
