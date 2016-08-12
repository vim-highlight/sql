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

let s:predicat = 'sql'

" Error: {{{
call vim_highlight#core#syntax#match(s:predicat.'Error', 'sqlHiError', '/\S.*/', {})
" }}}

" Common: {{{
    " Operator: {{{
        " parenthesis-open {{{
function! s:ParenthesisOpen (prefix, options)
    return vim_highlight#core#syntax#match(a:prefix.'ParenthesisOpen', 'sqlHiOperator', '/(/', a:options)
endfunction
        " }}}
        " parenthesis-close {{{
function! s:ParenthesisClose (prefix, options)
    return vim_highlight#core#syntax#match(a:prefix.'ParenthesisClose', 'sqlHiOperator', '/)/', a:options)
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
    let l:predicat = a:prefix.'CommonTableExpression'

    let l:tableName = s:TableName(l:predicat, { 'follow': a:follow })

    let l:columnParenthesisOpen  = s:ParenthesisOpen (l:predicat, { 'follow': l:tableName             })
    let l:columnName             = s:ColumnName      (l:predicat, { 'follow': l:columnParenthesisOpen })
    let l:columnParenthesisClose = s:ParenthesisClose(l:predicat, { 'follow': l:columnName            })

    let l:as = vim_highlight#core#syntax#keyword(l:predicat.'As', 'sqlHiKeywordSecond', [ 'AS' ], { 'follow': [ l:tableName, l:columnParenthesisClose ] })
    
    "let l:columnParenthesisOpen  = s:ParenthesisOpen (l:predicat, { 'follow': l:tableName             })
    "let l:columnName             = s:ColumnName      (l:predicat, { 'follow': l:columnParenthesisOpen })
    "let l:columnParenthesisClose = s:ParenthesisClose(l:predicat, { 'follow': l:columnName            })
endfunction
    " }}}
    " select-stmt: {{{
function! s:SelectStmt (prefix, follow)
    let l:predicat = a:prefix.'SelectStmt'

    let l:with      = vim_highlight#core#syntax#keyword(l:predicat.'With'     , 'sqlHiKeywordMain'  , [ 'WITH'      ], { 'follow': l:predicat, 'contained': 0 })
    let l:recursive = vim_highlight#core#syntax#keyword(l:predicat.'Recursive', 'sqlHiKeywordSecond', [ 'RECURSIVE' ], { 'follow': l:with                     })
    call s:CommonTableExpression(l:predicat, [ l:with, l:recursive ])

    call vim_highlight#core#syntax#follow('@'.l:predicat, { 'follow': a:follow })
endfunction
    " }}}
" }}}

call s:SelectStmt(s:predicat, '')

" HIGHLIGHT: {{{
highlight default link sqlHiComment         Comment
highlight default link sqlHiError           Error
highlight default link sqlHiKeywordMain     Identifier
highlight default link sqlHiKeywordSecond   Statement
highlight default link sqlHiOperator        Operator
highlight default link sqlHiVariable        Ignore
" }}}

let b:current_syntax = "sql"
