if exists("g:autoload_vim_highlight_core_syntax")
    finish
endif
let g:autoload_vim_highlight_core_syntax = 1

" keyword : declare keyword {{{
function! vim_highlight#core#syntax#keyword (name, highlight, keywords, options)
    let l:keywords = vim_highlight#core#utils#listToString(a:keywords, ' ')

    let l:options = a:options
    let l:options.nextgroup = '@'.a:name.'Next'

    let l:follow = []
    if has_key(l:options, 'follow')
        if type(get(l:options, 'follow')) == type('')
            let l:follow = [ get(l:options, 'follow') ]
        elseif type(get(l:options, 'follow')) == type([])
            let l:follow = get(l:options, 'follow')
        endif
    endif

    execute 'syntax keyword '.a:name.' '.vim_highlight#core#options#getForKeyword(l:options).' '.l:keywords
    execute 'highlight default link '.a:name.' '.a:highlight

    for l:curr in l:follow
        execute 'syntax cluster '.l:curr.'Next add='.a:name
    endfor

    return a:name
endfunction
" }}}
