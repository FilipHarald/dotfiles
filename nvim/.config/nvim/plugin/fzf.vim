let g:fzf_history_dir = '~/.local/share/fzf-history'

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

imap <c-x><c-p> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)

nmap <leader>f :Files<CR>
nmap <leader><leader>f :Files %:p:h<CR>
nmap <leader>s :Rg<CR>
nmap <leader>h :History<CR>
nmap <leader>b :Buffers<CR>

" z is for exZperimental
nmap <leader>zw :Windows<CR>
nmap <leader>zhc :History:<CR>
nmap <leader>zhs :History/<CR>
nmap <leader>zc :Commands<CR>
nmap <leader>zm :Maps<CR>

" depends on fugitive.vim
nmap <leader>gf :GFiles<CR>
nmap <leader>gfd :GFiles?<CR>
nmap <leader>gcc :Commits<CR>
nmap <leader>gcb :BCommits<CR>