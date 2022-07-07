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
nmap <leader>cdi :CocDiagnostics<CR>

" Format current buffer
nmap <leader>cf :call CocAction('format')<CR>

" Get suggestions to fix warnings and errors on current line
nmap <leader>ca <Plug>(coc-codeaction-cursor)

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

" Use <leader>cdoc to show documentation in preview window.
nnoremap <leader>cdoc :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
