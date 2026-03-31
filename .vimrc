source $VIMRUNTIME/defaults.vim

"colorscheme sorbet

 if &diff
     colorscheme habamax 
     "zaibatsu 
     "elflord
 endif

 
vnoremap <C-c> :w !wl-copy<CR><CR>
nnoremap <leader>c :let @/='\<' . expand('<cword>') . '\>'<CR>:echo searchcount().total . " matches"<CR>

set ignorecase
set smartcase
set backupcopy=yes
set laststatus=2
