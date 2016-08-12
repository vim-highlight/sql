if exists("g:autoload_vim_highlight_core_syntax")
    finish
endif
let g:autoload_vim_highlight_core_syntax = 1

" keyword : declare keyword {{{
function! vim_highlight#core#syntax#keyword (name, highlight, keywords, options)
    let l:keywords = vim_highlight#core#utils#listToString(a:keywords, ' ')

    execute 'syntax keyword '.a:name.' '.vim_highlight#core#options#getForKeyword(a:options).' '.l:keywords
    execute 'highlight default link '.a:name.' '.a:highlight
endfunction
" }}}
