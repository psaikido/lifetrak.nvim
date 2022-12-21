" Vim syntax file.
"
" A raw journal entry looks like this:
"    ---
"    # 2021-11-16
"    - id: 1356
"    - tags: 
"    - energy: 
"    - pain: 
"    - mood: 
"    - sleep: 

set syntax=lft

"Top two lines hilighted
syn match journalEntryTop /^--.*/
syn match journalEntryTop /^#.*/
syn match journalEntryTop /^\s.*id:\s.*/
hi def link journalEntryTop Special

"Hyphenated list of meta data (keys: values) in commented colour.
syn match journalEntryMeta /^-\s\w*:\s.*/
hi def link journalEntryMeta Comment 

"Tags item hilight if populated.
syn match journalEntryTags /-\stags:\s\w.*/
hi def link journalEntryTags Identifier 

"set columns=80
set tw=80
