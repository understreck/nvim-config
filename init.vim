call plug#begin(stdpath('data') . '/plugged')
Plug 'tpope/vim-vinegar'

Plug 'vim-airline/vim-airline'
let g:airline_powerline_fonts=1

Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'arecarn/crunch.vim'

"Disabled because it messes with coc.nvim
"Plug 'ElderTwig/dwm.vim'
"set master pane width to 85 columns
"let g:dwm_master_pane_width=85

"Plug 'terryma/vim-multiple-cursors'
"Plug 'sjl/gundo.vim'
"nnoremap <F5> :GundoToggle<CR>
Plug 'sheerun/vim-polyglot'

"Plug 'jackguo380/vim-lsp-cxx-highlight'

"Plug 'm-pilia/vim-ccls'

Plug 'preservim/nerdtree'
let NERDTreeShowHidden=1

Plug 'danro/rename.vim'

Plug 'ericcurtin/CurtineIncSw.vim'
map <F4> :call CurtineIncSw()<CR>

Plug 'preservim/nerdcommenter'

Plug 'luochen1990/rainbow'
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
let g:rainbow_conf = {
\   'separately': {
\       'cmake': 0,
\   }
\}

"Plug 'sakhnik/nvim-gdb', { 'do': ':!./install.sh \| UpdateRemotePlugins' }

" Themes
"Plug 'ajmwagar/vim-deus'
"Plug 'JBakamovic/yaflandia'
Plug 'joshdick/onedark.vim'
"Plug 'nanotech/jellybeans.vim'
"Plug 'cocopon/iceberg.vim'
"Plug 'arcticicestudio/nord-vim'

Plug 'reedes/vim-colors-pencil'
let g:pencil_higher_contrast_ui = 1 
" Themes

call plug#end()

let $NVIM_COC_LOG_LEVEL = 'debug'

let mapleader='\'

colorscheme onedark

syntax enable

set mouse=a
set expandtab
set shiftwidth=2
set tabstop=2               "tabs are 2 columns wide
set softtabstop=2           "removes spaces on <BS> as if it was a tab
set lcs=trail:·,tab:»·
set list
set cursorline
set number relativenumber

set signcolumn=yes
set colorcolumn=80 "visual cue to not go further than 80 columns
let g:minimumWidth=80


set splitbelow splitright   "opens splits below/right, instead of above/left
set hidden                  "allow switching between buffer without write

set ignorecase smartcase

set hlsearch

set clipboard+=unnamed,unnamedplus   "system clipboard as default

"don't use working directory for temporary files
set backupdir=~/.config/nvim/backup//
set directory=~/.config/nvim/swap//
set undodir=~/.config/nvim/undo//

filetype on

filetype plugin indent on   "choose autoindent depending on filetype

set updatetime=100 "milliseconds between updates

set laststatus=2

let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors "enable 24bit colors

autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

"navigate buffers
nnoremap <leader>k :ls!<CR>:b<Space>

function! ChangeWidth(newWidth)
    function! CycleWindows()
        let nrWindows = winnr('$')
        let i = 0
        while i < nrWindows
            call RotateForward()
            let &colorcolumn = g:minimumWidth
            let i = i + 1
        endwhile
    endfunction

    let g:minimumWidth = a:newWidth
    tabdo call CycleWindows()
endfunction

"nnoremap <leader><left> 
nnoremap <silent> <Tab> :bnext!<CR>
nnoremap <silent> <S-Tab> :bprevious!<CR>

"insert newline before/after current line
nnoremap <leader>O m`O<ESC>``
nnoremap <leader>o m`o<ESC>``

"Build and run shortcuts
noremap <F6> :tabnew term:// ./configure-
noremap <F7> :tabnew term:// ./build-
noremap <F8> :tabnew term:// ./run-

"Open init.vim
nnoremap <F12> :e ~/.config/nvim/init.vim<CR>

"Turn of search highlighting until next search
nnoremap <silent> <leader>hh :noh<CR>
nnoremap <silent> <leader><space> :noh<CR>

function! ResizeWindow()
  let l:windRestoreData = winsaveview()

  set virtualedit=all
  norm! g$
  let l:actualWidth=virtcol('.')

  set virtualedit=""

  call winrestview(l:windRestoreData)
  norm zz<CR>

  exe ":vertical resize +" . (g:minimumWidth - l:actualWidth)
endfunction

function! EnterWindow()
  wincmd K
  wincmd H
  set number relativenumber
  call ResizeWindow()
endfunction

function! BufferEmpty()
  return line('$') == 1 && getline(1) == ""
endfunction

function! UnnamedBuffer()
  return bufname() == ""
endfunction

function! LeaveWindow()
  if BufferEmpty() && UnnamedBuffer()
    bdelete
    echo "Yeeted empty buffer"
  elseif w:rotateFlag == 0
    wincmd K
  endif
endfunction

augroup manageWindows
  autocmd!
  autocmd FileType list let b:isList=1
  autocmd WinEnter,BufEnter * let w:rotateFlag=0
  autocmd WinEnter,BufEnter * if !exists('b:isList') | call EnterWindow()
  autocmd WinLeave,BufLeave * if !exists('b:isList') | call LeaveWindow()
augroup END

function! RotateForward()
  wincmd K
  wincmd R

  let w:rotateFlag=1
  1 wincmd w
  let w:rotateFlag=0
endfunction

function! RotateBack()
  wincmd K
  wincmd r

  let w:rotateFlag=1
  1 wincmd w
  let w:rotateFlag=0
endfunction

nnoremap <silent> <leader><left> :call RotateBack()<CR>
nnoremap <silent> <leader>wq :call RotateBack()<CR>

nnoremap <silent> <leader><right> :call RotateForward()<CR>
nnoremap <silent> <leader>we :call RotateForward()<CR>

set showtabline=0

nnoremap <silent> <leader>ww :tabnext<CR>
nnoremap <silent> <leader>ss :tabprevious<CR>
nnoremap <silent> <leader>wl :tabs<CR>:tabn 

function! NewTab()
  let l:curPos = getcurpos()
  exe ":tabnew %"
  call setpos('.', l:curPos)
endfunction

nnoremap <silent> <leader>wa :call NewTab()<CR>
nnoremap <silent> <leader>wd :tabclose<CR>

nnoremap <silent> <leader>qq  :-tabmove ""<CR>
nnoremap <silent> <leader>ee  :+tabmove ""<CR>

"------------------------------------------------------------------------------
"git-difftool like functionality
"------------------------------------------------------------------------------
function! Testing(branchName)
  call NewTab()
  rewind
  exe "Gdiffsplit " a:branchName

  let l:i = 0
  while l:i < (argc() - 1)
    call NewTab()
    n
    exe "Gdiffsplit " a:branchName

    let l:i = l:i + 1
  endwhile
endfunction
