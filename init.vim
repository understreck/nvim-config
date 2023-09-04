call plug#begin(stdpath('data') . '/plugged')
Plug 'neovim/nvim-lspconfig'
Plug 'p00f/clangd_extensions.nvim'
Plug 'hrsh7th/nvim-compe'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

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
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} 


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

let mapleader='\'

colorscheme onedark

syntax enable

set mouse=a
set expandtab
set shiftwidth=4
set tabstop=4               "tabs are 2 columns wide
set softtabstop=4           "removes spaces on <BS> as if it was a tab
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

nnoremap <A-Tab> <<
vnoremap <A-Tab> <<
inoremap <A-Tab> <C-d>

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
  return bufname() == "" || bufname() == "[Scratch]"
endfunction

function! LeaveWindow()
  if BufferEmpty() && UnnamedBuffer()
    bdelete
    echo "Yeeted empty buffer"
  elseif w:rotateFlag == 0
    wincmd K
  endif
endfunction

function! ValidWindow()
  let winConfig = nvim_win_get_config(0)

  return !exists('b:isList') && empty(winConfig['relative'])
endfunction

augroup manageWindows
  autocmd!
  autocmd FileType list let b:isList=1
  autocmd WinEnter,BufEnter * let w:rotateFlag=0
  autocmd WinEnter,BufEnter * if ValidWindow() | call EnterWindow()
  autocmd WinLeave,BufLeave * if ValidWindow() | call LeaveWindow()
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

nnoremap <silent> <leader>wf  :call ResizeWindow()<CR>

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

"------------------------------------------------------------------------------
"lsp-config
"------------------------------------------------------------------------------
lua << EOF
local lspconfig = require('lspconfig')
local configs = require('lspconfig/configs')
local util = require('lspconfig/util')

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>d', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'g]', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', 'g[', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', 'qq', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  -- Set autocommands conditional on server_capabilities
for _,client in ipairs(vim.lsp.get_active_clients()) do
  if client.resolved_capabilities.document_highlight then
    vim.cmd [[autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()]]
    vim.cmd [[autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()]]
    vim.cmd [[autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()]]
    break -- only add the autocmds once
  end
end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end
  
  local check_back_space = function()
      local col = vim.fn.col('.') - 1
      if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
          return true
      else
          return false
      end
  end
  
  -- Use (s-)tab to:
  --- move to prev/next item in completion menuone
  --- jump to prev/next snippet's placeholder
  _G.tab_complete = function()
    if vim.fn.pumvisible() == 1 then
      return t "<C-n>"
    elseif vim.fn.call("vsnip#available", {1}) == 1 then
      return t "<Plug>(vsnip-expand-or-jump)"
    elseif check_back_space() then
      return t "<Tab>"
    else
      return vim.fn['compe#complete']()
    end
  end
  _G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
      return t "<C-p>"
    elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
      return t "<Plug>(vsnip-jump-prev)"
    else
      return t "<S-Tab>"
    end
  end
  
  vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
  vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
  vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
  vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
end

--if not lspconfig.hdl_checker then
-- configs.hdl_checker = {
--   default_config = {
--      cmd = {"hdl_checker", "--lsp", };
--      filetypes = {"vhdl", "verilog", "systemverilog"};
--      root_dir = function(fname)
--          return
--              lspconfig.util.root_pattern('hdl_checker.config')(fname) or
--              lspconfig.util.path.dirname(fname)
--      end;
--      settings = {};
--   };
-- }
--end

--configs.java_language_server = {
-- default_config = {
--   cmd = {"java-language-server"};
--   root_dir = lspconfig.util.root_pattern("settings.gradle", "pom.xml", ".git");
--   settings = {};
-- };
--};

require'lspconfig'.java_language_server.setup {
    cmd = {"java-language-server"},
    filetypes = {"settings.gradle", "pom.xml", ".git", "java"}
}
-- Use a loop to conveniently both setup defined servers 
-- and map buffer local keybindings when the language server attaches
local servers =
    {"clangd", "vimls", "cmake", "jedi_language_server"}
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup { on_attach = on_attach }
end
EOF

"------------------------------------------------------------------------------
"compe
"------------------------------------------------------------------------------
set completeopt=menuone,noselect

inoremap <silent><expr> <C-Space>   compe#complete()
inoremap <silent><expr> <space>     compe#confirm('<space>')
inoremap <silent><expr> <C-e>       compe#close('<C-e>')

highlight link CompeDocumentation NormalFloat

let g:compe = {}
let g:compe.enabled = v:true
let g:compe.autocomplete = v:true
let g:compe.debug = v:false
let g:compe.min_length = 1
let g:compe.preselect = 'enable'
let g:compe.throttle_time = 80
let g:compe.source_timeout = 200
let g:compe.incomplete_delay = 400
let g:compe.max_abbr_width = 100
let g:compe.max_kind_width = 100
let g:compe.max_menu_width = 100
let g:compe.documentation = v:true

let g:compe.source = {}
let g:compe.source.path = v:true
let g:compe.source.buffer = v:true
let g:compe.source.calc = v:true
let g:compe.source.nvim_lsp = v:true
let g:compe.source.nvim_lua = v:true
let g:compe.source.vsnip = v:true

"------------------------------------------------------------------------------
"compe
"------------------------------------------------------------------------------

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,              -- false will disable the whole extension
  },
}
EOF
