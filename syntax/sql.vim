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

" Entities: {{{
	" Number: {{{
function! s:DefineEntity_Number (name, next, cluster)
	execute 'syntax match '.a:name.' nextgroup='.a:next.' skipwhite skipempty /[0-9]\+\(\.[0-9]\+\)\?/'
	execute 'syntax cluster '.a:cluster.' add='.a:name

	execute 'highlight link '.a:name.' sqlNumber'
endfunction
	" }}}
	" String: {{{
function! s:DefineEntity_String (name, next, cluster)
	execute 'syntax region '.a:name.'Single nextgroup='.a:next.' skipwhite skipempty matchgroup='.a:name.'SingleDelimiter start=/''/ skip=/\\''/ end=/''/'
	execute 'syntax region '.a:name.'Double nextgroup='.a:next.' skipwhite skipempty matchgroup='.a:name.'DoubleDelimiter start=/"/  skip=/\\"/  end=/"/ '

	execute 'syntax cluster '.a:cluster.' add='.a:name.'Single,'.a:name.'Double'

	execute 'highlight link '.a:name.'SingleDelimiter '.a:name.'Delimiter'
	execute 'highlight link '.a:name.'DoubleDelimiter '.a:name.'Delimiter'

	execute 'highlight link '.a:name.'Single          '.a:name
	execute 'highlight link '.a:name.'Double          '.a:name

	execute 'highlight link '.a:name.'Delimiter       sqlStringDelimiter'
	execute 'highlight link '.a:name.'                sqlString'
endfunction
	" }}}
	" Column: {{{
function! s:DefineEntity_Column (name, next, cluster)
	execute 'syntax region '.a:name.'Escaped nextgroup='.a:next.' skipwhite skipempty transparent oneline contains='.a:name.' matchgroup='.a:name.'Delimiter start=/`/ end=/`/'
	execute 'syntax match  '.a:name.'        nextgroup='.a:next.' skipwhite skipempty contained /\h\w*/'

	execute 'syntax cluster '.a:cluster.' add='.a:name.'Escaped,'.a:name

	execute 'highlight link '.a:name.'Delimiter sqlColumnDelimiter'
	execute 'highlight link '.a:name.'          sqlColumn'
endfunction
	" }}}
	" Function: {{{
function! s:DefineEntity_Function (name, next, cluster)
	execute 'syntax keyword '.a:name.'Common nextgroup='.a:name.'Call skipwhite skipempty sum min max'

	execute 'syntax cluster sqlClSelectFunction add=sqlSelectFunctionCommon'
	execute 'highlight link sqlSelectFunctionCommon sqlSelectFunction'


	execute 'syntax keyword sqlSelectFunctionCommonStar nextgroup=sqlSelectFunctionCallStar skipwhite skipempty count'

	execute 'syntax cluster sqlClSelectFunction add=sqlSelectFunctionCommonStar'
	execute 'highlight link sqlSelectFunctionCommonStar sqlSelectFunction'


	execute 'syntax match sqlSelectFunctionUser nextgroup=sqlSelectFunctionCallStar skipwhite skipempty contained /\h\w*\([\s\n\t\r]*(\)\@=/'
	execute 'syntax cluster sqlClSelectFunction add=sqlSelectFunctionUser'
	execute 'highlight link sqlSelectFunctionUser sqlSelectFunctionUser'


	execute 'syntax cluster sqlClSelectContent add=@sqlClSelectFunction'
	execute 'highlight link sqlSelectFunction     sqlFunction'
	execute 'highlight link sqlSelectFunctionUser sqlFunctionUser'


	execute 'syntax region sqlSelectFunctionCall     nextgroup=@sqlClSelectContentNext skipwhite skipempty contains=@sqlClSelectFunctionContent     matchgroup=sqlSelectFunctionCallDelimiter start=/(/ end=/)/'
	execute 'syntax region sqlSelectFunctionCallStar nextgroup=@sqlClSelectContentNext skipwhite skipempty contains=@sqlClSelectFunctionContentStar matchgroup=sqlSelectFunctionCallDelimiter start=/(/ end=/)/'

	execute 'highlight link sqlSelectFunctionCallDelimiter sqlFunctionCallDelimiter'
endfunction

function! s:DefineFunctionNames (names, blocks)
	let blocks = substitute(a:blocks, '^ALL', 'Select', 'I')


endfunction
	" }}}
" }}}

" ERROR: {{{
syntax match sqlError /.\+/
" }}}

" SELECT: {{{
syntax keyword sqlSelect nextgroup=@sqlClSelectContentGeneral skipwhite skipempty SELECT

	" DISTINCT: {{{
syntax keyword sqlSelectDistinct nextgroup=@sqlClSelectContent skipwhite skipempty DISTINCT
syntax cluster sqlClSelectContentGeneral add=sqlSelectDistinct

highlight link sqlSelectDistinct sqlFunction
	" }}}

	" Values: {{{
call s:DefineEntity_Number  ('sqlSelectNumber',   '@sqlClSelectContentNext', 'sqlClSelectContent')
call s:DefineEntity_String  ('sqlSelectString',   '@sqlClSelectContentNext', 'sqlClSelectContent')
call s:DefineEntity_Column  ('sqlSelectColumn',   '@sqlClSelectContentNext', 'sqlClSelectContent')

call s:DefineEntity_Function('sqlSelectFunction', '@sqlClSelectContentNext', 'sqlClSelectContent')

		" Functions: {{{
syntax keyword sqlSelectFunctionCommon nextgroup=sqlSelectFunctionCall skipwhite skipempty sum min max

syntax cluster sqlClSelectFunction add=sqlSelectFunctionCommon
highlight link sqlSelectFunctionCommon sqlSelectFunction


syntax keyword sqlSelectFunctionCommonStar nextgroup=sqlSelectFunctionCallStar skipwhite skipempty count

syntax cluster sqlClSelectFunction add=sqlSelectFunctionCommonStar
highlight link sqlSelectFunctionCommonStar sqlSelectFunction


syntax match sqlSelectFunctionUser nextgroup=sqlSelectFunctionCallStar skipwhite skipempty contained /\h\w*\([\s\n\t\r]*(\)\@=/
syntax cluster sqlClSelectFunction add=sqlSelectFunctionUser
highlight link sqlSelectFunctionUser sqlSelectFunctionUser


syntax cluster sqlClSelectContent add=@sqlClSelectFunction
highlight link sqlSelectFunction     sqlFunction
highlight link sqlSelectFunctionUser sqlFunctionUser


syntax region sqlSelectFunctionCall     nextgroup=@sqlClSelectContentNext skipwhite skipempty contains=@sqlClSelectFunctionContent     matchgroup=sqlSelectFunctionCallDelimiter start=/(/ end=/)/
syntax region sqlSelectFunctionCallStar nextgroup=@sqlClSelectContentNext skipwhite skipempty contains=@sqlClSelectFunctionContentStar matchgroup=sqlSelectFunctionCallDelimiter start=/(/ end=/)/

highlight link sqlSelectFunctionCallDelimiter sqlFunctionCallDelimiter




"syntax match sqlSelectFunction nextgroup=sqlSelectFunctionCall skipwhite skipempty contains=@sqlClSelectFunctionName contained /\h\w*\([\s\n\t\r]*(\)\@=/

			"" Common: {{{
"syntax keyword sqlSelectFunctionNameCommon contained sum min max
"syntax cluster sqlClSelectFunctionName add=sqlSelectFunctionNameCommon

"highlight link sqlSelectFunctionNameCommon sqlSelectFunctionName
			"" }}}
			"" MySQL: {{{
"syntax keyword sqlSelectFunctionNameSpecific contained concat group_concat
"syntax cluster sqlClSelectFunctionName add=sqlSelectFunctionNameSpecific

"highlight link sqlSelectFunctionNameSpecific sqlSelectFunctionName
			"" }}}

			"" () {{{
"syntax region sqlSelectFunctionCall nextgroup=@sqlClSelectContentNext skipwhite skipempty contains=@sqlClSelectFunctionContent matchgroup=sqlSelectFunctionCallDelimiter start=/(/ end=/)/

"highlight link sqlSelectFunctionCallDelimiter sqlFunctionCallDelimiter
			"" }}}

"syntax cluster sqlClSelectContent add=sqlSelectFunction

"highlight link sqlSelectFunctionName sqlFunction
"highlight link sqlSelectFunction sqlFunctionUnknown
		"" }}}
	" }}}
	" Alias AS: {{{
syntax keyword sqlSelectContentAliasAs nextgroup=@sqlClSelectContentAliasName skipwhite skipempty AS
syntax cluster sqlClSelectContentNext add=sqlSelectContentAliasAs

		" Name: {{{
syntax region sqlSelectContentAliasEscaped nextgroup=@sqlClSelectContentNext skipwhite skipempty transparent oneline contains=sqlSelectContentAliasName matchgroup=sqlEscape start=/`/ end=/`/
syntax cluster sqlClSelectContentAliasName add=sqlSelectContentAliasEscaped

syntax match sqlSelectContentAliasName nextgroup=@sqlClSelectContentNext skipwhite skipempty contained /\h\w*/
syntax cluster sqlClSelectContentAliasName add=sqlSelectContentAliasName

highlight link sqlSelectContentAliasName sqlColumnName
		" }}}

highlight link sqlSelectContentAliasAs sqlStructure
	" }}}
	" Values Separator: {{{
syntax match sqlSelectContentComma nextgroup=@sqlClSelectContent skipwhite skipempty /,/
syntax cluster sqlClSelectContentNext add=sqlSelectContentComma

highlight link sqlSelectContentComma sqlComma
	" }}}

syntax cluster sqlClSelectContentGeneral add=@sqlClSelectContent

highlight link sqlSelect sqlStructure
" }}}
" INTO: {{{
syntax keyword sqlInto nextgroup=@sqlClIntoContent skipwhite skipempty INTO

	" Variable: {{{
syntax match sqlIntoVarName nextgroup=@sqlClIntoContentNext skipwhite skipempty contained /\h\w*/
syntax cluster sqlClIntoContent add=sqlIntoVarName
	" }}}
	" Variable Separator: {{{
syntax match sqlIntoContentComma nextgroup=@sqlClIntoContent skipwhite skipempty /,/
syntax cluster sqlClIntoContentNext add=sqlIntoContentComma

highlight link sqlIntoContentComma sqlComma
	" }}}

syntax cluster sqlClSelectContentNext add=sqlInto

highlight link sqlInto sqlStructure
" }}}
" FROM: {{{
syntax keyword sqlFrom nextgroup=@sqlClFromContent skipwhite skipempty FROM

	" Table: {{{
syntax match sqlFromTable nextgroup=@sqlClFromContentNext skipwhite skipempty contained /\h\w*/
syntax cluster sqlClFromContent add=sqlFromTable
	" }}}

syntax cluster sqlClSelectContentNext add=sqlFrom

highlight link sqlFrom sqlStructure
" }}}

" Cleaning: {{{
delfunction s:DefineEntity_Number
delfunction s:DefineEntity_String
delfunction s:DefineEntity_Column
" }}}

" COLORS: {{{
highlight link sqlComma						Operator
highlight link sqlError						Error
highlight link sqlEscape					Special
highlight link sqlFunction					Function
highlight link sqlFunctionUser				None
highlight link sqlFunctionCallDelimiter		Operator
highlight link sqlNumber					Number
highlight link sqlString					String
highlight link sqlStringDelimiter			sqlString
highlight link sqlStructure					Structure

highlight link sqlNone						Todo
highlight link sqlColumn					sqlNone
highlight link sqlIntoVarName				sqlNone
highlight link sqlFromTable					sqlNone
" }}}

