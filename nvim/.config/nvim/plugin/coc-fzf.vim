let g:coc_fzf_preview = ''
let g:coc_fzf_opts = []

" Mappings for CocFzfList
" Show all diagnostics.
nnoremap <leader>cla  :<C-u>CocFzfList diagnostics<cr>
" Show all diagnostics.
nnoremap <leader>clb  :<C-u>CocFzfList diagnostics --current-buf<cr>
" Manage extensions.
nnoremap <leader>cle  :<C-u>CocFzfList extensions<cr>
" Show commands.
nnoremap <leader>clc  :<C-u>CocFzfList commands<cr>
" Find symbol of current document.
nnoremap <leader>clo  :<C-u>CocFzfList outline<cr>
" Search workspace symbols.
nnoremap <leader>cls  :<C-u>CocFzfList -I symbols<cr>
" Resume latest coc list.
nnoremap <leader>clp  :<C-u>CocListResume<cr>
