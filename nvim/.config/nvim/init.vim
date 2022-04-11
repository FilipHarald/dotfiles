" plugin management with vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" Styling
Plug 'sainnhe/gruvbox-material'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Increase Productivity
Plug 'junegunn/fzf'                             " fuzzy search
Plug 'junegunn/fzf.vim'                         " need both of these
Plug 'tpope/vim-fugitive'                       " git integration
Plug 'liuchengxu/vim-which-key'                 " some help with keybinds

" Track Productivity
Plug 'FilipHarald/aw-watcher-vim'

" Language specific
Plug 'neoclide/coc.nvim', {'branch': 'release'} " LSP integration
Plug 'neoclide/coc-json'                        " json
Plug 'neoclide/coc-tsserver'                    " js
Plug 'neoclide/coc-eslint'                      " js
Plug 'fannheyward/coc-styled-components'        " js
Plug 'rust-lang/rust.vim'                       " Rust

call plug#end()

" Disable arrow-keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
inoremap <Up> <NOP>
inoremap <Down> <NOP>
inoremap <Left> <NOP>
inoremap <Right> <NOP>

" Y wil now act as C and D
noremap Y y$

" Use space as <leader> key
let mapleader = " "

" integrate with system clipboard
set clipboard+=unnamedplus

" netrw
let g:netrw_liststyle = 3

" search
set hlsearch         " Highlight all search results
set smartcase        " Enable smart-case search
set ignorecase       " Always case-insensitive
set incsearch        " Searches for strings incrementally

" tabs
set autoindent       " Auto-indent new lines
set expandtab        " Use spaces instead of tabs
set shiftwidth=2     " Number of auto-indent spaces
set smartindent      " Enable smart-indent
set smarttab         " Enable smart-tabs
set softtabstop=0    " Number of spaces per Tab
set linebreak        " Break long lines by word-boundaries instead of in the middle of word

" a little visual help
set list
set listchars=
set listchars+=tab:░░
set listchars+=trail:▓
set listchars+=extends:»
set listchars+=precedes:«
set listchars+=nbsp:⣿

" miscellaneous
set showcmd
set updatetime=300

set cursorline                " help with finding cursor
set scrolloff=20              " some padding when scrolling

set wildmode=longest:full
set wildmenu

set number relativenumber
set nu rnu
set signcolumn=number         " Add signs on top of number column

" Gruvbox colorscheme
set background=dark
let g:gruvbox_contrast_light='hard'
colorscheme gruvbox-material
