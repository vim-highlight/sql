if exists("g:autoload_vim_highlight_core_options")
    finish
endif
let g:autoload_vim_highlight_core_options = 1

" getValue : get option value {{{
function! vim_highlight#core#options#getValue (name, defaultValue)
    if exists('b:sql_'.a:name)
        return b:{'sql_'.a:name}
    elseif exists('g:sql_'.a:name)
        return g:{'sql_'.a:name}
    else
        return a:defaultValue
    endif
endfunction
" }}}
    
" boolToString : concert bool option in string {{{
function! vim_highlight#core#options#boolToString (options, name)
    let l:str = ''

    if has_key(a:options, a:name)
        if type(get(a:options, a:name)) == type(0)
            if get(a:options, a:name) == 1
                let l:str = l:str.' '.a:name
            endif
        endif
    endif

    return l:str
endfunction
" }}}
" listToString : convert list option in string {{{
function! vim_highlight#core#options#listToString (options, name)
    let l:str = ''

    if has_key(a:options, a:name)
        let l:option = vim_highlight#core#utils#listToString(get(a:options, a:name), ',')
        if len(l:option) > 0
            let l:str = l:str.' '.a:name.'='.vim_highlight#core#utils#listToString(get(a:options, a:name), ',')
        endif
    endif

    return l:str
endfunction
" }}}


" commonToString : common options {{{
function! vim_highlight#core#options#getForCommon (options)
    let l:str = ''

    let l:options = deepcopy(g:vim_highlight#core#options#default#common)
    call extend(l:options, a:options, 'force')

    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'contained'  )
    let l:str = l:str.vim_highlight#core#options#listToString(l:options, 'containedin')
    let l:str = l:str.vim_highlight#core#options#listToString(l:options, 'nextgroup'  )
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'transparent')
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'skipwhite'  )
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'skipnl'     )
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'skipempty'  )

    return l:str
endfunction
" }}}
" keywordToString : keyword options {{{
function! vim_highlight#core#options#getForKeyword (options)
    let l:str = ''
    
    let l:options = deepcopy(g:vim_highlight#core#options#default#keyword)
    call extend(l:options, a:options, 'force')

    let l:str = l:str.vim_highlight#core#options#getForCommon(l:options)

    return l:str
endfunction
" }}}
" matchToString : match options {{{
function! vim_highlight#core#options#getForMatch (options)
    let l:str = ''

    let l:options = deepcopy(g:vim_highlight#core#options#default#match)
    call extend(l:options, a:options, 'force')

    let l:str = l:str.vim_highlight#core#options#getForCommon(l:options)

    let l:str = l:str.vim_highlight#core#options#listToString(l:options, 'contains')
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'fold'    )
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'display' )
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'extend'  )
    
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'excludenl')

    return l:str
endfunction
" }}}
" regionToString : region options {{{
function! vim_highlight#core#options#getForRegion (options)
    let l:str = ''

    let l:options = deepcopy(g:vim_highlight#core#options#default#region)
    call extend(l:options, a:options, 'force')

    let l:str = l:str.vim_highlight#core#options#getForCommon(l:options)

    let l:str = l:str.vim_highlight#core#options#listToString(l:options, 'contains')
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'oneline' )
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'fold'    )
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'display' )
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'extend'  )
    
    let l:str = l:str.vim_highlight#core#options#listToString(l:options, 'matchgroup')
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'keepend'   )
    let l:str = l:str.vim_highlight#core#options#boolToString(l:options, 'excludenl' )

    return l:str
endfunction
" }}}
