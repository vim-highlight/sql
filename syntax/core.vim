" Vim-highlight core functions
" Language:     -
" Maintainer:   Julien Rosset <jul.rosset@gmail.com>
"
" URL:          https://github.com/vim-highlight/sql/
" Version:      0.0.1

if exists("b:vim_highlight")
  finish
endif

let b:vim_highlight = {}
" OPTIONS: {{{
let b:vim_highlight.options {}
    " CORE: {{{
let b:vim_highlight.options.core = {}
        " getOption : get value for an option {{{
function b:vim_highlight.options.core.getOption (name, defaultValue)
    if exists('b:sql_'.a:name)
        return b:{'sql_'.a:name}
    elseif exists('g:sql_'.a:name)
        return g:{'sql_'.a:name}
    else
        return a:defaultValue
    endif
endfunction
        " }}}
        " options type functions {{{
            " boolOption : get bool option {{{
function s:vim_highligt.options.core.boolOption (options, name)
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
function s:vim_highligt.options.core.listOption (options, name)
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
        " }}}
        " options functions {{{
            " commonToString : common options {{{
function b:vim_highlight.options.core.commonToString (options)
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
function b:vim_highlight.options.core.keywordToString (options)
    let l:str = ''

    let l:str = l:str.commonToString(a:options)

    return l:str
endfunction
            " }}}
            " matchToString : match options {{{
function b:vim_highlight.options.core.matchToString (options)
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
function b:vim_highlight.options.core.regionToString (options)
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
        " }}} 
    " }}}
" }}}
