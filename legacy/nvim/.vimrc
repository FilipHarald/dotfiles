" Use space as <leader> key
let mapleader = " "

" search
set hlsearch	     " Highlight all search results
set smartcase	     " Enable smart-case search
set ignorecase	   " Always case-insensitive
set incsearch	     " Searches for strings incrementally

" tabs
set autoindent	   " Auto-indent new lines
set expandtab	     " Use spaces instead of tabs
set shiftwidth=2	 " Number of auto-indent spaces
set smartindent 	 " Enable smart-indent
set smarttab	     " Enable smart-tabs
set softtabstop=0	 " Number of spaces per Tab

" miscellaneous
set showcmd
set cursorline

set wildmode=longest,list,full
set wildmenu

set number relativenumber
set nu rnu

hi MatchParen cterm=none ctermbg=green ctermfg=blue
