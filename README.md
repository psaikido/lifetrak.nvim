# Lifetrak - keep a journal in vi

A vim/neovim plugin to provide utilities for keeping a journal.  

## Setup
Packer  
`use {'psaikido/lifetrak.nvim'}`

Make a file with a '.lft' extension eg. 'journal.lft'. 
Open it and then use these commands via the suggested mappings


## Default keymaps
The following mappings are set in an autocmd block in the main source code.

- 'leader'+ le = JournalEntry() - make a new journal entry with today's date and an id.  
- 'leader'+ lt = ChooseATag() - filter any populated 'tags' entries to a new window.
- 'leader'+ ld = ViewDown() - move down one journal entry.
- 'leader'+ lu = ViewUp() - move up one journal entry.


## Tags
vim.opts.lifetrak_metas = {'energy', 'pain', 'mood', 'sleep'}
