" Disable arrow-keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
inoremap <Up> <NOP>
inoremap <Down> <NOP>
inoremap <Left> <NOP>
inoremap <Right> <NOP>

" Use space as <leader> key
let mapleader = " "

" netrw
let g:netrw_liststyle = 3

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
set updatetime=500

set wildmode=longest,list,full
set wildmenu

set number relativenumber
set nu rnu

" ==== PACK/DISPLAY

" Gruvbox colorscheme
set background=dark
let g:gruvbox_contrast_light='hard'
colorscheme gruvbox


" ==== PACK/TOOLS

" Fzf bindings
nmap <leader>f :Files<CR>
nmap <leader><leader>f :Files %:p:h<CR>
nmap <leader>gc :Commits<CR>
nmap <leader>gf :GFiles<CR>
nmap <leader>gs :GFiles?<CR>
nmap <leader>h :History<CR>
nmap <leader>b :Buffers<CR>
nmap <leader>s :Rg<CR>

" fugitive.vim bindings
nmap <leader>gb :Git blame<CR>

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
