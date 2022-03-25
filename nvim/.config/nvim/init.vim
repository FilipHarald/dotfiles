" plugin management with vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" Styling
Plug 'morhetz/gruvbox'                          " Gruvbox theme

" Productivity
Plug 'junegunn/fzf'                             " fuzzy search
Plug 'junegunn/fzf.vim'                         " need both of these
Plug 'tpope/vim-fugitive'                       " git integration
Plug 'liuchengxu/vim-which-key'                 " some help with keybinds

" Language specific
Plug 'neoclide/coc.nvim', {'branch': 'release'} " LSP integration
Plug 'neoclide/coc-json'                        " json
Plug 'neoclide/coc-tsserver'                    " js
Plug 'neoclide/coc-eslint'                      " js
Plug 'fannheyward/coc-styled-components'        " js

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
set scrolloff=5               " some padding when scrolling

set wildmode=longest:full
set wildmenu

set number relativenumber
set nu rnu
set signcolumn=number         " Add signs on top of number column

" ==== DISPLAY

" Gruvbox colorscheme
set background=dark
let g:gruvbox_contrast_light='hard'
colorscheme gruvbox

" ==== TOOLS

" FZF
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_history_dir = '~/.local/share/fzf-history'
let g:fzf_layout = { 'window': { 'width': 0.95, 'height': 0.95 } }
imap <c-x><c-p> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)

nmap <leader>f :Files<CR>
nmap <leader><leader>f :Files %:p:h<CR>
nmap <leader>s :Rg<CR>
nmap <leader>h :History<CR>
nmap <leader>b :Buffers<CR>

nmap <leader>zw :Windows<CR>
nmap <leader>zhc :History:<CR>
nmap <leader>zhs :History/<CR>
nmap <leader>zc :Commands<CR>
nmap <leader>zm :Maps<CR>

nmap <leader>gf :GFiles<CR>
nmap <leader>gfd :GFiles?<CR>
nmap <leader>gcc :Commits<CR>
nmap <leader>gcb :BCommits<CR>

" fugitive.vim bindings
nmap <leader>gb :Git blame<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gs :G<CR>
nmap <leader>gmf :diffget //2<CR>
nmap <leader>gmj :diffget //3<CR>

" which-key
" let g:which_key_fallback_to_native_key = 1
" autocmd VimEnter * let g:which_key_map =  {}
" autocmd VimEnter * call which_key#register('<Space>', "g:which_key_map")
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
