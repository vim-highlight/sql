" Vim syntax file for SQL
" Language:        SQL standard / Support for drivers specifics
" Maintainer:    Julien Rosset <jul.rosset@gmail.com>
"
" URL:            https://github.com/darkelfe/vim-highlight
" Version:        0.0.1

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Initialize options {{{
function! s:DefineOption (name, value)
    if exists('b:sql_'.a:name)
        return b:{'sql_'.a:name}
    elseif exists('g:sql_'.a:name)
        return g:{'sql_'.a:name}
    else
        return a:value
    endif
endfunction

let s:driver         = s:DefineOption('driver'        , '')
let s:case_sensitive = s:DefineOption('case_sensitive', 0)

delfunction s:DefineOption
" }}}

" Case matching {{{
if s:case_sensitive
    syntax case match
else
    syntax case ignore
endif
" }}}

" ERROR: {{{
syntax match sqlError /\S.*/
" }}}

let b:current_syntax = "sql"
