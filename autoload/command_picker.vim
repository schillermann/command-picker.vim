vim9script

var filtered_items: list<any> = []
var current_command_list: list<any> = []

def FormatLine(_: any, val: list<any>): string
    return printf("%-30s :%s", val[0], val[1])
enddef

def CommandSelected(id: number, result: number)
    var buf = winbufnr(id)
    var lines = getbufline(buf, result)

    if empty(lines) || empty(trim(lines[0]))
        return
    endif

    var selected_text = lines[0]
    var desc = substitute(selected_text, '\s\+:.*$', '', '')

    var match_item: list<any> = []
    for item in filtered_items
        if item[0] == desc
            match_item = item
            break
        endif
    endfor

    if !empty(match_item)
        var keys = $":{match_item[1]}"
        if len(match_item) > 2
            var moves: number = match_item[2]
            keys ..= repeat("\<Left>", moves)
        endif
        feedkeys(keys, 'nt')
    endif
enddef

def FilterMenu(id: number, key: string): bool
    var win_cfg = popup_getoptions(id)
    var current_filter = substitute(win_cfg.title, '^ Command Filter: \(.*\) $', '\1', '')

    var handled = false
    if key == "\<BS>"
        var filter_len = strlen(current_filter)
        current_filter = (filter_len > 0) ? slice(current_filter, 0, filter_len - 1) : ""
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

    if handled && key =~ '^\p$\|\<BS\>\|\<C-u\>'
        var fuzzy = substitute(current_filter, ' ', '.*', 'g')
        filtered_items = []
        for item in current_command_list
            if item[0] =~? fuzzy || item[1] =~? fuzzy
                add(filtered_items, item)
            endif
        endfor

        var display = mapnew(filtered_items, FormatLine)
        popup_settext(id, display)
        popup_setoptions(id, {title: $" Command Filter: {current_filter} "})
    endif

    return true
enddef

export def Open(command_list: list<any>, opts: dict<any> = {})
    current_command_list = command_list
    filtered_items = copy(current_command_list)
    var options = mapnew(filtered_items, FormatLine)

    var popup_opts: dict<any> = {
        callback: CommandSelected,
        filter: FilterMenu,
        title: has_key(opts, 'title') ? $" {opts['title']} " : ' Command Filter:  ',
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
