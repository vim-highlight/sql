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
let s:driver         = vim_highlight#options#core#getOption('driver'        , '')
let s:case_sensitive = vim_highlight#options#core#getOption('case_sensitive',  0)
" }}}

" Case matching {{{
if s:case_sensitive
    syntax case match
else
    syntax case ignore
endif
" }}}

function s:SelectStmt ()
    "syntax cluster sqlSelectSTMT

    call vim_highlight#options#core#keyword('sqlSelectStmtWith', 'sqlIdentifier', [ 'WITH' ], { 'nexgroup': [ 'sqlSelectStmtRecursive' ], 'skipempty': 1, 'skipnl': 1, 'skipwhite': 1 })
    syntax cluster sqlSelectSTMT add=sqlSelectStmtWith
endfunction

call s:SelectStmt()

delfunction s:SelectStmt

" HIGHLIGHT: {{{
highlight default link sqlIdentifier    Identifier
highlight default link sqlError         Error
highlight default link sqlComment       Comment
" }}}

let b:current_syntax = "sql"
