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
" region : declare region {{{
function! vim_highlight#core#syntax#region (name, highlight, start, end, options)
    let l:options = a:options
    let l:options.nextgroup = '@'.a:name.'Next'
    let l:options.matchgroup = a:name.'Match'

    execute 'syntax region '.a:name.' '.vim_highlight#core#options#getForRegion(l:options).' start='.a:start.' end='.a:end
    execute 'highlight default link '.l:options.matchgroup.' '.a:highlight
    
    if has_key(l:options, 'wholehighlight')
        if type(get(l:options, 'wholehighlight')) == type ('')
            if len(get(l:options, 'wholehighlight')) > 0
                execute 'highlight default link '.a:name.' '.a:wholehighlight
            endif
        endif
    endif

    call vim_highlight#core#syntax#follow(a:name, a:options)

    return a:name
endfunction
" }}}

" follow : declare element in followed cluster {{{
function! vim_highlight#core#syntax#follow (name, options)
    let l:follow = []
    if has_key(a:options, 'follow')
        if type(get(a:options, 'follow')) == type('')
            if len(get(a:options, 'follow')) > 0
                let l:follow = [ get(a:options, 'follow') ]
            endif
        elseif type(get(a:options, 'follow')) == type([])
            let l:follow = get(a:options, 'follow')
        endif
    endif
    
    for l:curr in l:follow
        if strpart(l:curr, 0, 1) == '@'
            let l:curr = strpart(l:curr, 1)
        else
            let l:curr = l:curr.'Next'
        endif

        execute 'syntax cluster '.l:curr.' add='.a:name
    endfor
endfunction
" }}}

" predicat : get predicat part {{{
function! vim_highlight#core#syntax#predicat (name, follow)
    let l:predicat = { 'root': a:name, 'start': '@'.a:name.'Start', 'end': '@'.a:name.'End' }

    call vim_highlight#core#syntax#follow(l:predicat.start, { 'follow': a:follow })

    return l:predicat
endfunction
" }}}
