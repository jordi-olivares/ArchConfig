set mouse=a
set relativenumber
set smartindent
set smarttab
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab 
set tabstop=4
set clipboard=unnamed
syntax on
" checks if your terminal has 24-bit color support
if (has("termguicolors"))
    set termguicolors
endif

set t_Co=256
set number
let mapleader=" "

"Plugins install
call plug#begin('~/.vim/plugged')
    " File explorer
    Plug 'scrooloose/NERDTree'    
    " Icons
    Plug 'ryanoasis/vim-devicons'
    "airline
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'

call plug#end()

"Temas de airline
let g:airline_theme='monokai-pro'
"Para agregar ventanas (buffers)
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#left_sep=''
let g:airline#extensions#tabline#left_alt_sep=''
let g:airline#extensions#tabline#formatter='default'
let g:airline_powerline_fonts=1
"Teclas
nmap <C-n> :bnext<CR>
nmap <C-p> :bprevious<CR>
nmap <Leader>nt :NERDTreeFind<CR>
let NERDTreeQuitOnOpen=1
nmap <Leader>t :belowright terminal <CR>
