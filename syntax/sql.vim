" Vim syntax file for SQL
" Language:     SQL standard / Support for drivers specifics
" Maintainer:   Julien Rosset <jul.rosset@gmail.com>
"
" URL:          https://github.com/vim-highlight/sql/
" Version:      0.0.1

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Initialize options {{{
let s:driver         = vim_highlight#core#options#getValue('driver'        , '')
let s:case_sensitive = vim_highlight#core#options#getValue('case_sensitive',  0)
" }}}

" Case matching {{{
if s:case_sensitive
    syntax case match
else
    syntax case ignore
endif
" }}}

call extend(g:vim_highlight#core#options#default#common, { 'skipempty': 1, 'skipnl': 1, 'skipwhite': 1, 'contained': 1 })
call extend(g:vim_highlight#core#options#default#region, { 'keepend': 1 })

let s:predicats = { 'root': 'sql' }

" Error: {{{
let s:predicats.error = vim_highlight#core#syntax#match(s:predicats.root.'Error', 'sqlHiError', '/\S.*/', { 'contained': 0 })
" }}}

" Common: {{{
    " Operator: {{{
        " bracket-round : ( ) {{{
function! s:BracketRound (prefix, middle, options)
    let l:predicat = a:prefix.'BracketRound'

    let l:open  = vim_highlight#core#syntax#match(l:predicat.'Open', 'sqlHiOperator', '/(/', a:options)

    if type(a:middle) == type({})
        let l:middleStart = a:middle.start
        let l:middleEnd   = a:middle.end
    else
        let l:middleStart = a:middle
        let l:middleEnd   = a:middle
    endif

    call vim_highlight#core#syntax#follow(l:middleStart, { 'follow': l:open })

    let a:options.follow = l:middleEnd
    let l:close = vim_highlight#core#syntax#match(l:predicat.'Close', 'sqlHiOperator', '/)/', a:options)

    return l:close
endfunction
        " }}}
        
        " comma : , {{{
function! s:Comma (prefix, options)
    return vim_highlight#core#syntax#match(a:prefix.'Comma', 'sqlHiOperator', '/,/', a:options)
endfunction
        " }}}
        " dot : . {{{
function! s:Dot (prefix, options)
    return vim_highlight#core#syntax#match(a:prefix.'Dot', 'sqlHiOperator', '/\./', a:options)
endfunction
        " }}}
        " star : * {{{
function! s:Star (prefix, options)
    return vim_highlight#core#syntax#match(a:prefix.'Star', 'sqlHiOperator', '/\*/', a:options)
endfunction
        " }}}
    " }}}
    " Variable: {{{
        " table-name {{{
function! s:TableName (prefix, options)
    return vim_highlight#core#syntax#match(a:prefix.'TableName', 'sqlHiVariable', '/\c[a-z_][a-z0-9_]*/', a:options)
endfunction
        " }}}
        " column-name {{{
function! s:ColumnName (prefix, options)
    return vim_highlight#core#syntax#match(a:prefix.'ColumnName', 'sqlHiVariable', '/\c[a-z_][a-z0-9_]*/', a:options)
endfunction
        " }}}
    " }}}
" }}}

" Predicats: {{{
    " common-table-expression {{{
function! s:CommonTableExpression (prefix, follow)
    let l:predicat = vim_highlight#core#syntax#predicat(a:prefix.'CommonTableExpression', a:follow)

    let l:tableName = s:TableName(l:predicat.root, { 'follow': l:predicat.start })

    let l:columnName    = s:ColumnName  (l:predicat.root                          , {                       })
    let l:columnBracket = s:BracketRound(l:predicat.root.'Column', l:columnName   , { 'follow': l:tableName })

    let l:as = vim_highlight#core#syntax#keyword(l:predicat.root.'As', 'sqlHiKeywordSecond', [ 'AS' ], { 'follow': [ l:tableName, l:columnBracket ] })

    let l:selectBracket = s:BracketRound(l:predicat.root.'Select', s:predicats.selectStmt, { 'follow': l:as })
    call vim_highlight#core#syntax#follow(l:predicat.end, { 'follow': l:selectBracket })
    
    return l:predicat
endfunction
    " }}}
    " result-column {{{
function! s:ResultColumn (prefix, follow)
    let l:predicat = vim_highlight#core#syntax#predicat(a:prefix.'ResultColumn', a:follow)

    let l:tableName = s:TableName(l:predicat.root, { 'follow': l:predicat.start })
    let l:dot       = s:Dot      (l:predicat.root, { 'follow': l:tableName      })

    let l:star = s:Star(l:predicat.root, { 'follow': [ l:predicat.start, l:dot ] })

    call vim_highlight#core#syntax#follow(l:predicat.end, { 'follow': [ l:star ] })

    return l:predicat
endfunction
    " }}}
    " select-stmt: {{{
function! s:SelectStmt (prefix, follow)
    let l:predicat = vim_highlight#core#syntax#predicat(a:prefix.'SelectStmt', a:follow)
    let s:predicats.selectStmt = l:predicat

    " with {{{
    let l:with      = vim_highlight#core#syntax#keyword(l:predicat.root.'With'     , 'sqlHiKeywordFirst' , [ 'WITH'      ], { 'follow': l:predicat.start, 'contained': 0 })
    let l:recursive = vim_highlight#core#syntax#keyword(l:predicat.root.'Recursive', 'sqlHiKeywordSecond', [ 'RECURSIVE' ], { 'follow': l:with                           })

    let l:commonTableExpression = s:CommonTableExpression(l:predicat.root, [ l:with, l:recursive ])
    
    let l:cteComma = s:Comma(l:predicat.root.'Cte', { 'follow': l:commonTableExpression.end })
    call vim_highlight#core#syntax#follow(l:commonTableExpression.start, { 'follow': l:cteComma })
    " }}}

    " select {{{
    let l:select       = vim_highlight#core#syntax#keyword(l:predicat.root.'Select'     , 'sqlHiKeywordFirst' , [ 'SELECT'          ], { 'follow': [ l:predicat.start, l:commonTableExpression.end ], 'contained': 0 })
    let l:distinct_all = vim_highlight#core#syntax#keyword(l:predicat.root.'DistinctAll', 'sqlHiKeywordSecond', [ 'DISTINCT', 'ALL' ], { 'follow': [ l:select                                      ]                 })

    let l:resultColumn = s:ResultColumn(l:predicat.root, [ l:select, l:distinct_all ])
    call vim_highlight#core#syntax#follow(l:predicat.end, { 'follow': l:resultColumn.end })
    
    let l:resultColumnComma = s:Comma(l:predicat.root.'ResultColumn', { 'follow': l:resultColumn.end })
    call vim_highlight#core#syntax#follow(l:resultColumn.start, { 'follow': l:resultColumnComma })
    " }}}

    return l:predicat
endfunction
    " }}}
" }}}

call s:SelectStmt(s:predicats.root, [])

" HIGHLIGHT: {{{
highlight default link sqlHiComment         Comment
highlight default link sqlHiError           Error
highlight default link sqlHiKeywordFirst    Statement
highlight default link sqlHiKeywordSecond   Identifier
highlight default link sqlHiOperator        Operator
highlight default link sqlHiVariable        Ignore
" }}}

let b:current_syntax = "sql"
