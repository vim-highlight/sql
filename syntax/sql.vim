" Vim syntax file for SQL
" Language:		SQL standard / Support for drivers specifics
" Maintainer:	Julien Rosset <jul.rosset@gmail.com>
"
" URL:			https://github.com/darkelfe/vim-highlight
" Version:		0.0.1

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

let s:join_92        = s:DefineOption('join_92'       , 1)

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
function! s:DefineEntity_Null (block)
	execute 'syntax keyword sql'.a:block.'Null nextgroup=@sqlCl'.a:block.'NullNext skipwhite skipempty contained display NULL'

	execute 'syntax cluster sqlCl'.a:block.'NullNext          add=@sqlCl'.a:block.'Operation,@sqlCl'.a:block.'ContentNext'
	execute 'syntax cluster sqlCl'.a:block.'Content           add=sql'.a:block.'Null'
	execute 'syntax cluster sqlCl'.a:block.'OperationPartNext add=sql'.a:block.'Null'

	execute 'highlight link sql'.a:block.'Null sqlNull'
endfunction
	" }}}
	" Number: {{{
function! s:DefineEntity_Number (block)
	execute 'syntax match sql'.a:block.'Number nextgroup=@sqlCl'.a:block.'NumberNext skipwhite skipempty contained display /[+-]\?[0-9]\+\(\.[0-9]\+\)\?/'

	execute 'syntax cluster sqlCl'.a:block.'NumberNext        add=@sqlCl'.a:block.'Operation,@sqlCl'.a:block.'ContentNext'
	execute 'syntax cluster sqlCl'.a:block.'Content           add=sql'.a:block.'Number'
	execute 'syntax cluster sqlCl'.a:block.'OperationPartNext add=sql'.a:block.'Number'

	execute 'highlight link sql'.a:block.'Number sqlNumber'
endfunction
	" }}}
	" String: {{{
function! s:DefineEntity_String (block)
	execute 'syntax region sql'.a:block.'StringSingle nextgroup=@sqlCl'.a:block.'StringSingleNext skipwhite skipempty contained matchgroup=sql'.a:block.'StringSingleDelimiter start=/''/ skip=/\\''/ end=/''/'
	execute 'syntax region sql'.a:block.'StringDouble nextgroup=@sqlCl'.a:block.'StringDoubleNext skipwhite skipempty contained matchgroup=sql'.a:block.'StringDoubleDelimiter start=/"/  skip=/\\"/  end=/"/ '

	execute 'syntax cluster sqlCl'.a:block.'StringSingleNext add=@sqlCl'.a:block.'StringNext'
	execute 'syntax cluster sqlCl'.a:block.'StringDoubleNext add=@sqlCl'.a:block.'StringNext'
	execute 'syntax cluster sqlCl'.a:block.'StringNext       add=@sqlCl'.a:block.'Operation,@sqlCl'.a:block.'ContentNext'

	execute 'syntax cluster sqlCl'.a:block.'String            add=sql'.a:block.'StringSingle,sql'.a:block.'StringDouble'
	execute 'syntax cluster sqlCl'.a:block.'Content           add=@sqlCl'.a:block.'String'
	execute 'syntax cluster sqlCl'.a:block.'OperationPartNext add=@sqlCl'.a:block.'String'

	execute 'highlight link sql'.a:block.'StringSingleDelimiter sql'.a:block.'StringDelimiter'
	execute 'highlight link sql'.a:block.'StringDoubleDelimiter sql'.a:block.'StringDelimiter'

	execute 'highlight link sql'.a:block.'StringSingle sql'.a:block.'String'
	execute 'highlight link sql'.a:block.'StringDouble sql'.a:block.'String'

	execute 'highlight link sql'.a:block.'Delimiter sqlStringDelimiter'
	execute 'highlight link sql'.a:block.'String    sqlString'
endfunction
	" }}}
	" Table: {{{
function! s:DefineEntity_Table (block)
	execute 'syntax region sql'.a:block.'TableEscaped nextgroup=@sqlCl'.a:block.'TableNext skipwhite skipempty contained display transparent oneline contains=sql'.a:block.'Table matchgroup=sql'.a:block.'TableDelimiter start=/`/ end=/`/'
	execute 'syntax match  sql'.a:block.'Table        nextgroup=@sqlCl'.a:block.'TableNext skipwhite skipempty contained display /\h\w*/'

	execute 'syntax cluster sqlCl'.a:block.'TableNext add=@sqlCl'.a:block.'ContentNext'
	execute 'syntax cluster sqlCl'.a:block.'Content   add=sql'.a:block.'TableEscaped,sql'.a:block.'Table'

	execute 'highlight link sql'.a:block.'TableDelimiter sqlTableDelimiter'
	execute 'highlight link sql'.a:block.'Table          sqlTable'
endfunction
	" }}}
	" Column: {{{
function! s:DefineEntity_Column (block)
		" column {{{
	execute 'syntax region sql'.a:block.'ColumnEscaped nextgroup=@sqlCl'.a:block.'ColumnNext skipwhite skipempty contained display transparent oneline contains=sql'.a:block.'Column matchgroup=sql'.a:block.'ColumnDelimiter start=/`/ end=/`/'
	execute 'syntax match  sql'.a:block.'Column        nextgroup=@sqlCl'.a:block.'ColumnNext skipwhite skipempty contained /\h\w*/'

	execute 'syntax cluster sqlCl'.a:block.'Column     add=sql'.a:block.'ColumnEscaped,sql'.a:block.'Column'
	execute 'syntax cluster sqlCl'.a:block.'ColumnNext add=@sqlCl'.a:block.'Operation,@sqlCl'.a:block.'ContentNext'

	execute 'syntax cluster sqlCl'.a:block.'Content           add=@sqlCl'.a:block.'Column'
	execute 'syntax cluster sqlCl'.a:block.'OperationPartNext add=@sqlCl'.a:block.'Column'

	execute 'highlight link sql'.a:block.'ColumnDelimiter sqlColumnDelimiter'
	execute 'highlight link sql'.a:block.'Column          sqlColumn'
		" }}}
		" table. {{{
	execute 'syntax region sql'.a:block.'TableEscaped nextgroup=sql'.a:block.'TableSeparator contained display transparent oneline contains=sql'.a:block.'TableSingle matchgroup=sql'.a:block.'TableDelimiter start=/`/ end=/`\(\.\)\@=/'
	execute 'syntax match  sql'.a:block.'TableSingle  nextgroup=sql'.a:block.'TableSeparator contained display /\h\w*/'
	execute 'syntax match  sql'.a:block.'Table        nextgroup=sql'.a:block.'TableSeparator contained display /\h\w*\(\.\)\@=/'

	execute 'syntax cluster sqlCl'.a:block.'Content add=sql'.a:block.'TableEscaped,sql'.a:block.'Table'

	execute 'highlight link sql'.a:block.'TableDelimiter sqlTableDelimiter'
	execute 'highlight link sql'.a:block.'TableSingle    sql'.a:block.'Table'
	execute 'highlight link sql'.a:block.'Table          sqlTable'

	execute 'syntax match sql'.a:block.'TableSeparator nextgroup=@sqlCl'.a:block.'Column contained display /\./'
	execute 'highlight link sql'.a:block.'TableSeparator sqlTableSeparator'
		" }}}
endfunction
	" }}}
	" Alias: AS {{{
function! s:DefineEntity_Alias (block)
	execute 'syntax keyword sql'.a:block.'AliasAs nextgroup=@sqlCl'.a:block.'AliasName skipwhite skipempty contained AS'
	execute 'syntax cluster sqlCl'.a:block.'ContentNext add=sql'.a:block.'AliasAs'

		" Name: {{{
	execute 'syntax region sql'.a:block.'AliasEscaped nextgroup=@sqlCl'.a:block.'AliasNext skipwhite skipempty contained display transparent oneline contains=sql'.a:block.'AliasName matchgroup=sql'.a:block.'AliasNameDelimiter start=/`/ end=/`/'
	execute 'syntax match  sql'.a:block.'AliasName    nextgroup=@sqlCl'.a:block.'AliasNext skipwhite skipempty contained display /\h\w*/'

	execute 'syntax cluster sqlCl'.a:block.'AliasName add=sql'.a:block.'AliasEscaped,sql'.a:block.'AliasName'

	execute 'highlight link sql'.a:block.'AliasNameDelimiter sqlAliasDelimiter'
	execute 'highlight link sql'.a:block.'AliasName          sqlAliasName'
		" }}}

	execute 'syntax cluster sqlCl'.a:block.'AliasNext add=@sqlCl'.a:block.'Next'

	execute 'highlight link sql'.a:block.'AliasAs sqlAliasAs'
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
			execute 'syntax keyword sql'.l:block.'FunctionCommonStar nextgroup=sql'.l:block.'FunctionCallStar skipwhite skipempty contained '.a:names
		else
			execute 'syntax keyword sql'.l:block.'FunctionCommon     nextgroup=sql'.l:block.'FunctionCall     skipwhite skipempty contained '.a:names
		endif

		let pos_old = l:pos
		let pos     = match(l:blocks, '\s\+', l:pos_old)
	endwhile

	let block = strpart(l:blocks, l:pos_old)
	if a:star
		execute 'syntax keyword sql'.l:block.'FunctionCommonStar nextgroup=sql'.l:block.'FunctionCallStar skipwhite skipempty contained '.a:names
	else
		execute 'syntax keyword sql'.l:block.'FunctionCommon     nextgroup=sql'.l:block.'FunctionCall     skipwhite skipempty contained '.a:names
	endif
endfunction
		" }}}
		" DefineEntity_Function {{{
function! s:DefineEntity_Function_real (block, included)
	" Values: {{{
		" Must be declared at first to allow user function match BEFORE column match
	call s:DefineEntityCommon_Root(a:block, 'Function')
	" }}}

	call s:DefineFunctionNames(a:block, 0, 'sum min max')
	call s:DefineFunctionNames(a:block, 1, 'count')
	execute 'syntax match sql'.a:block.'FunctionUser nextgroup=sql'.a:block.'FunctionCallStar skipwhite skipempty contained /\h\w*\(\s*(\)\@=/'

	execute 'syntax cluster sqlCl'.a:block.'Function add=sql'.a:block.'FunctionCommon,sql'.a:block.'FunctionCommonStar,sql'.a:block.'FunctionUser'
	execute 'syntax cluster sqlCl'.a:block.'Content add=@sqlCl'.a:block.'Function'

	execute 'highlight link sql'.a:block.'FunctionCommon     sql'.a:block.'Function'
	execute 'highlight link sql'.a:block.'FunctionCommonStar sql'.a:block.'Function'

	execute 'highlight link sql'.a:block.'Function     sqlFunction'
	execute 'highlight link sql'.a:block.'FunctionUser sqlFunctionUser'


	execute 'syntax region sql'.a:block.'FunctionCall     nextgroup=@sqlCl'.a:block.'FunctionNext skipwhite skipempty contained transparent contains=@sqlCl'.a:block.'FunctionContent     matchgroup=sql'.a:block.'FunctionCallDelimiter start=/(/ end=/)/'
	execute 'syntax region sql'.a:block.'FunctionCallStar nextgroup=@sqlCl'.a:block.'FunctionNext skipwhite skipempty contained transparent contains=@sqlCl'.a:block.'FunctionContentStar matchgroup=sql'.a:block.'FunctionCallDelimiter start=/(/ end=/)/'

	" Star: * {{{
	execute 'syntax match sql'.a:block.'FunctionContentStarStar nextgroup=@sqlCl'.a:block.'FunctionContentNext skipwhite skipempty contained display /\*/'
	execute 'syntax cluster sqlCl'.a:block.'FunctionContentStar add=sql'.a:block.'FunctionContentStarStar'
	execute 'highlight link sql'.a:block.'FunctionContentStarStar sqlStar'
	" }}}
	" Values: {{{
	call s:DefineEntityCommon_Nested(a:block, 'Function', a:included)
	" }}}
	
	" Values Separator: {{{
	execute 'syntax match sql'.a:block.'FunctionContentComma nextgroup=@sqlCl'.a:block.'FunctionContent skipwhite skipempty contained display /,/'
	execute 'syntax cluster sqlCl'.a:block.'FunctionContentNext add=sql'.a:block.'FunctionContentComma'
	execute 'highlight link sql'.a:block.'FunctionContentComma sqlComma'
	" }}}
	execute 'syntax cluster sqlCl'.a:block.'FunctionContentNext add=sqlError'
	
	execute 'syntax cluster sqlCl'.a:block.'FunctionContent     add=sqlError'
	execute 'syntax cluster sqlCl'.a:block.'FunctionContentStar add=@sqlCl'.a:block.'FunctionContent'

	execute 'syntax cluster sqlCl'.a:block.'FunctionNext        add=@sqlCl'.a:block.'ContentNext'

	execute 'highlight link sql'.a:block.'FunctionCallDelimiter sqlFunctionCallDelimiter'
endfunction

function! s:DefineEntity_Function (block)
	call s:DefineEntity_Function_real(a:block, 0)
endfunction
		" }}}
	" }}}
	" Group: () {{{
function! s:DefineEntity_Group_real (block, included)
	execute 'syntax region sql'.a:block.'Group nextgroup=@sqlCl'.a:block.'GroupNext skipwhite skipempty contained transparent contains=@sqlCl'.a:block.'GroupContent matchgroup=sql'.a:block.'GroupDelimiter start=/(/ end=/)/'

		" Values: {{{
	call s:DefineEntityCommon_Root  (a:block, 'Group')
	call s:DefineEntityCommon_Nested(a:block, 'Group', a:included)
		" }}}
	execute 'syntax cluster sqlCl'.a:block.'GroupContentNext add=sqlError'

	execute 'syntax cluster sqlCl'.a:block.'GroupNext add=@sqlCl'.a:block.'ContentNext'
	execute 'syntax cluster sqlCl'.a:block.'Content   add=sql'.a:block.'Group'

	execute 'highlight link sql'.a:block.'GroupDelimiter sqlGroupDelimiter'
endfunction
function! s:DefineEntity_Group (block)
	call s:DefineEntity_Group_real(a:block, 0)
endfunction
	" }}}
	" Operation: {{{
		" Calculation: + - * / % {{{
function! s:DefineEntity_OperationCalculation(block)
	execute 'syntax match sql'.a:block.'OperationCalculation nextgroup=@sqlCl'.a:block.'OperationCalculationNext skipwhite skipempty contained display /[-+*\/%]/'

	execute 'syntax cluster sqlCl'.a:block.'OperationCalculationNext add=sqlError,@sqlCl'.a:block.'OperationPartNext'
	execute 'syntax cluster sqlCl'.a:block.'Operation                add=sql'.a:block.'OperationCalculation'
	
	execute 'highlight link sql'.a:block.'OperationCalculation sqlOperationCalculation'
endfunction
		" }}}
		" Comparison: = != <> < <= > >= <! >! IN ANY ALL {{{
			" Operator: = != <> < <= > >= <! >! {{{
function! s:DefineEntity_OperationComparisonOperator(block)
	execute 'syntax match sql'.a:block.'OperationComparisonOperator nextgroup=@sqlCl'.a:block.'OperationComparisonOperatorNext skipwhite skipempty contained display /\(=\|!\(=\|<\|>\)\|<\(>\|=\)\?\|>\(=\)\?\)/'

	execute 'syntax cluster sqlCl'.a:block.'OperationComparisonOperatorNext add=sql'.a:block.'OperationComparisonMultipleOperator,@sqlCl'.a:block.'OperationPartNext'
	execute 'syntax cluster sqlCl'.a:block.'OperationComparison             add=sql'.a:block.'OperationComparisonOperator'
	
	execute 'highlight link sql'.a:block.'OperationComparisonOperator sqlOperationComparisonOperator'
endfunction
			" }}}
			" Multiple: IN ANY ALL {{{
				" Operator: ANY ALL {{{
function! s:DefineEntity_OperationComparisonMultipleOperator(block)
	execute 'syntax keyword sql'.a:block.'OperationComparisonMultipleOperator nextgroup=@sqlCl'.a:block.'OperationComparisonMultipleBlock skipwhite skipempty contained display ANY ALL'
	
	execute 'highlight link sql'.a:block.'OperationComparisonMultipleOperator sqlOperationComparisonMultiple'
endfunction
				" }}}
				" Root: IN {{{
function! s:DefineEntity_OperationComparisonMultipleRoot(block)
	execute 'syntax keyword sql'.a:block.'OperationComparisonMultipleRoot nextgroup=@sqlCl'.a:block.'OperationComparisonMultipleBlock skipwhite skipempty contained display IN'
	
	execute 'syntax cluster sqlCl'.a:block.'OperationComparison add=sql'.a:block.'OperationComparisonMultipleRoot'
	
	execute 'highlight link sql'.a:block.'OperationComparisonMultipleRoot sqlOperationComparisonMultiple'
endfunction
				" }}}
				" Block: (...) {{{
function! s:DefineEntity_OperationComparisonMultipleBlock_real(block, included)
	execute 'syntax region sql'.a:block.'OperationComparisonMultipleBlock nextgroup=@sqlCl'.a:block.'ContentNext skipwhite skipempty contained transparent contains=@sqlCl'.a:block.'OperationComparisonMultipleBlockContent matchgroup=sql'.a:block.'OperationComparisonMultipleBlockDelimiter start=/(/ end=/)/'

					" Values: {{{
	execute 'syntax cluster sqlCl'.a:block.'OperationComparisonMultipleBlockContent add=sqlError'
	
	call s:DefineEntityCommon_Root  (a:block, 'OperationComparisonMultipleBlock')
	call s:DefineEntityCommon_Nested(a:block, 'OperationComparisonMultipleBlock', a:included)
					" }}}

					" Values Separator: {{{
	execute 'syntax match sql'.a:block.'OperationComparisonMultipleBlockContentComma nextgroup=@sqlCl'.a:block.'OperationComparisonMultipleBlockContent skipwhite skipempty contained display /,/'
	execute 'syntax cluster sqlCl'.a:block.'OperationComparisonMultipleBlockContentNext add=sql'.a:block.'OperationComparisonMultipleBlockContentComma'
	execute 'highlight link sql'.a:block.'OperationComparisonMultipleBlockContentComma sqlComma'
					" }}}
	execute 'syntax cluster sqlCl'.a:block.'OperationComparisonMultipleBlockContentNext add=sqlError'
	
	execute 'syntax cluster sqlCl'.a:block.'OperationComparisonMultipleBlock add=sql'.a:block.'OperationComparisonMultipleBlock,sqlError'

	execute 'highlight link sql'.a:block.'OperationComparisonMultipleBlockDelimiter sqlOperationComparisonMultipleBlockDelimiter'
endfunction
function! s:DefineEntity_OperationComparisonMultipleBlock(block)
	call s:DefineEntity_OperationComparisonMultipleBlock_real(a:block, 0)
endfunction
				" }}}

function! s:DefineEntity_OperationComparisonMultiple_real(block, included)
	call s:DefineEntity_OperationComparisonMultipleOperator(a:block)
	call s:DefineEntity_OperationComparisonMultipleRoot    (a:block)

	call s:DefineEntity_OperationComparisonMultipleBlock_real(a:block, a:included)
endfunction
function! s:DefineEntity_OperationComparisonMultiple(block)
	call s:DefineEntity_OperationComparisonMultiple_real(a:block, 0)
endfunction
			" }}}

function! s:DefineEntity_OperationComparison_real(block, included)
	execute 'syntax cluster sqlCl'.a:block.'OperationComparisonMultipleBlock add=sqlError'

	call s:DefineEntity_OperationComparisonOperator     (a:block)
	call s:DefineEntity_OperationComparisonMultiple_real(a:block, a:included)
	
	execute 'syntax cluster sqlCl'.a:block.'Operation add=@sqlCl'.a:block.'OperationComparison'
endfunction
function! s:DefineEntity_OperationComparison(block)
	call s:DefineEntity_OperationComparison_real(a:block, 0)
endfunction
		" }}}
		" Combination: AND OR {{{
function! s:DefineEntity_OperationCombination(block)
	execute 'syntax keyword sql'.a:block.'OperationCombination nextgroup=@sqlCl'.a:block.'OperationCombinationNext skipwhite skipempty contained display AND OR'

	execute 'syntax cluster sqlCl'.a:block.'OperationCombinationNext add=sqlError,@sqlCl'.a:block.'OperationPartNext'
	execute 'syntax cluster sqlCl'.a:block.'Operation                add=sql'.a:block.'OperationCombination'
	
	execute 'highlight link sql'.a:block.'OperationCombination sqlOperationCombination'
endfunction
		" }}}

function! s:DefineEntity_Operation_real (block, included)
	call s:DefineEntity_OperationCalculation    (a:block)
	call s:DefineEntity_OperationComparison_real(a:block, a:included)
	call s:DefineEntity_OperationCombination    (a:block)
	"call s:DefineEntity_OperationTest           (a:block)
endfunction
function! s:DefineEntity_Operation (block)
	call s:DefineEntity_Operation_real(a:block, 0)
endfunction
	" }}}

	" Commons: {{{
function! s:DefineEntityCommon_Root(block, section)
	call s:DefineEntity_Null  (a:block.a:section)
	call s:DefineEntity_Number(a:block.a:section)
	call s:DefineEntity_String(a:block.a:section)
	call s:DefineEntity_Column(a:block.a:section)
endfunction
function! s:DefineEntityCommon_Nested(block, section, included)
	if a:included
		execute 'syntax cluster sqlCl'.a:block.a:section.'Content   add=@sqlCl'.a:block.'Function,sql'.a:block.'Group'
		execute 'syntax cluster sqlCl'.a:block.a:section.'Operation add=@sqlCl'.a:block.'Operation'
	else
		call s:DefineEntity_Function_real (a:block.a:section, 1)
		call s:DefineEntity_Group_real    (a:block.a:section, 1)
		call s:DefineEntity_Operation_real(a:block.a:section, 1)
	endif
endfunction
	" }}}
" }}}

" ERROR: {{{
syntax match sqlError /\S.*/
" }}}

" SELECT: {{{
syntax keyword sqlSelect nextgroup=@sqlClSelectContentStart skipwhite skipempty SELECT

	" DISTINCT: {{{
syntax keyword sqlSelectDistinct nextgroup=@sqlClSelectContent skipwhite skipempty contained DISTINCT
syntax cluster sqlClSelectContentStart add=sqlSelectDistinct

highlight link sqlSelectDistinct sqlFunction
	" }}}

	" Star: * {{{
syntax match sqlSelectStar nextgroup=@sqlClSelectContentNext skipwhite skipempty contained display /\*/
syntax cluster sqlClSelectContent add=sqlSelectStar

highlight link sqlSelectStar sqlStar
	" }}}
	" Values: {{{
call s:DefineEntityCommon_Root('', 'Select')

call s:DefineEntity_Function ('Select')
call s:DefineEntity_Group    ('Select')
call s:DefineEntity_Operation('Select')

call s:DefineFunctionNames   ('Select', 0, 'concat group_concat')
	" }}}
	" Alias AS: {{{
call s:DefineEntity_Alias('Select')
	" }}}
	" Values Separator: {{{
syntax match sqlSelectContentComma nextgroup=@sqlClSelectContent skipwhite skipempty contained display /,/
syntax cluster sqlClSelectContentNext add=sqlSelectContentComma
syntax cluster sqlClSelectAliasNext   add=sqlSelectContentComma

highlight link sqlSelectContentComma sqlComma
	" }}}

syntax cluster sqlClSelectContentNext  add=@sqlClSelectNext
syntax cluster sqlClSelectContentStart add=@sqlClSelectContent

highlight link sqlSelect sqlStructure
" }}}
" INTO: {{{
syntax keyword sqlInto nextgroup=@sqlClIntoContent skipwhite skipempty INTO

	" Variable: {{{
syntax match sqlIntoVarName nextgroup=@sqlClIntoContentNext skipwhite skipempty contained display /\h\w*/
syntax cluster sqlClIntoContent add=sqlIntoVarName
	" }}}
	" Variable Separator: {{{
syntax match sqlIntoContentComma nextgroup=@sqlClIntoContent skipwhite skipempty contained display /,/
syntax cluster sqlClIntoContentNext add=sqlIntoContentComma

highlight link sqlIntoContentComma sqlComma
	" }}}

syntax cluster sqlClSelectNext add=sqlInto

highlight link sqlInto sqlStructure
" }}}
" FROM: {{{
syntax keyword sqlFrom nextgroup=@sqlClFromContent skipwhite skipempty FROM

	" Table: {{{
call s:DefineEntity_Table('From')

		" Alias: AS {{{
call s:DefineEntity_Alias('From')
		" }}}
	" }}}
	
	"" Jointure: norme 87 : , {{{
"syntax match sqlFromJoin87 nextgroup=@sqlClFromJoinContent skipwhite skipempty /,/
"syntax cluster sqlClFromContentNext add=sqlFromJoin87

"highlight link sqlFromJoin87 sqlOperator
	"" }}}
	" Jointure: norme 92 : JOIN {{{
		" JOIN: {{{
syntax keyword sqlFromJoin92Common     nextgroup=sqlFromJoin92Join                         skipwhite skipempty contained INNER CROSS NATURAL
syntax keyword sqlFromJoin92Outer      nextgroup=sqlFromJoin92OuterOuter,sqlFromJoin92Join skipwhite skipempty contained LEFT RIGHT FULL
syntax keyword sqlFromJoin92OuterOuter nextgroup=sqlFromJoin92Join                         skipwhite skipempty contained OUTER
syntax keyword sqlFromJoin92Join       nextgroup=@sqlClFromJoin92Content                   skipwhite skipempty contained JOIN

syntax cluster sqlClFromJoin92 add=sqlFromJoin92Common,sqlFromJoin92Outer,sqlFromJoin92OuterOuter,sqlFromJoin92Join

highlight link sqlFromJoin92Common     sqlFromJoin92
highlight link sqlFromJoin92Outer      sqlFromJoin92
highlight link sqlFromJoin92OuterOuter sqlFromJoin92
highlight link sqlFromJoin92Join       sqlFromJoin92

syntax cluster sqlClFromContentNext add=@sqlClFromJoin92
syntax cluster sqlClFromAliasNext   add=@sqlClFromJoin92

highlight link sqlFromJoin92           sqlStructure
		" }}}
		" Table: {{{
call s:DefineEntity_Table('FromJoin92')

			" Alias: AS {{{
call s:DefineEntity_Alias('FromJoin92')
syntax clear @sqlClFromJoin92AliasNext
			" }}}
		" }}}
		" ON: {{{
syntax keyword sqlFromJoin92On nextgroup=@sqlClFromContentNext skipwhite skipempty contained ON

syntax cluster sqlClFromJoin92ContentNext add=sqlFromJoin92On
syntax cluster sqlClFromJoin92AliasNext   add=sqlFromJoin92On

highlight link sqlFromJoin92On sqlStatement
		" }}}
	" }}}

syntax cluster sqlClSelectNext add=sqlFrom

highlight link sqlFrom sqlStructure
" }}}

" Cleaning: {{{
	" Entities: {{{
delfunction s:DefineEntity_Null
delfunction s:DefineEntity_Number
delfunction s:DefineEntity_String
delfunction s:DefineEntity_Table
delfunction s:DefineEntity_Column
delfunction s:DefineEntity_Alias

		" Function: {{{
delfunction s:DefineEntity_Function
delfunction s:DefineEntity_Function_real

delfunction s:DefineFunctionNames
		" }}}
		" Group: {{{
delfunction s:DefineEntity_Group
delfunction s:DefineEntity_Group_real
		" }}}
		" Operation: {{{
delfunction s:DefineEntity_OperationCalculation
			" Comparison: {{{
delfunction s:DefineEntity_OperationComparisonOperator
				" Multiple: {{{
delfunction s:DefineEntity_OperationComparisonMultipleOperator
delfunction s:DefineEntity_OperationComparisonMultipleRoot
					" Block: {{{
delfunction s:DefineEntity_OperationComparisonMultipleBlock
delfunction s:DefineEntity_OperationComparisonMultipleBlock_real
					" }}}
					"
delfunction s:DefineEntity_OperationComparisonMultiple
delfunction s:DefineEntity_OperationComparisonMultiple_real
				" }}}

delfunction s:DefineEntity_OperationComparison
delfunction s:DefineEntity_OperationComparison_real
			" }}}
delfunction s:DefineEntity_OperationCombination
"delfunction s:DefineEntity_OperationTest

delfunction s:DefineEntity_Operation
delfunction s:DefineEntity_Operation_real
		" }}}

		" Commons: {{{
delfunction s:DefineEntityCommon_Root
delfunction s:DefineEntityCommon_Nested
		" }}}
	" }}}
" }}}

" COLORS: {{{
highlight link sqlAliasAs									sqlStructure
highlight link sqlAliasName									sqlNone
highlight link sqlAliasDelimiter							Delimiter
highlight link sqlComma										Operator
highlight link sqlColumn									sqlNone
highlight link sqlColumnDelimiter							Delimiter
highlight link sqlError										Error
highlight link sqlEscape									Special
highlight link sqlFunction									Function
highlight link sqlFunctionUser								Operator
highlight link sqlFunctionCallDelimiter						Operator
highlight link sqlGroupDelimiter							Operator
highlight link sqlNull										Statement
highlight link sqlNumber									Number
highlight link sqlOperationCalculation						Operator
highlight link sqlOperationComparisonOperator				Operator
highlight link sqlOperationComparisonMultiple				Statement
highlight link sqlOperationComparisonMultipleBlockDelimiter	Operator
highlight link sqlOperationCombination						Statement
highlight link sqlStar										Operator
highlight link sqlStatement									Statement
highlight link sqlString									String
highlight link sqlStringDelimiter							sqlString
highlight link sqlStructure									Structure
highlight link sqlTable										sqlNone
highlight link sqlTableDelimiter							Delimiter
highlight link sqlTableSeparator							Operator

highlight link sqlNone						Todo
highlight link sqlIntoVarName				sqlNone
highlight link sqlFromTable					sqlNone
" }}}

let b:current_syntax = "sql"
