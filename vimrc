" Gist options - put code in clipboard
let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1

" Use our user unless we have a sudo user, then is it
let luser = substitute(system('whoami'), '\n', '', '')
if strlen($SUDO_USER)
    let luser = $SUDO_USER
endif

if &term =~ '^screen'
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif

" pathogen
call pathogen#infect()
silent! call pathogen#helptags()

let g:indent_guides_guide_size=2

set number
set nocompatible

filetype on
filetype plugin on
filetype indent on
set t_Co=256
syntax on
colorscheme bakedbeans

" folding
"let perl_fold=1
"let perl_extended_vars = 1
set foldmethod=indent

" backspaces over everything in insert mode
set backspace=indent,eol,start

set autoindent
set tabstop=2
set shiftwidth=2
set smartindent
set expandtab
set textwidth=79
set formatoptions=qrn1
set incsearch
set ignorecase
set smartcase
set visualbell
set noerrorbells
set hlsearch
set history=500
set scrolloff=10   " Scroll with 10 line buffer
set nobackup
set noswapfile
set numberwidth=5  " line tracking
set cursorline

let g:buftabline_numbers=1
let g:buftabline_indicators=1

" clear recent search highlighting with space
:nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" save files as root without prior sudo
cmap w!! w !sudo tee % >/dev/null

set list
set listchars=tab:.\ ,trail:.,extends:#,nbsp:.

" lightline
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'component': {
      \   'readonly': '%{&readonly?"⭤":""}',
      \ }
      \ }

" status bar
set statusline=%f\                                " tail of the filename
set statusline+=%{fugitive#statusline()}          " git branch
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}      " syntax errors
set statusline+=%*

set statusline+=%=                                " left/right separator
set statusline+=%{StatuslineCurrentHighlight()}\  " current highlight
set statusline+=%c,                               " cursor column
set statusline+=%l/%L                             " cursor line/total lines
set statusline+=\ %P\                             " percent through file
set laststatus=2                                  " always show status line

" warning for mixed indenting
set statusline+=%#error#
set statusline+=%{StatuslineMixedIndentingWarning()}
set statusline+=%*

set statusline+=%h                                " help file flag
set statusline+=%y                                " filetype
set statusline+=%r                                " read only flag
set statusline+=%m                                " modified flag

" Sidebar folder navigation
let NERDTreeShowLineNumbers=1
let NERDTreeShowBookmarks=1
let NERDTreeChDirMode=2
let NERDTreeWinSize=35

" mojo
let mojo_highlight_data = 1

" shortcuts
inoremap jj <Esc>
nnoremap ; :
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

let mapleader = ','
noremap <Leader>, :NERDTreeToggle<cr>
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

map <leader>pull :silent !sandbox pull %<cr>
map <leader>push :silent !sandbox push %<cr>
map <leader>same :!sandbox same %<cr>
map <leader>rt :!sandbox rtest %<cr>
map <leader>diff :!sandbox diff %<cr>

" http://vim.wikia.com/wiki/Redirect_g_search_output
nmap <leader>s :redir @a<cr>:g//<cr>:redir END<cr>:new<cr>:put! a<cr><cr>zRggd<cr>

" Move single lines up-down
nmap <c-up> ddkP
nmap <c-down> ddp

" Resize vertical windows
nmap + <c-w>+
nmap _ <c-w>-

" Resize horizontal windows
nmap > <c-w>>
nmap < <c-w><

" Move multiple lines up-down
vmap <c-up> xkP`[V`]
vmap <c-down> xp`[V`]

" Insert on empty line, with lines above and below
nmap oo o<Esc>O

" visually select whole sub/method
nmap <leader>v v2aBV

" autocompletion
imap <Leader><Tab> <C-X><C-O>

" perldoc for module || perl command
noremap K :!perldoc <cword> <bar><bar> perldoc -f <cword><cr>

" file types
au BufRead,BufNewFile *.t,*.cgi    set filetype=perl
au BufRead,BufNewFile *.conf       set filetype=apache
au BufRead,BufNewFile *.{tt,tt2}   set filetype=tt2html
au BufRead,BufNewFile *.tracwiki   set filetype=tracwiki
au BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn} set filetype=markdown

" haskell support (vim2hs)
let g:haskell_conceal_wide = 1
au FileType haskell nmap gt :GhcModType<cr>
au FileType haskell nmap gc :GhcModTypeClear<cr>

" save/retrieve folds automatically
au BufWinLeave * silent! mkview
au BufWinEnter * silent! loadview

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
au FileType perl command! -nargs=1 PerlModuleSource :tabnew `perldoc -lm <args>`
au FileType perl setlocal iskeyword+=:
au FileType perl noremap <leader>P :PerlModuleSource <cword><cr>zR<cr>

" perltidy
au FileType perl command! -range=% -nargs=* Tidy <line1>,<line2>!perltidy
au FileType perl nmap <Leader>pt mz:Tidy<cr>'z:delmarks z<cr>  " normal mode
au FileType perl vmap <Leader>pt :Tidy<cr>                     " visual mode

" include local lib when doing perl syntax checks
let g:syntastic_perl_lib_path = './lib,./t/lib'
let g:syntastic_ignore_files = ['\m\c\.t$']

" ack shortcut
let g:ackprg="ack-grep -H --nocolor --nogroup --column"

" To use gf with perl "
set path+=$PWD/**,
set path+=/usr/lib/perl5/**,
set path+=/usr/share/perl5/**,

inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a

" Automatic tabularize with pipes |
function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction

function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

function! StatuslineMixedIndentingWarning()
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

" return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

function! s:check_and_lint()
  let l:qflist = ghcmod#make('check')
  call extend(l:qflist, ghcmod#make('lint'))
  call setqflist(l:qflist)
  cwindow
  if empty(l:qflist)
    echo "No errors found"
  endif
endfunction

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

