" plugin management with vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" Styling
Plug 'vim-airline/vim-airline'                  " Pretty statusline
Plug 'morhetz/gruvbox'                          " Gruvbox theme

" Productivity
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'tpope/vim-fugitive'                       " git integration
Plug 'neoclide/coc.nvim', {'branch': 'release'} " LSP integration
Plug 'liuchengxu/vim-which-key'

" Language specific
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

" netrw
let g:netrw_liststyle = 3
let g:airline_section_z = airline#section#create(['windowswap', 'obsession', 'linenr', 'colnr'])

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

set cursorline
set scrolloff=5      " Cursor centered-ish

set wildmode=full
set wildmenu

set number relativenumber
set nu rnu
set signcolumn=number " Add signs on top of number column

" ==== PACK/DISPLAY

" Gruvbox colorscheme
set background=dark
let g:gruvbox_contrast_light='hard'
colorscheme gruvbox


" ==== PACK/TOOLS

" Telescope
lua require('telescope').setup { extensions = { fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case", } } }
lua require('telescope').load_extension('fzf')

nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fd <cmd>lua require('telescope.builtin').find_files({ hidden = true })<cr>
nnoremap <leader>ss <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>s* <cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.expand("<cword>") })<cr>
nnoremap <leader>b <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>h <cmd>lua require('telescope.builtin').help_tags()<cr>
nnoremap <leader>hc <cmd>lua require('telescope.builtin').command_history()<cr>
nnoremap <leader>hs <cmd>lua require('telescope.builtin').search_history()<cr>
nnoremap <leader>gf <cmd>lua require('telescope.builtin').git_files()<cr>
nnoremap <leader>gc <cmd>lua require('telescope.builtin').git_commits()<cr>
nnoremap <leader>gbr <cmd>lua require('telescope.builtin').git_branches()<cr>

" fugitive.vim bindings
nmap <leader>gbl :Git blame<CR>
nmap <leader>gd :Gdiff<CR>

" == COC
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Start Coc
" nmap <leader>cs :CocStart<CR>

" Use `<leader>cd` to get all diagnostics of current buffer in location list.
nmap <leader>cd :CocDiagnostics<CR>

" Format current buffer
nmap <leader>cf :call CocAction('format')<CR>

" Get suggestions to fix warnings and errors on current line
nmap <leader>ca <Plug>(coc-codeaction-line)

" Rename a symbol
nmap <leader>cr <Plug>(coc-rename)


" let g:coc_disable_startup_warning = 1
nmap <leader>cgd <Plug>(coc-definition)
nmap <leader>cgD <Plug>(coc-declaration)
nmap <leader>cgy <Plug>(coc-type-definition)
nmap <leader>cgi <Plug>(coc-implementation)
nmap <leader>cgr <Plug>(coc-references)

" Use `[g` and `]g` to navigate diagnostics
nmap <silent>[g <Plug>(coc-diagnostic-prev)
nmap <silent>]g <Plug>(coc-diagnostic-next)

" Use cdoc to show documentation in preview window.
nnoremap <leader>cdoc :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call cocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" which-key
" let g:which_key_fallback_to_native_key = 1
" autocmd VimEnter * let g:which_key_map =  {}
" autocmd VimEnter * call which_key#register('<Space>', "g:which_key_map")
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
