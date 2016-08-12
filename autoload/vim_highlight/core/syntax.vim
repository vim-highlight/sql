if exists("g:autoload_vim_highlight_core_syntax")
    finish
endif
let g:autoload_vim_highlight_core_syntax = 1

" keyword : declare keyword {{{
function! vim_highlight#core#syntax#keyword (name, highlight, keywords, options)
    let l:keywords = vim_highlight#core#utils#listToString(a:keywords, ' ')

    let l:options = a:options
    let l:options.nextgroup = '@'.a:name.'Next'

    execute 'syntax keyword '.a:name.' '.vim_highlight#core#options#getForKeyword(l:options).' '.l:keywords
    execute 'highlight default link '.a:name.' '.a:highlight

    call vim_highlight#core#syntax#follow(a:name, a:options)

    return a:name
endfunction
" }}}
" match : declare match {{{
function! vim_highlight#core#syntax#match (name, highlight, pattern, options)
    let l:options = a:options
    let l:options.nextgroup = '@'.a:name.'Next'

    execute 'syntax match '.a:name.' '.vim_highlight#core#options#getForMatch(l:options).' '.a:pattern
    execute 'highlight default link '.a:name.' '.a:highlight

    call vim_highlight#core#syntax#follow(a:name, a:options)

    return a:name
endfunction
" }}}

" follow : declare element in followed cluster {{{
function! vim_highlight#core#syntax#follow (name, options)
    let l:follow = []
    if has_key(a:options, 'follow')
        if type(get(a:options, 'follow')) == type('')
            let l:follow = [ get(a:options, 'follow') ]
        elseif type(get(a:options, 'follow')) == type([])
            let l:follow = get(a:options, 'follow')
        endif
    endif
    
    for l:curr in l:follow
        execute 'syntax cluster '.l:curr.'Next add='.a:name
    endfor
endfunction
" }}}
