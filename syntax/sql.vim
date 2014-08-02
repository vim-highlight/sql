" Vim syntax file for SQL
" Language:		SQL standard / Support for drivers specifics
" Maintainer:	Julien Rosset <jul.rosset@gmail.com>
"
" URL:			https://github.com/darkelfe/vim-highlight
" Version:		0.0.1

if version < 600 || exists("b:current_syntax")
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

let s:driver = s:DefineOption('driver', '')

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
" Driver specifics include {{{
"if s:driver != ''
"	source! sql/s:driver.vim
"endif
" }}}

" SELECT: {{{
syntax keyword sqlSelect nextgroup=@sqlClSelectContent skipwhite skipempty SELECT

	" DISTINCT: {{{
syntax keyword sqlSelectDistinct nextgroup=@sqlClSelectContent skipwhite skipempty DISTINCT
syntax cluster sqlClSelectContent add=sqlSelectDistinct

highlight link sqlSelectDistinct sqlFunction
	" }}}
	
	" Column Name: {{{
syntax region sqlSelectColumnEscaped nextgroup=sqlSelectColumnAlias,sqlSelectColumnSeparator transparent oneline contains=sqlSelectColumnName matchgroup=sqlEscape start=/`/ end=/`/
syntax cluster sqlClSelectContent add=sqlSelectColumnEscaped

syntax match sqlSelectColumnName nextgroup=sqlSelectColumnAlias,sqlSelectColumnSeparator /[a-zA-Z0-9_]\+/
syntax cluster sqlClSelectContent add=sqlSelectColumnName

highlight link sqlSelectColumnName sqlColumnName
	" }}}

highlight link sqlSelect sqlStructure
" }}}

" COLORS: {{{
highlight link sqlFunction		Function
highlight link sqlStructure		Structure
" }}}

