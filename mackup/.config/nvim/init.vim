" Load vim configuration.
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Install nvim plugins.
call plug#begin()
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}
Plug 'pocco81/auto-save.nvim'
Plug 'sbdchd/neoformat'
call plug#end()

" Configure fzf.
set rtp+=/opt/homebrew/opt/fzf

" Key mappings.
" Telescope.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fb <cmd>Telescope file_browser<cr>
" Move line or visually selected block up or down (j/k).
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
" Move between buffers using `\b`.
nnoremap <Leader>b :ls<Cr>:b<Space>

" Additional nvim config.
set autoindent              " Indent a new line the same amount as the line just typed.
set wildmode=longest,list   " Get bash-like tab completions.
filetype plugin on          " Allow auto-indenting depending on file type.
filetype plugin indent on
set clipboard=unnamedplus   " Using system clipboard.
set ttyfast                 " Speed up scrolling in Vim.
set splitright              " Change default split direction.
set splitbelow

" Change color of pop-ups.
highlight Pmenu ctermbg=darkgray guibg=darkgray

" Jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

