vim9script

if exists('g:loaded_command_picker')
    finish
endif
g:loaded_command_picker = 1

import autoload 'command_picker.vim'

command! -nargs=1 CommandPicker command_picker.Open(<args>)
