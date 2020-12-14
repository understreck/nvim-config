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

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jackguo380/vim-lsp-cxx-highlight'

"Plug 'm-pilia/vim-ccls'

Plug 'preservim/nerdtree'
let NERDTreeShowHidden=1

Plug 'danro/rename.vim'

Plug 'ericcurtin/CurtineIncSw.vim'
map <F4> :call CurtineIncSw()<CR>

"Plug 'sbdchd/neoformat'
"let g:neoformat_enabled_cpp = ['clang-format']
"let g:neoformat_enabled_cmake = ['cmake-format']

"augroup fmt
"  autocmd!
"  autocmd BufWritePre * undojoin | Neoformat
"augroup END

Plug 'preservim/nerdcommenter'

Plug 'luochen1990/rainbow'
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
let g:rainbow_conf = {
\   'separately': {
\       'cmake': 0,
\   }
\}

Plug 'sakhnik/nvim-gdb', { 'do': ':!./install.sh \| UpdateRemotePlugins' }

" Themes
Plug 'ajmwagar/vim-deus'
Plug 'JBakamovic/yaflandia'
Plug 'joshdick/onedark.vim'
Plug 'nanotech/jellybeans.vim'
Plug 'cocopon/iceberg.vim'
Plug 'arcticicestudio/nord-vim'

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
nnoremap <leader>k :ls u+<CR>:ls<CR>:b<Space>

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
nnoremap <Tab> :bnext<CR>:redraw<CR>:ls u+<CR>:ls<CR>
nnoremap <S-Tab> :bprevious<CR>:redraw<CR>:ls u+<CR>:ls<CR>

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
  CocDisable

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

  CocEnable
endfunction

"------------------------------------------------------------------------------
"coc.vim begin
"------------------------------------------------------------------------------
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Abort tab completion if backspace is pressed
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <S-space> to trigger signature help
function! ShowSignature()
  call CocActionAsync('showSignatureHelp')
endfunction

inoremap <C-s> <ESC>:call ShowSignature()<CR><Right><insert>

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if has('patch8.1.1068')
  " Use `complete_info` if your (Neo)Vim version supports it.
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Expand macro
nnoremap <leader>aa :CocAction<CR>

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
"xmap <leader>f  <Plug>(coc-format-selected)

" Formatting selected code.
"xmap <leader>f  <Plug>(coc-format-selected)
"nmap <leader>f  <Plug>(coc-format-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for selections ranges.
" NOTE: Requires 'textDocument/selectionRange' support from the language server.
" coc-tsserver, coc-python are the examples of servers that support it.
"nmap <silent> <TAB> <Plug>(coc-range-select)
"xmap <silent> <TAB> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

"------------------------------------------------------------------------------
"coc.vim end
"------------------------------------------------------------------------------
