"Boilerplate for a new journal entry
au BufNewFile,BufRead *.lft set filetype=lft

let s:metas = ['energy', 'pain', 'mood', 'sleep']

augroup lifetrak_settings " {
	autocmd!
	autocmd FileType lft :set linebreak
	autocmd FileType lft :set nohls
	autocmd FileType lft :set nospell
    autocmd FileType lft nmap <Leader>je :call <SID>JournalEntry()<cr>
    autocmd FileType lft nmap <Leader>jt :call <SID>ChooseATag()<cr>
	autocmd FileType lft nnoremap <Leader>jd :call <SID>ViewDown()<cr>
	autocmd FileType lft nnoremap <Leader>ju :call <SID>ViewUp()<cr>
augroup END " }

function! s:ViewDown() abort
    execute "normal! /^---$\rzt:nohlsearch\r"
endfunction

function! s:ViewUp() abort
    execute "normal! ?^---$\rzt:nohlsearch\r"
endfunction

function! s:JournalEntry() abort
    "Increment the id.
    "First find the last one and yank it into register '0'.
    "Once found, increment and save it to insert later.
    normal! gg0jjwww"0yiW
    let nextId = @0 + 1

    normal! ggO
    normal! O
    normal! O
    normal! O

    let hdrDelim = '---'
    let hdrDate =  '# ' . strftime('%Y-%m-%d')
    let hdrId =    '# id: ' . nextId
    let lstTop = [hdrDelim, hdrDate, hdrId]

    let lstMeta = s:DoMeta()

    let hdrList = lstTop + lstMeta
    call append(0, hdrList)
endfunction

function s:DoMeta() abort
    let formattedMetas = []

    for m in s:metas
        let strMeta = '- ' . m . ': '
        call add(formattedMetas, strMeta)
    endfor

    call add(formattedMetas, '- tags: ')
    return formattedMetas 
endfunction

"Filter by tag, output to new split
function! s:JournalFilter(searchTerm) abort
    call cursor(1,1)
    let str = 'tags:.*' . a:searchTerm
    let matches = []

    "clear register 'a' 
    normal! qaq
    execute 'g/' . str . '/call add(matches, line("."))'

    for m in matches
        call s:GetSurroundingEntry(m) 
    endfor

    call s:OutputFilteredResults()
endfunction

function! s:GetSurroundingEntry(lineNumber) abort
    call cursor(a:lineNumber, 1)
    "Go to first blank line above, select to next block and save in register
    "'a'
    normal! {jV/---k"Ay
endfunction

function! s:OutputFilteredResults() abort
    setlocal splitright
    set filetype=lft
    "set buftype=nofile
    vsplit filter_journal.lft
    normal! ggVGd"ap
    setlocal buftype=
endfunction

function! s:GetTags() abort
    call cursor(1,1)
    let tags = 'tags: '
    let tag = ''
    let arTags = []
    let uniqueTags = []

    "clear register 'a' 
    normal! qaq
    "Find the tag strings and load them into array arTags
    execute 'g/' . tags . '/call add(arTags, getline(line(".")))'

    for i in arTags
        "Clean the string to leave just the tags themselves.
        let tag = substitute(i, '- tags: ', '', '')

        "Some tag strings have multiple comma separated values
        let lump = split(tag, ',')

        for item in lump
            let t = trim(item)
            if s:IsUnique(uniqueTags, t)
                call add(uniqueTags, t)
            endif
        endfor
    endfor

    return uniqueTags
endfunction

function! s:IsUnique(uniqueTags, tag) abort
    for j in a:uniqueTags
        if j == a:tag
            return 0
        endif
    endfor

    return 1
endfunction

function! s:ChooseATag()
    let tags = s:GetTags()
    let choiceString = join(tags, "\n&")
    let choice = confirm('tag?', choiceString, '', 'Q')
    call s:JournalFilter(tags[choice - 1])
endfunction

