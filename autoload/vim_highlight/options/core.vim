if exists("g:loaded_vim_highlight_options_core_autoload")
    finish
endif
let g:loaded_vim_highlight_options_core_autoload = 1

" getOption : get option value {{{
function! vim_highlight#options#core#getOption (name, defaultValue)
    if exists('b:sql_'.a:name)
        return b:{'sql_'.a:name}
    elseif exists('g:sql_'.a:name)
        return g:{'sql_'.a:name}
    else
        return a:defaultValue
    endif
endfunction
" }}}
    
" boolOption : get bool option {{{
function! vim_highlight#options#core#boolOption (options, name)
    let l:str = ''

    if has_key(a:options, a:name)
        if type(a:options.a:name) == type(0)
            if a:options.a:name == 1
                let l:str = l:str.' '.a:name
            endif
        endif
    endif

    return l:str
endfunction
" }}}
" listOption : get list option {{{
function! vim_highlight#options#core#listOption (options, name)
    let l:str = ''

    if has_key(a:options, a:name)
        if type(a:options.a:name) == type('')
            if len(a:options.a:name) > 0
                let l:str = l:str.' '.a:name.'='.a:options.a:name
            endif
        elseif type(a:options.a:name == type([]))
            if count(a:options.a:name) > 0
                let l:str = l:str.' '.a:name.'='.join(a:options.a:name, ',')
            endif
        endif
    endif

    return l:str
endfunction
" }}}
    
" commonToString : common options {{{
function! vim_highlight#options#core#commonToString (options)
    let l:str = ''

    let l:str = l:str.boolOption(a:options, 'contained')
    let l:str = l:str.listOption(a:options, 'containedin')
    let l:str = l:str.listOption(a:options, 'nextgroup')
    let l:str = l:str.boolOption(a:options, 'transparent')
    let l:str = l:str.boolOption(a:options, 'skipwhite')
    let l:str = l:str.boolOption(a:options, 'skipnl')
    let l:str = l:str.boolOption(a:options, 'skipempty')

    return l:str
endfunction
" }}}
" keywordToString : keyword options {{{
function! vim_highlight#options#core#keywordToString (options)
    let l:str = ''

    let l:str = l:str.commonToString(a:options)

    return l:str
endfunction
" }}}
" matchToString : match options {{{
function! vim_highlight#options#core#matchToString (options)
    let l:str = ''

    let l:str = l:str.commonToString(a:options)
    let l:str = l:str.listOption(a:options, 'contains')
    let l:str = l:str.boolOption(a:options, 'fold')
    let l:str = l:str.boolOption(a:options, 'display')
    let l:str = l:str.boolOption(a:options, 'extend')
    
    let l:str = l:str.boolOption(a:options, 'excludenl')

    return l:str
endfunction
" }}}
" regionToString : region options {{{
function! vim_highlight#options#core#regionToString (options)
    let l:str = ''

    let l:str = l:str.commonToString(a:options)
    let l:str = l:str.listOption(a:options, 'contains')
    let l:str = l:str.boolOption(a:options, 'oneline')
    let l:str = l:str.boolOption(a:options, 'fold')
    let l:str = l:str.boolOption(a:options, 'display')
    let l:str = l:str.boolOption(a:options, 'extend')
    
    let l:str = l:str.listOption(a:options, 'matchgroup')
    let l:str = l:str.boolOption(a:options, 'keepend')
    let l:str = l:str.boolOption(a:options, 'extend')
    let l:str = l:str.boolOption(a:options, 'excludenl')

    return l:str
endfunction
" }}}
