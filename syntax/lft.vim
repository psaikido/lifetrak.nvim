" Vim syntax file.
"
" A raw journal entry looks like this:
"    ---
"    # 2021-11-16
"    - id: 1356
"    - energy: 
"    - pain: 
"    - mood: 
"    - sleep: 
"    - tags: 

set syntax=lft

"Top two lines hilighted
syn match journalEntryTop /^--.*/
syn match journalEntryTop /^#.*/
syn match journalEntryTop /^\s.*id:\s.*/
hi def link journalEntryTop Special

"Hyphenated list of meta data (keys: values) in commented colour.
syn match journalEntryMeta /^-\s\w*:\s.*/
hi def link journalEntryMeta Comment 

"Tags item blue if populated.
syn match journalEntryTags /-\stags:\s\w.*/
hi def link journalEntryTags Statement 
