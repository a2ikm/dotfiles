set tabstop=2
set shiftwidth=2
set backspace=2
set expandtab
set autoindent
set nocompatible
set showmatch
set title
filetype on
colorscheme desert

" Solve error: pattern uses more memory than 'maxmempattern'
" https://www.gitmemory.com/issue/vim/vim/2049/494923065
set mmp=5000

set encoding=utf-8
set termencoding=utf-8
set fileencodings=utf-8,iso-2022-jp,cp932,euc-jp,utf-16,utf-16le
set fileformats=unix,dos,mac
set fenc=utf-8
set enc=utf-8

set laststatus=2
set statusline=%f\ \(%{&fileencoding}\:%{&fileformat}\)
set statusline+=%=%l/%L\ %c

" https://github.com/guard/listen/issues/434
set backupcopy=yes

highlight JpSpace cterm=underline ctermfg=Red guifg=Red
au BufRead,BufNew * match JpSpace /　/
"autocmd BufWritePre * :%s/\s\+$//e

filetype plugin indent on
syntax on

" search and scroll to center
nmap n nzz
nmap N Nzz

" After insert, automatically set nopaste
autocmd InsertLeave * set nopaste

" http://vim-users.jp/2011/02/hack202/
augroup vimrc-auto-mkdir  " {{{
  autocmd!
  autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
  function! s:auto_mkdir(dir, force)  " {{{
    if !isdirectory(a:dir) && (a:force ||
    \    input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
      call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
  endfunction  " }}}
augroup END  " }}}

let _curfile=expand("%:r")
if _curfile == 'Makefile'
  set noexpandtab
endif
