" Jag's .vimrc
" Used for developing in python, C++, bash, and make files
" Used snippits from vimbits, and Martin Brochhaus' pycon talk
" vim as a Python IDE see: https://github.com/mbrochh/vim-as-a-python-ide.git

" Automatic reloading of .vimrc (when editing)
autocmd! bufwritepost .vimrc source %

" Better copy & paste
" When you want to paste large blocks of code into vim, press F2 before you
" paste. At the bottom you should see ``-- INSERT (paste) --``.
set pastetoggle=<F2>
set clipboard=unnamed



" Allow the mouse to play
set mouse=a  " on OSX press ALT and click


" Rebind <Leader> key
let mapleader = ";"

" Bind nohl
" Removes highlight of your last search
noremap <C-n> :nohl<CR>
vnoremap <C-n> :nohl<CR>
inoremap <C-n> :nohl<CR>


" bind Ctrl+<movement> keys to move around the windows, instead of using Ctrl+w + <movement>
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h

" easier moving between tabs
map <Leader>n <esc>:bp<CR>
map <Leader>m <esc>:bn<CR>

" easier moving between buffers
map <Leader>l <esc>:bnext<CR>
map <Leader>h <esc>:bprevious<CR>


" map sort function to a key
vnoremap <Leader>s :sort<CR>

" easier moving of code blocks in visual mode - without this
" you lose the highlight when you want to indent multiple times
vnoremap < <gv  " better indentation
vnoremap > >gv  " better indentation

" Smart indenting
set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class

" Showing line numbers and length
set number  " show line numbers
set tw=119   " width of document (used by gd)
" set nowrap  " don't automatically wrap on load
" set fo-=t   " don't automatically wrap text when typing
set cursorline
autocmd InsertEnter * highlight CursorLine guifg=brown guibg=blue ctermfg=None ctermbg=None cterm=bold
autocmd InsertLeave * highlight CursorLine guifg=white guibg=darkblue ctermfg=None ctermbg=None


" Flake8
autocmd FileType python map <buffer> <Leader>p :call Flake8()<CR>
" let g:flake8_ignore="E501,W293"

" Conque
let g:ConqueTerm_FastMode = 0
let g:ConqueTerm_ReadUnfocused = 1
let g:ConqueTerm_CWInsert = 1
let g:ConqueTerm_ExecFileKey = '<F6>'
map <Leader>e <F9>
map <Leader>ef <F6>


" Highlight end of line whitespace.
highlight WhitespaceEOL ctermbg=red guibg=red
match WhitespaceEOL /\s\+$/

" let python_highlight_all = 1

" Prep for vundle
filetype off
" Vundle config
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Vundle plugins
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-scripts/vtreeexplorer'
Plugin 'nvie/vim-flake8'
" Plugin 'Lokaltog/vim-powerline'
Plugin 'vim-airline/vim-airline'
Plugin 'kien/ctrlp.vim'
Plugin 'davidhalter/jedi-vim'
Plugin 'vim-scripts/Conque-Shell'
Plugin 'majutsushi/tagbar'
Plugin 'vim-scripts/bufferlist.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'morhetz/gruvbox'
Plugin 'kshenoy/vim-signature'
Plugin 'airblade/vim-gitgutter'
Plugin 'mileszs/ack.vim'
Plugin 'alfredodeza/pytest.vim'
Plugin 'sjl/gundo.vim'
Plugin 'MarcWeber/vim-addon-local-vimrc'
Plugin 'scrooloose/nerdtree'
Plugin 'fatih/vim-go'
Plugin 'vim-airline/vim-airline-themes'


" End of vundle section filetypes back on
filetype plugin indent on
syntax on
" easier formatting of paragraphs
"" vmap Q gq
"" nmap Q gqap


" History/undo length
set history=700
set undolevels=700


" Use spaces not TABs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set expandtab

" Make needs TABs
autocmd FileType make  set noexpandtab

" Prettyfy XML and JSON
autocmd FileType xml exe ":silent 1,$!xmllint --format --recover - 2>/dev/null"
com! FormatJSON %!python -m json.tool

" Make search case insensitive
set hlsearch
set incsearch
set ignorecase
set smartcase

" Marks on
let g:showmarks_enable=1

" Terminal stuff and colour scheme
set t_Co=256
highlight Normal ctermbg=NONE
highlight nonText ctermbg=NONE

" Work to 120 character line length
set colorcolumn=120
highlight ColorColumn ctermbg=green

" ============================================================================
" Specific Python IDE Setup
" ============================================================================

" Ack
nmap <leader>g <Esc>:Ack!

" Gundo
map <leader>l :GundoToggle<CR>

" Settings for vim-powerline !!!
set laststatus=2
set encoding=utf-8
let g:Powerline_symbols = 'compatible'

" Settings for ctrlp
let g:ctrlp_max_height = 30
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=*/coverage/*

" Settings for jedi-vim
" cd ~/.vim/bundle
" git clone git://github.com/davidhalter/jedi-vim.git
let g:jedi#usages_command = "<leader>z"
let g:jedi#popup_on_dot = 0
let g:jedi#popup_select_first = 0
map <Leader>h <esc><s-k>
map <Leader>b Oimport ipdb; ipdb.set_trace() # BREAKPOINT<C-c>

" Pytest plugin
" Execute the tests
nmap <silent><Leader>tf <Esc>:Pytest file<CR>
nmap <silent><Leader>tc <Esc>:Pytest class<CR>
nmap <silent><Leader>tm <Esc>:Pytest method<CR>
" cycle through test errors
nmap <silent><Leader>tn <Esc>:Pytest next<CR>
nmap <silent><Leader>tp <Esc>:Pytest previous<CR>
nmap <silent><Leader>te <Esc>:Pytest error<CR>

" airline plugin
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_section_y = 'BN: %{bufnr("%")}'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

" Tagbar
map <Leader>t :TagbarToggle<CR>

" Nerdtree
map <silent>  <Leader>a :NERDTreeToggle<CR>

" GitGutter
let g:gitgutter_sign_column_always = 1

" Buffer list
map <silent>  <Leader>f :call BufferList()<CR>
let g:BufferListWidth = 25
let g:BufferListMaxWidth = 50
hi BufferSelected term = reverse ctermfg=white ctermbg=red cterm=bold
hi BufferNormal term = NONE ctermfg=black ctermbg=darkcyan cterm=NONE

" Better navigating through omnicomplete option list
" See http://stackoverflow.com/questions/2170023/how-to-map-keys-for-popup-menu-in-vim
set completeopt=longest,menuone
function! OmniPopup(action)
  if pumvisible()
    if a:action == 'j'
      return "\<C-N>"
    elseif a:action == 'k'
      return "\<C-P>"
    endif
  endif
  return a:action
endfunction
inoremap <silent><C-j> <C-R>=OmniPopup('j')<CR>
inoremap <silent><C-k> <C-R>=OmniPopup('k')<CR>

" Static analysis
autocmd BufWritePost *.py call Flake8()

set nofoldenable


" Auto completion via ctrl-space (instead of the nasty ctrl-x ctrl-o)
" set omnifunc=pythoncomplete#Complete
" inoremap <Nul> <C-x><C-o>

