"Boilerplate for a new journal entry
au BufNewFile,BufRead *.lft set filetype=lft

augroup lifetrak_settings " {
	autocmd!
	autocmd FileType lft :set linebreak
	autocmd FileType lft :set nohls
	autocmd FileType lft :set nospell
    autocmd FileType lft let b:coc_suggest_disable = 1
augroup END " }

