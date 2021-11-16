" Vim syntax file
augroup lifetrak_settings " {
	autocmd!
	autocmd FileType lft :set linebreak
	autocmd FileType lft :set nohls
	autocmd FileType lft :set nospell
    autocmd FileType lft nmap <Leader>je :call <SID>JournalEntry()<cr>
    autocmd FileType lft nmap <Leader>jt :call <SID>ChooseATag()<cr>
	autocmd FileType lft nnoremap <Leader>jd :execute "normal! /^---$\rzt:nohlsearch\r"<cr>
	autocmd FileType lft nnoremap <Leader>ju :execute "normal! ?^---$\rzt:nohlsearch\r"<cr>
augroup END " }

set syntax=lft

syn match journalEntryTop /--.*/
syn match journalEntryTop /#.*/
hi def link journalEntryTop Special

syn match journalEntryMeta /-\s.*/
hi def link journalEntryMeta Comment 

syn match journalEntryTags /-\stags:\s\w.*/
hi def link journalEntryTags Identifier 
