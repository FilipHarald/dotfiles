let cwd = getcwd()
let $FZF_DEFAULT_COMMAND =  'find '.cwd.' -type f | rstrt'
let $FZF_DEFAULT_OPTS = '--ansi'
let g:fzf_history_dir = '~/.local/share/fzf-history'
let g:fzf_layout = { 'window': { 'width': 1, 'height': 0.99, 'yoffset': -1.0} }

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-v': 'vsplit' }

imap <c-x><c-p> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)


function! s:fzf_neighbouring_files()
  let current_file =expand("%")
  let cwd = fnamemodify(current_file, ':h')
  call fzf#vim#files('.', fzf#vim#with_preview({
      \ 'options':'--query ' . cwd
  \}))
endfunction
command! FZFNeigh call s:fzf_neighbouring_files()
nmap <leader><leader>f :FZFNeigh<CR>


nmap <leader>f :Files<CR>
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
nmap <leader>gz :GFiles?<CR>
nmap <leader>gh :BCommits<CR>
