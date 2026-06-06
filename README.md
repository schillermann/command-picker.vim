# Command Templates

A simple, fuzzy-searchable command templates picker for executing Vim commands.

## Installation

Move this folder to your Vim package directory:
`~/.vim/pack/my_category/start/command-templates`

## Usage

### In Vim9Script
```vim
import autoload 'command_templates.vim'

const my_commands = [
    ['search and replace on line under cursor', 's/old/new/g', 9],
    ['search and replace in file', '%s/old/new/g'],
    ['search and replace in file with confirmation', '%s/old/new/gc'],
    ['search and replace in file with last search', '%s//new/g'],
]

# You can optionally pass a dictionary to customize the appearance:
const opts = {
    title: ' My Commands ',      # Custom title text
    highlight: 'Normal',        # Background and text color
    borderhighlight: ['Normal'], # Border color
    borderstyle: 'rounded',      # Border shape (single, double, thick, rounded, ascii)
}

command_templates.Open(my_commands, opts)
```

### Via Command

```vim
:CommandTemplates [['search and replace on line under cursor', 's/old/new/g', 9], ['search and replace in file', '%s/old/new/g']]
```

### Configuration Options (`opts`)

The `Open` function accepts an optional second argument—a dictionary to customize the appearance of the popup window:

- `highlight`: (String) The highlight group for the background and text. Defaults to `'Normal'`.
- `borderhighlight`: (List of Strings) The highlight group for the border. Defaults to `['Normal']`.
- `borderstyle`: (String) A ready-made style name. Defaults to `'rounded'`.
- `title`: (String) Custom title text for the popup.

#### Common Background Colors (Highlight Groups)

You can use any highlight group defined in your Vim setup.
To see all available groups, run `:hi` in Vim. Common ones include:

| Group Name | Description |
| :--- | :--- |
| `Pmenu` | Default popup background (usually dark gray) |
| `Normal` | Standard editor background |
| `Search` | Highlighted search background (usually yellow/bright) |
| `Visual` | Selection background |
| `Folded` | Background used for folded lines |
| `ErrorMsg` | Error background (usually red) |
| `WarningMsg` | Warning background (usually yellow/orange) |

#### Common Border Styles (`borderstyle`)

| Style Name | Description |
| :--- | :--- |
| `'single'` | Default single-line border |
| `'double'` | Double-line border |
| `'thick'` | Thick single-line border |
| `'rounded'` | Single-line border with rounded corners |
| `'ascii'` | Simple ASCII border |

## Structure of Command List

Each item in the list is a sub-list:
`[description, command, cursor_offset]`

- `description`: The text shown in the menu.
- `command`: The command to be executed (without the leading colon).
- `cursor_offset`: (Optional) Number of characters to move the cursor to the left after inserting the command. Useful for commands where you need to fill in values.
