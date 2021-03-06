" Use our user unless we have a sudo user, then is it
let luser = substitute(system('whoami'), '\n', '', '')
if strlen($SUDO_USER)
    let luser = $SUDO_USER
endif

" Manage plugins with vim-plug
call plug#begin()
Plug 'alx741/vim-hindent'
Plug 'dense-analysis/ale'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'mileszs/ack.vim'
Plug 'neovimhaskell/haskell-vim'
Plug 'plasticboy/vim-markdown'
Plug 'radenling/vim-dispatch-neovim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-perl/vim-perl'
call plug#end()

" tmux will send xterm-style keys when its xterm-keys option is on
if &term =~ '^screen'
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif 

" set path for local perl modules *before* vim-perl gets loaded as it does some
" mad batshit
set path+=lib,t/lib

" Enable all the filetype help
filetype on
filetype plugin on
filetype indent on
syntax on

" Make it pretty
set t_Co=256
set cursorline
colorscheme bakedbeans

" Basic options
set autoindent
set backspace=indent,eol,start
set expandtab
set formatoptions+=q,r,n,1,j
set history=500
set hlsearch
set ignorecase
set incsearch
set list
set listchars=tab:.\ ,trail:.,extends:#,nbsp:.
set nobackup
set nocompatible
set noerrorbells
set noswapfile
set number
set numberwidth=5  " line tracking
set scrolloff=8   " Scroll with 8 line buffer
set shiftwidth=2
set smartcase
set smartindent
set tabstop=2
set textwidth=79
set visualbell

" tweak some file types
au BufRead,BufNewFile *.t,*.cgi    set filetype=perl
au BufRead,BufNewFile *.conf       set filetype=apache
au BufRead,BufNewFile *.{tt,tt2}   set filetype=tt2html
au BufRead,BufNewFile *.tracwiki   set filetype=tracwiki
au BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn,md.html} set filetype=markdown

" Cold turkey on arrow key addiction
inoremap  <Up>     <NOP>
inoremap  <Down>   <NOP>
inoremap  <Left>   <NOP>
inoremap  <Right>  <NOP>
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>

" Get <C-n/p> to filter command history
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" Expansion of active file directory
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" Redo last substitution across entire file
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" Search for visual selection forwards/backwords with */#
xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

function! s:VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

" shortcuts
inoremap jj <Esc>
:nnoremap <F5> :buffers<CR>:buffer<Space>

map <Leader>h :bnext<cr>
map <Leader>l :bprev<cr>
map <leader>tts :%s/\s\+$//<cr>
map <leader>sp :setlocal spell! spelllang=en_GB<CR>  " toggle spellcheck

map <leader>cd :cd %:p:h<cr>         " cd to directory of current file
map <leader>F :NERDTreeFind<cr>
map <leader>R :source ~/.vimrc<cr>

map <Leader>pd :!perldoc %<cr>
map <Leader>x :!perl -Ilib %<cr>

" perldoc for module || perl command
noremap K :!perldoc <cword> <bar><bar> perldoc -f <cword><cr>

" Gitv options, not interested in merge commits
nmap <leader>gv :Gitv --all --no-merges<cr>
nmap <leader>gV :Gitv! --all --no-merges<cr>
vmap <leader>gV :Gitv! --all --no-merges<cr>

" fzf from normal mode
nnoremap <C-p> :<C-u>FZF<CR>

" http://vim.wikia.com/wiki/Redirect_g_search_output
nmap <leader>s :redir @a<cr>:g//<cr>:redir END<cr>:new<cr>:put! a<cr><cr>zRggd<cr>

" Move single lines up-down
nmap <c-up> ddkP
nmap <c-down> ddp

" Move multiple lines up-down
vmap <c-up> xkP`[V`]
vmap <c-down> xp`[V`]

" Insert on empty line, with lines above and below
nmap oo o<Esc>O

" visually select whole sub/method
nmap <leader>v v2aBV

" clear recent search highlighting with space
:nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" save files as root without prior sudo
cmap w!! w !sudo tee % >/dev/null

autocmd BufReadPost fugitive://* set bufhidden=delete

" lightline template
set laststatus=2            " always show status line
let g:lightline = {
      \ 'colorscheme': 'jellybeans',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'ale', 'fugitive', 'filename' ] ],
      \   'right': [ [ 'mixedindent', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'MyFugitive',
      \   'filename': 'MyFilename',
      \   'fileformat': 'MyFileformat',
      \   'filetype': 'MyFiletype',
      \   'fileencoding': 'MyFileencoding',
      \   'mode': 'MyMode',
      \   'ale': 'MyLinterStatus'
      \ },
      \ 'component_expand': {
      \   'mixedindent': 'MixedIndentingWarning'
      \ },
      \ 'component_type': {
      \   'mixedindent': 'error'
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

" lightline helpers
"
function! MyModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help' && &readonly ? '' : ''
endfunction

function! MyFilename()
  let fname = expand('%:t')
  return  ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ ('' != fname        ? fname : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if exists('*fugitive#head')
      let mark = ' '
      let _ = fugitive#head()
      return strlen(_) ? mark._ : ''
    endif
    catch
  endtry
  return ''
endfunction

function! MyFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  let fname = expand('%:t')
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! MyLinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
    \   '%dW %dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction

function! MixedIndentingWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction


" Perl tests
function! Prove ( verbose, taint )
    if ! exists("g:testfile")
        let g:testfile = "t/*.t"
    endif
    if g:testfile == "t/*.t" || g:testfile =~ "\.t$"
        let s:params = "lrc"
        if a:verbose
            let s:params = s:params . "v"
        endif
"        if a:taint
"            let s:params = s:params . "t"
"        endif
        execute "!TEST_POD=1 prove -I./t/lib --timer --normalize --merge -" . s:params . " " . g:testfile
    else
       call Compile ()
    endif
endfunction

" Perl compile check
function! Compile ()
    if ! exists("g:compilefile")
        let g:compilefile = expand("%")
    endif
    execute "!perl -wc -Ilib " . g:compilefile
endfunction

autocmd BufRead,BufNewFile *.t,*.pl,*.plx,*.pm nmap <Leader>T :let g:testfile = expand("%")<cr>:echo "testfile is now" g:testfile<cr>:call Prove (1,1)<cr>

" open installed perl modules
au FileType perl command! -nargs=1 PerlModuleSource :execute 'e' system('perldoc -lm <args>')
au FileType perl setlocal iskeyword+=:
au FileType perl noremap <leader>P :PerlModuleSource <cword><cr>zR<cr>

" perltidy
au FileType perl command! -range=% -nargs=* Tidy <line1>,<line2>!perltidy
au FileType perl nmap <Leader>pt mz:Tidy<cr>'z:delmarks z<cr>  " normal mode
au FileType perl vmap <Leader>pt :Tidy<cr>                     " visual mode

" Haskell
let g:hindent_on_save = 0

" Helper function, called below with mappings
function! HaskellFormat(which) abort
  if a:which ==# 'hindent' || a:which ==# 'both'
    :Hindent
  endif
  if a:which ==# 'stylish' || a:which ==# 'both'
    silent! exe 'undojoin'
    silent! exe 'keepjumps %!stylish-haskell'
  endif
endfunction

" Key bindings
augroup haskellStylish
  au!
  " Just hindent
  au FileType haskell nnoremap <leader>hi :Hindent<CR>
  " Just stylish-haskell
  au FileType haskell nnoremap <leader>hs :call HaskellFormat('stylish')<CR>
  " First hindent, then stylish-haskell
  au FileType haskell nnoremap <leader>hf :call HaskellFormat('both')<CR>
augroup END

" Ack
let g:ackhighlight = 1
let g:ack_default_options = " -H --nocolor --nogroup --column"

" ALE
let g:ale_perl_perl_options = '-c -Ilib -It/lib'
let g:ale_linters = {'perl': ['perl'] }
let g:ale_linters.haskell = ['stack-ghc', 'hlint']

let g:firenvim_config = {
    \ 'localSettings': {
        \ 'twitch\.tv': {
            \ 'selector': '',
            \ 'priority': 1
        \ },
        \ 'discordapp\.com': {
            \ 'selector': '',
            \ 'priority': 1
        \ },
        \ '.*': {
            \ 'selector': 'textarea',
            \ 'priority': 0
        \ }
    \ }
\ }

function! DoPrettyXML()
  " save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists, this will permit us to surround the
  " document with fake tags" without creating invalid xml, then we can format
  " dodgy XML fragments
  1s/<?xml .*?>//e
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'

  silent %!xmllint --format --nowarning -

  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  1  " back to home

  " restore the filetype
  exe "set ft=" . l:origft
endfunction
command! PrettyXML call DoPrettyXML()

" Open notes file for this branch, depends on fugitive and a template for
" markdeep
augroup templates
  autocmd BufNewFile *.md.html 0r ~/.vim/templates/skeleton.md.html
augroup END

function! OpenNotes()
  try
    if exists('*fugitive#head')
      let _ = fugitive#head()
      let notefile = "~/dev/NOTES/tickets/" . _ . ".md.html"
      execute "e" notefile
    endif
  catch
  endtry
endfunction
command! OpenNotes call OpenNotes()
noremap <Leader>D :OpenNotes<cr>

" Disable hard wrapping in firenvim
if exists('g:started_by_firenvim')
  set wrap
  set textwidth=0
endif
