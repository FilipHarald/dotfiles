" fugitive.vim bindings

" common
nmap <leader>gb :Git blame<CR>
nmap <leader>gs :G<CR>

" compare to master
nmap <leader>gdb :Git difftool --name-only master<CR>
nmap <leader>gdm :Gvdiffsplit master<CR>

" resolve merges
nmap <leader>gd :Gvdiffsplit!<CR>
nmap <leader>gmf :diffget //2<CR>
nmap <leader>gmj :diffget //3<CR>
