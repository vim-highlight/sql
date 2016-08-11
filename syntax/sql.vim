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
"let s:driver         = s:DefineOption('driver'        , '')
"let s:case_sensitive = s:DefineOption('case_sensitive',  0)
" }}}

" Case matching {{{
"if s:case_sensitive
    syntax case match
"else
    "syntax case ignore
"endif
" }}}

" HIGHLIGHT: {{{
highlight default link sqlIdentifier    Identifier
highlight default link sqlError         Error
highlight default link sqlComment       Comment
" }}}

let b:current_syntax = "sql"
