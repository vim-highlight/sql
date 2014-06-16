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

if s:case_sensitive
	syntax case match
else
	syntax case ignore
endif

if s:driver != ''
	source! sql/s:driver.vim
endif

" COLORS: {{{
highlight link phpBounds		Debug
highlight link phpError			Error
highlight link phpComment		Comment
highlight link phpOperator		Operator
highlight link phpNumber		Number

highlight link phpString		String
highlight link phpStringEscape	Operator

highlight link phpModifier		StorageClass
highlight link phpStructure		Structure

highlight link phpExtensionConstants	Constant
highlight link phpExtensionFunctions	Function
highlight link phpExtensionClasses		Function
" }}}

