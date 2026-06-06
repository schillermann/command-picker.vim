vim9script

var filtered_items: list<any> = []
var current_command_list: list<any> = []
var current_filter: string = ""
var filter_title: string = ""
var max_desc_width: number = 30

def InitProps()
    if empty(prop_type_get('CommandTemplatesDesc'))
        prop_type_add('CommandTemplatesDesc', {highlight: 'Identifier'})
    endif
    if empty(prop_type_get('CommandTemplatesCmd'))
        prop_type_add('CommandTemplatesCmd', {highlight: 'Statement'})
    endif
    if empty(prop_type_get('CommandTemplatesSep'))
        prop_type_add('CommandTemplatesSep', {highlight: 'Comment'})
    endif
enddef

def UpdateMaxDescWidth(items: list<any>)
    var max_w = 20
    for item in items
        var w = strdisplaywidth(item[0])
        if w > max_w
            max_w = w
        endif
    endfor
    max_desc_width = min([max_w, 50])
enddef

def FormatLine(_: any, val: list<any>): dict<any>
    var desc = val[0]
    if strdisplaywidth(desc) > max_desc_width
        desc = strcharpart(desc, 0, max_desc_width - 3) .. "..."
    endif
    var padding = repeat(' ', max_desc_width - strdisplaywidth(desc) + 4)
    var cmd = val[1]
    var text = desc .. padding .. cmd
    
    return {
        text: text,
        props: [
            {col: len(desc) + len(padding) + 1, length: len(cmd), type: 'CommandTemplatesCmd'}
        ]
    }
enddef

def CommandSelected(id: number, result: number)
    if result <= 0 || result > len(filtered_items)
        return
    endif

    var match_item = filtered_items[result - 1]

    var keys = $":{match_item[1]}"
    if len(match_item) > 2
        var moves: number = match_item[2]
        keys ..= repeat("\<Left>", moves)
    endif
    feedkeys(keys, 'nt')
enddef

def FilterMenu(id: number, key: string): bool
    var handled = false
    if key == "\<BS>" || key == "\<C-h>"
        var filter_len = strchars(current_filter)
        current_filter = (filter_len > 0) ? strcharpart(current_filter, 0, filter_len - 1) : ""
        handled = true
    elseif key == "\<C-u>"
        current_filter = ""
        handled = true
    elseif key =~ '^\p$'
        current_filter ..= key
        handled = true
    else
        handled = popup_filter_menu(id, key)
    endif

    if handled && (key =~ '^\p$' || key == "\<BS>" || key == "\<C-h>" || key == "\<C-u>")
        var fuzzy = substitute(current_filter, ' ', '.*', 'g')
        filtered_items = []
        for item in current_command_list
            if item[0] =~? fuzzy || item[1] =~? fuzzy
                add(filtered_items, item)
            endif
        endfor

        var display = mapnew(filtered_items, FormatLine)
        popup_settext(id, display)
        popup_setoptions(id, {title: $" {filter_title}: {current_filter} "})
    endif

    return true
enddef

export def Open(command_list: list<any>, opts: dict<any> = {})
    InitProps()
    current_command_list = command_list
    UpdateMaxDescWidth(current_command_list)
    filtered_items = copy(current_command_list)
    current_filter = ""
    filter_title = get(opts, 'title', 'Command Filter')

    var options = mapnew(filtered_items, FormatLine)

    var popup_opts: dict<any> = {
        callback: CommandSelected,
        filter: FilterMenu,
        title: $" {filter_title}:  ",
        border: [1, 1, 1, 1],
        padding: [0, 1, 0, 1],
        cursorline: true,
        minwidth: 60,
        highlight: get(opts, 'highlight', 'Normal'),
        borderhighlight: get(opts, 'borderhighlight', ['Normal']),
    }

    var bstyle = get(opts, 'borderstyle', 'rounded')
    if bstyle == 'double'
        popup_opts['borderchars'] = ['═', '║', '═', '║', '╔', '╗', '╝', '╚']
    elseif bstyle == 'thick'
        popup_opts['borderchars'] = ['━', '┃', '━', '┃', '┏', '┓', '┛', '┗']
    elseif bstyle == 'rounded'
        popup_opts['borderchars'] = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']
    elseif bstyle == 'ascii'
        popup_opts['borderchars'] = ['-', '|', '-', '|', '+', '+', '+', '+']
    elseif bstyle == 'single'
        popup_opts['borderchars'] = ['─', '│', '─', '│', '┌', '┐', '┘', '└']
    endif

    popup_menu(options, popup_opts)
enddef
