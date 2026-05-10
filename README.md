# vim-command-picker

A simple, fuzzy-searchable popup menu for executing Vim commands.

## Installation

Move this folder to your Vim package directory:
`~/.vim/pack/custom/start/vim-command-picker`

## Usage

### In Vim9Script

```vim
import autoload 'command_picker.vim'

const my_commands = [
    ['search and replace on line under cursor', 's/old/new/g', 9],
    ['search and replace in file', '%s/old/new/g'],
    ['search and replace in file with confirmation', '%s/old/new/gc'],
    ['search and replace in file with last search', '%s//new/g'],
]

command_picker.Open(my_commands)
```

### Via Command

```vim
:CommandPicker [['search and replace on line under cursor', 's/old/new/g', 9], ['search and replace in file', '%s/old/new/g']]
```

## Structure of Command List

Each item in the list is a sub-list:
`[description, command, cursor_offset]`

- `description`: The text shown in the menu.
- `command`: The command to be executed (without the leading colon).
- `cursor_offset`: (Optional) Number of characters to move the cursor to the left after inserting the command. Useful for commands where you need to fill in values.
