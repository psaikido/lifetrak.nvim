# Lifetrak - keep a journal in vi

A vim/neovim plugin to provide utilities for keeping a journal.  

## Setup
Packer  
`use {'psaikido/lifetrak.nvim'}`

Make a file with a '.lft' extension eg. 'journal.lft'. 
Open it and then use these commands via the suggested mappings


## Default keymaps
The following mappings are set in an autocmd block in the main source code.

- 'leader'+ le = journal_entry() - make a new journal entry with today's date and an id.  
- 'leader'+ lt = choose_a_tag() - filter any populated 'tags' entries to a new window.
- 'leader'+ ld = view_down() - move down one journal entry.
- 'leader'+ lu = view_up() - move up one journal entry.

Commands are also offered. Use:
- :LifetrakEntry - as in 'journal_entry' above
- :LifetrakOpen - give the option to initialise a new journal or just open any existing one
- :LifetrakFilter - as in 'choose_a_tag' above


## Config
require('lifetrak').init({ 
    journal = '~/journal.lft',
    metas = {'energy', 'pain', 'mood', 'sleep'},
})


## Todo
- Add plenary testing
- Use some sort of storage to get latest entry id
- Storage could keep stats to display
- Consider building encryption in
- Allow for multiple journals
