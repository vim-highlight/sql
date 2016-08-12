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

let s:predicat = 'sql'

" Error: {{{
call vim_highlight#core#syntax#match(s:predicat.'Error', 'sqlHiError', '/\S.*/', {})
" }}}

" Predicats: {{{
    " select-stmt: {{{
function s:SelectStmt (prefix)
    let l:predicat = a:prefix.'SelectStmt'

    let l:with      = vim_highlight#core#syntax#keyword(l:predicat.'With'     , 'sqlHiIdentifier', [ 'WITH'      ], {'skipempty': 1, 'skipnl': 1, 'skipwhite': 1 })
    let l:recursive = vim_highlight#core#syntax#keyword(l:predicat.'Recursive', 'sqlHiStatement' , [ 'RECURSIVE' ], {'skipempty': 1, 'skipnl': 1, 'skipwhite': 1, 'contained': 1, 'follow': l:with })
endfunction
    " }}}
" }}}

call s:SelectStmt(s:predicat)

" Suppression: {{{
delfunction s:SelectStmt
" }}}

" HIGHLIGHT: {{{
highlight default link sqlHiIdentifier    Identifier
highlight default link sqlHiStatement     Statement
highlight default link sqlHiError         Keyword
highlight default link sqlHiComment       Comment
" }}}

let b:current_syntax = "sql"
