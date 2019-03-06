" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes
Plug 'drewtempelmeyer/palenight.vim' "theme
Plug 'itchyny/lightline.vim' "lightline on bottom
Plug 'sickill/vim-monokai' "theme
Plug 'tpope/vim-commentary' "comments via gcc/gc
Plug 'scrooloose/nerdtree' "nerdtree
Plug 'junegunn/fzf', { 'dir': '~/configs/.fzf', 'do': './install --all' } "fzf fuzzy finder
Plug 'junegunn/fzf.vim' "fzf
Plug 'editorconfig/editorconfig-vim' "multi-editor tool

" Initialize plugin system
call plug#end()

" Theme stuff
set background=dark
syntax on "color highlighting
colorscheme monokai "default teme
set number "line numbers
set incsearch
set hlsearch
set noshowmode "hide add'l --INSERT-- on bottom
set laststatus=2 "keep lightlime on

imap jj <esc>

"nerdtree mapped to Ctrl-O
map <C-o> :NERDTreeToggle<CR>
