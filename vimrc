" Use our user unless we have a sudo user, then is it
let luser = substitute(system('whoami'), '\n', '', '')
if strlen($SUDO_USER)
    let luser = $SUDO_USER
endif

" tmux will send xterm-style keys when its xterm-keys option is on
if &term =~ '^screen'
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif

" set path for local perl modules *before* vim-perl gets loaded as it does some
" mad batshit
set path+=lib

" get pathogen to load the plugins
call pathogen#infect()
silent! call pathogen#helptags()

filetype on
filetype plugin on
filetype indent on
syntax on

set t_Co=256
colorscheme bakedbeans

set autoindent
set backspace=indent,eol,start
set cursorline
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

" Sidebar folder navigation
let NERDTreeShowLineNumbers=1
let NERDTreeShowBookmarks=1
let NERDTreeChDirMode=2
let NERDTreeWinSize=35

" shortcuts
inoremap jj <Esc>
:nnoremap <F5> :buffers<CR>:buffer<Space>

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

" Search for visual selection with */#
xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

function! s:VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

map <Leader>h :bnext<cr>
map <Leader>l :bprev<cr>
map <Leader>pd :!perldoc %<cr>
map <Leader>f :TlistToggle<cr>
map <Leader>x :!perl -Ilib %<cr>
map <leader>tts :%s/\s\+$//<cr>
map <leader>sp :setlocal spell! spelllang=en_GB<CR>  " toggle spellcheck

map <leader>cd :cd %:p:h<cr>         " cd to directory of current file
map <leader>F :NERDTreeFind<cr>
map <leader>R :source ~/.vimrc<cr>

" Gitv
nmap <leader>gv :Gitv --all --no-merges<cr>
nmap <leader>gV :Gitv! --all --no-merges<cr>
vmap <leader>gV :Gitv! --all --no-merges<cr>

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

" perldoc for module || perl command
noremap K :!perldoc <cword> <bar><bar> perldoc -f <cword><cr>

autocmd BufReadPost fugitive://* set bufhidden=delete

" lightline
set laststatus=2            " always show status line
let g:lightline = {
      \ 'colorscheme': 'jellybeans',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ],
      \   'right': [ [ 'mixedindent', 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'MyFugitive',
      \   'filename': 'MyFilename',
      \   'fileformat': 'MyFileformat',
      \   'filetype': 'MyFiletype',
      \   'fileencoding': 'MyFileencoding',
      \   'mode': 'MyMode',
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag',
      \   'mixedindent': 'MixedIndentingWarning'
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \   'mixedindent': 'error'
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

function! MyModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help' && &readonly ? '' : ''
endfunction

function! MyFilename()
  let fname = expand('%:t')
  return fname == 'ControlP' ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname =~ 'NERD_tree' ? '' :
        \ ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|NERD' && exists('*fugitive#head')
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
  return fname == '__Tagbar__' ? 'Tagbar' :
        \ fname == 'ControlP' ? 'CtrlP' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

let g:tagbar_status_func = 'TagbarStatusFunc'

function! TagbarStatusFunc(current, sort, fname, ...) abort
    let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.pm,*.c,*.cpp call s:syntastic()
augroup END
function! s:syntastic()
  SyntasticCheck
  call lightline#update()
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

" file types
au BufRead,BufNewFile *.t,*.cgi    set filetype=perl
au BufRead,BufNewFile *.conf       set filetype=apache
au BufRead,BufNewFile *.{tt,tt2}   set filetype=tt2html
au BufRead,BufNewFile *.tracwiki   set filetype=tracwiki
au BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn} set filetype=markdown

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
        execute "!TEST_POD=1 prove --timer --normalize --merge -" . s:params . " " . g:testfile
    else
       call Compile ()
    endif
endfunction

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

" perl syntastic
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_perl_checkers = ['perl']
let g:syntastic_enable_perl_checker = 1
let g:syntastic_perl_lib_path = ['./lib', './t/lib']
let g:syntastic_ignore_files = ['\m\c\.t$']

" Ack
let g:ackhighlight = 1
let g:ack_default_options = " -H --nocolor --nogroup --column"

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

" Open notes file for this branch, depends on fugitive
function! OpenNotes()
  try
    if exists('*fugitive#head')
      let _ = fugitive#head()
      let notefile = "~/dev/NOTES/tickets/" . _ . ".mkd"
      execute "e" notefile
    endif
  catch
  endtry
endfunction
command! OpenNotes call OpenNotes()
noremap <Leader>D :OpenNotes<cr>
