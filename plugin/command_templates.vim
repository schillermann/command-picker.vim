vim9script

if exists('g:loaded_command_templates')
    finish
endif
g:loaded_command_templates = 1

import autoload 'command_templates.vim'

command! -nargs=1 CommandTemplates command_templates.Open(<args>)
