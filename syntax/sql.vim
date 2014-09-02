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
function! s:DefineEntity_Number (block)
	execute 'syntax match sql'.a:block.'Number nextgroup=@sqlCl'.a:block.'ContentNext skipwhite skipempty /[0-9]\+\(\.[0-9]\+\)\?/'
	execute 'syntax cluster sqlCl'.a:block.'Content add=sql'.a:block.'Number'

	execute 'highlight link sql'.a:block.'Number sqlNumber'
endfunction
	" }}}
	" String: {{{
function! s:DefineEntity_String (block)
	execute 'syntax region sql'.a:block.'StringSingle nextgroup=@sqlCl'.a:block.'ContentNext skipwhite skipempty matchgroup=sql'.a:block.'StringSingleDelimiter start=/''/ skip=/\\''/ end=/''/'
	execute 'syntax region sql'.a:block.'StringDouble nextgroup=@sqlCl'.a:block.'ContentNext skipwhite skipempty matchgroup=sql'.a:block.'StringDoubleDelimiter start=/"/  skip=/\\"/  end=/"/ '

	execute 'syntax cluster sqlCl'.a:block.'String  add=sql'.a:block.'StringSingle,sql'.a:block.'StringDouble'
	execute 'syntax cluster sqlCl'.a:block.'Content add=@sqlCl'.a:block.'String'

	execute 'highlight link sql'.a:block.'StringSingleDelimiter sql'.a:block.'StringDelimiter'
	execute 'highlight link sql'.a:block.'StringDoubleDelimiter sql'.a:block.'StringDelimiter'

	execute 'highlight link sql'.a:block.'StringSingle sql'.a:block.'String'
	execute 'highlight link sql'.a:block.'StringDouble sql'.a:block.'String'

	execute 'highlight link sql'.a:block.'Delimiter sqlStringDelimiter'
	execute 'highlight link sql'.a:block.'String    sqlString'
endfunction
	" }}}
	" Column: {{{
function! s:DefineEntity_Column (block)
	execute 'syntax region sql'.a:block.'ColumnEscaped nextgroup=@sqlCl'.a:block.'ContentNext skipwhite skipempty transparent oneline contains=sql'.a:block.'Column matchgroup=sql'.a:block.'ColumnDelimiter start=/`/ end=/`/'
	execute 'syntax match  sql'.a:block.'Column        nextgroup=@sqlCl'.a:block.'ContentNext skipwhite skipempty contained /\h\w*/'

	execute 'syntax cluster sqlCl'.a:block.'Content add=sql'.a:block.'ColumnEscaped,sql'.a:block.'Column'

	execute 'highlight link sql'.a:block.'ColumnDelimiter sqlColumnDelimiter'
	execute 'highlight link sql'.a:block.'Column          sqlColumn'
endfunction
	" }}}
	" Function: {{{
		" DefineFunctionNames {{{
function! s:DefineFunctionNames (blocks, star, names)
	let blocks = substitute(a:blocks, '^ALL', 'Select', 'I')
	
	let pos_old = 0
	let pos     = match(l:blocks, '\s\+', l:pos_old)
	while l:pos != -1
		let block = strpart(l:blocks, l:pos_old, l:pos - l:pos_old)

		if a:star
			execute 'syntax keyword sql'.l:block.'FunctionCommonStar nextgroup=sql'.l:block.'FunctionCallStar skipwhite skipempty '.a:names
		else
			execute 'syntax keyword sql'.l:block.'FunctionCommon     nextgroup=sql'.l:block.'FunctionCall     skipwhite skipempty '.a:names
		endif

		let pos_old = l:pos
		let pos     = match(l:blocks, '\s\+', l:pos_old)
	endwhile

	let block = strpart(l:blocks, l:pos_old)
	if a:star
		execute 'syntax keyword sql'.l:block.'FunctionCommonStar nextgroup=sql'.l:block.'FunctionCallStar skipwhite skipempty '.a:names
	else
		execute 'syntax keyword sql'.l:block.'FunctionCommon     nextgroup=sql'.l:block.'FunctionCall     skipwhite skipempty '.a:names
	endif
endfunction
		" }}}
		" DefineEntity_Function {{{
function! s:DefineEntity_Function (block)
	call s:DefineFunctionNames(a:block, 0, 'sum min max')
	call s:DefineFunctionNames(a:block, 1, 'count')
	execute 'syntax match sql'.a:block.'FunctionUser nextgroup=sql'.a:block.'FunctionCallStar skipwhite skipempty contained /\h\w*\(\s*(\)\@=/'

	execute 'syntax cluster sqlCl'.a:block.'Function add=sql'.a:block.'FunctionCommon,sql'.a:block.'FunctionCommonStar,sql'.a:block.'FunctionUser'
	execute 'syntax cluster sqlCl'.a:block.'Content add=@sqlCl'.a:block.'Function'

	execute 'highlight link sql'.a:block.'FunctionCommon     sql'.a:block.'Function'
	execute 'highlight link sql'.a:block.'FunctionCommonStar sql'.a:block.'Function'

	execute 'highlight link sql'.a:block.'Function     sqlFunction'
	execute 'highlight link sql'.a:block.'FunctionUser sqlFunctionUser'


	execute 'syntax region sql'.a:block.'FunctionCall     nextgroup=@sqlCl'.a:block.'ContentNext skipwhite skipempty contains=@sqlCl'.a:block.'FunctionContent     matchgroup=sql'.a:block.'FunctionCallDelimiter start=/(/ end=/)/'
	execute 'syntax region sql'.a:block.'FunctionCallStar nextgroup=@sqlCl'.a:block.'ContentNext skipwhite skipempty contains=@sqlCl'.a:block.'FunctionContentStar matchgroup=sql'.a:block.'FunctionCallDelimiter start=/(/ end=/)/'

	" Star: * {{{
	execute 'syntax match sql'.a:block.'FunctionContentStarStar nextgroup=@sqlCl'.a:block.'FunctionContentNext skipwhite skipempty contained /\*/'
	execute 'syntax cluster sqlCl'.a:block.'FunctionContentStar add=sql'.a:block.'FunctionContentStarStar'
	execute 'highlight link sql'.a:block.'FunctionContentStarStar sqlStar'
	" }}}
	" Values: {{{
	call s:DefineEntity_Number  ('SelectFunction')
	call s:DefineEntity_String  ('SelectFunction')
	call s:DefineEntity_Column  ('SelectFunction')

	execute 'syntax cluster sqlCl'.a:block.'FunctionContent add=@sqlCl'.a:block.'Function'

		" Spaces: {{{
	execute 'syntax match sql'.a:block.'FunctionContentSpace     nextgroup=@sqlCl'.a:block.'FunctionContent     skipwhite skipempty /\s\+/'
	execute 'syntax match sql'.a:block.'FunctionContentSpaceStar nextgroup=@sqlCl'.a:block.'FunctionContentStar skipwhite skipempty /\s\+/'

	execute 'syntax cluster sqlCl'.a:block.'FunctionContent     add=sql'.a:block.'FunctionContentSpace'
	execute 'syntax cluster sqlCl'.a:block.'FunctionContentStar add=sql'.a:block.'FunctionContentSpaceStar'

	execute 'highlight link sql'.a:block.'FunctionContentSpace     None'
	execute 'highlight link sql'.a:block.'FunctionContentSpaceStar sql'.a:block.'FunctionContentSpace'
		" }}}
	" }}}
	
	" Values Separator: {{{
	execute 'syntax match sql'.a:block.'FunctionContentComma nextgroup=@sqlCl'.a:block.'FunctionContentCall skipwhite skipempty /,/'
	execute 'syntax cluster sqlCl'.a:block.'FunctionContentNext add=sql'.a:block.'FunctionContentComma'
	execute 'highlight link sql'.a:block.'FunctionContentComma sqlComma'
	" }}}
	
	execute 'syntax cluster sqlCl'.a:block.'FunctionContent     add=sqlError'
	execute 'syntax cluster sqlCl'.a:block.'FunctionContentStar add=@sqlCl'.a:block.'FunctionContent'

	execute 'highlight link sql'.a:block.'FunctionCallDelimiter sqlFunctionCallDelimiter'
endfunction
		" }}}
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

	" Star: * {{{
syntax match sqlSelectStar nextgroup=@sqlClSelectContentNext skipwhite skipempty /\*/
syntax cluster sqlClSelectContent add=sqlSelectStar

highlight link sqlSelectStar sqlStar
	" }}}
	" Values: {{{
call s:DefineEntity_Number  ('Select')
call s:DefineEntity_String  ('Select')
call s:DefineEntity_Column  ('Select')

call s:DefineEntity_Function('Select')
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
delfunction s:DefineEntity_Function

delfunction s:DefineFunctionNames
" }}}

" COLORS: {{{
highlight link sqlComma						Operator
highlight link sqlError						Error
highlight link sqlEscape					Special
highlight link sqlFunction					Function
highlight link sqlFunctionUser				Operator
highlight link sqlFunctionCallDelimiter		Operator
highlight link sqlNumber					Number
highlight link sqlStar						Operator
highlight link sqlString					String
highlight link sqlStringDelimiter			sqlString
highlight link sqlStructure					Structure

highlight link sqlNone						Todo
highlight link sqlColumn					sqlNone
highlight link sqlIntoVarName				sqlNone
highlight link sqlFromTable					sqlNone
" }}}

