" plugin management with vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" Styling
Plug 'sainnhe/gruvbox-material'

" Increase productivity
Plug 'junegunn/fzf'                             " fuzzy search
Plug 'junegunn/fzf.vim'                         " need both of these
Plug 'tpope/vim-fugitive'                       " git integration
Plug 'tpope/vim-unimpaired'                     " some good keybinds
Plug 'tpope/vim-vinegar'                        " improves netrw
Plug 'tpope/vim-rhubarb'                        " improves Github-integration
Plug 'cedarbaum/fugitive-azure-devops.vim'      " improves Github-integration
Plug 'nat-418/boole.nvim'                       " cycle more than just nbrs

" language-specific and LSP-stuff
Plug 'neoclide/coc.nvim', {'branch': 'release'} " LSP integratinon
Plug 'antoinemadec/coc-fzf'
Plug 'pearofducks/ansible-vim', { 'do': './UltiSnips/generate.sh' }

" Miscellaneous
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'liuchengxu/vim-which-key'                 " some help with keybinds
Plug 'p00f/nvim-ts-rainbow'                     " easier to see matching parentheses
Plug 'mbbill/undotree'                          " more powerful undo

" Track what I work with
" Plug 'ActivityWatch/aw-watcher-vim'
" Plug 'FilipHarald/aw-watcher-vim'
" Plug '~/code/aw-watcher-vim'

" vim for everything?
Plug 'jrop/mongo.nvim'

call plug#end()

let g:coc_global_extensions = [ 'coc-json', 'coc-git', 'coc-tsserver', 'coc-eslint', 'coc-styled-components', 'coc-rust-analyzer', 'coc-prettier', '@yaegassy/coc-ansible', 'coc-docker' ]
let g:coc_filetype_map = {
  \ 'yaml.ansible': 'ansible',
  \ }

" Use space as <leader> key
let mapleader = " "

" persistent undo
if has("persistent_undo")
   let target_path = expand('~/.vim-undo')
    if !isdirectory(target_path)
        call mkdir(target_path, "p", 0700)
    endif

    let &undodir=target_path
    set undofile
endif

" Y wil now act as C and D
noremap Y y$
vnoremap <leader>p "_dP

" integrate with system clipboard
set clipboard+=unnamedplus

" turn off mouse
set mouse=

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
set updatetime=300            " improves responsiveness for coc.nvim, amongst other things

set cursorline                " help with finding cursor
set scrolloff=20              " some padding when scrolling

set wildmode=longest:full
set wildmenu

set number relativenumber
set signcolumn=number

" Gruvbox colorscheme
set background=dark
let g:gruvbox_contrast_light='hard'
colorscheme gruvbox-material

" better matching brackets
hi MatchParen cterm=none ctermbg=red ctermfg=white

" recursive create folder on save
function s:MkNonExDir(file, buf)
    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
        let dir=fnamemodify(a:file, ':h')
        if !isdirectory(dir)
            call mkdir(dir, 'p')
        endif
    endif
endfunction
augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END
