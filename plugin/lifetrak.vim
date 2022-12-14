if exists('g:loaded_lifetrak') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

au BufNewFile,BufRead *.lft set filetype=lft

augroup lifetrak_settings " {
	autocmd!
	autocmd FileType lft :set linebreak
	autocmd FileType lft :set nohls
	autocmd FileType lft :set nospell
    autocmd FileType lft let b:coc_suggest_disable = 1
augroup END " }

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_lifetrak = 1
