if exists("g:autoload_vim_highlight_core_utils")
    finish
endif
let g:autoload_vim_highlight_core_utils = 1

" listToString : transform string/list to string {{{
function! vim_highlight#core#utils#listToString (valeur, join)
    let l:str = ''

    if type(a:valeur) == type('')
        if len(a:valeur) > 0
            let l:str = a:valeur
        endif
    elseif type(a:valeur) == type([])
        if len(a:valeur) > 0
            let l:str = join(a:valeur, a:join)
        endif
    endif

    return l:str
endfunction
" }}}
