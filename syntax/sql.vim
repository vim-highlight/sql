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
	" NOT: {{{
function! s:DefineEntity_Not_real (block, included)
		" NOT: {{{
	execute 'syntax keyword sql'.a:block.'Not nextgroup=@sqlCl'.a:block.'NotContent skipwhite skipempty contained display NOT'

	execute 'syntax cluster sqlCl'.a:block.'Content           add=sql'.a:block.'Not'

	execute 'highlight default link sql'.a:block.'Not sqlNot'
		" }}}
		" ... {{{
	execute 'syntax cluster sqlCl'.a:block.'NotContent add=sqlError'
			" Values: {{{
	call s:DefineEntityCommon_Root  (a:block, 'Not')
	call s:DefineEntityCommon_Nested(a:block, 'Not', a:included)
			" }}}
		" }}}
endfunction
function! s:DefineEntity_Not (block)
	call s:DefineEntity_Not_real(a:block, 0)
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

			" Function names {{{
	call s:DefineFunctionNames(a:block, 0, 'sum min max')
	call s:DefineFunctionNames(a:block, 1, 'count')
	execute 'syntax match sql'.a:block.'FunctionUser nextgroup=sql'.a:block.'FunctionCallStar skipwhite skipempty contained /\h\w*\(\s*(\)\@=/'

	execute 'syntax cluster sqlCl'.a:block.'Function add=sql'.a:block.'FunctionCommon,sql'.a:block.'FunctionCommonStar,sql'.a:block.'FunctionUser'
	execute 'syntax cluster sqlCl'.a:block.'Content add=@sqlCl'.a:block.'Function'

	execute 'highlight default link sql'.a:block.'FunctionCommon     sql'.a:block.'Function'
	execute 'highlight default link sql'.a:block.'FunctionCommonStar sql'.a:block.'Function'

	execute 'highlight default link sql'.a:block.'Function     sqlFunction'
	execute 'highlight default link sql'.a:block.'FunctionUser sqlFunctionUser'
			" }}}
			" (... ,) {{{
				" () {{{
	execute 'syntax region sql'.a:block.'FunctionCall     nextgroup=@sqlCl'.a:block.'FunctionNext skipwhite skipempty contained transparent contains=@sqlCl'.a:block.'FunctionContent     matchgroup=sql'.a:block.'FunctionCallDelimiter start=/(/ end=/)/'
	execute 'syntax region sql'.a:block.'FunctionCallStar nextgroup=@sqlCl'.a:block.'FunctionNext skipwhite skipempty contained transparent contains=@sqlCl'.a:block.'FunctionContentStar matchgroup=sql'.a:block.'FunctionCallDelimiter start=/(/ end=/)/'

	execute 'syntax cluster sqlCl'.a:block.'FunctionNext add=@sqlCl'.a:block.'Operation,@sqlCl'.a:block.'ContentNext'

	execute 'highlight default link sql'.a:block.'FunctionCallDelimiter sqlFunctionCallDelimiter'
				" }}}
				" ... {{{
					" Star: * {{{
	execute 'syntax match sql'.a:block.'FunctionContentStarStar nextgroup=@sqlCl'.a:block.'FunctionContentNext skipwhite skipempty contained display /\*/'

	execute 'syntax cluster sqlCl'.a:block.'FunctionContentStar add=sql'.a:block.'FunctionContentStarStar'
	execute 'syntax cluster sqlCl'.a:block.'FunctionContentStar add=@sqlCl'.a:block.'FunctionContent'

	execute 'highlight default link sql'.a:block.'FunctionContentStarStar sqlFunctionContentStar'
					" }}}
					" Values: {{{
	call s:DefineEntityCommon_Nested(a:block, 'Function', a:included)

	execute 'syntax cluster sqlCl'.a:block.'FunctionContent add=sqlError'
					" }}}
				" }}}
				" Values Separator: , {{{
	execute 'syntax match sql'.a:block.'FunctionContentComma nextgroup=@sqlCl'.a:block.'FunctionContent skipwhite skipempty contained display /,/'

	execute 'syntax cluster sqlCl'.a:block.'FunctionContentNext add=sqlError'
	execute 'syntax cluster sqlCl'.a:block.'FunctionContentNext add=sql'.a:block.'FunctionContentComma'

	execute 'highlight default link sql'.a:block.'FunctionContentComma sqlFunctionComma'
				" }}}
			" }}}
endfunction

function! s:DefineEntity_Function (block)
	call s:DefineEntity_Function_real(a:block, 0)
endfunction
		" }}}
	" }}}
	" Group: () {{{
function! s:DefineEntity_Group_real (block, included)
		" (...) {{{
			" () {{{
	execute 'syntax region sql'.a:block.'Group nextgroup=@sqlCl'.a:block.'GroupNext skipwhite skipempty contained transparent contains=@sqlCl'.a:block.'GroupContent matchgroup=sql'.a:block.'GroupDelimiter start=/(/ end=/)/'

	execute 'syntax cluster sqlCl'.a:block.'GroupNext add=@sqlCl'.a:block.'Operation,@sqlCl'.a:block.'ContentNext'
	execute 'syntax cluster sqlCl'.a:block.'Content   add=sql'.a:block.'Group'

	execute 'highlight default link sql'.a:block.'GroupDelimiter sqlGroupDelimiter'
			" }}}
			" ... {{{
	execute 'syntax cluster sqlCl'.a:block.'GroupContentNext add=sqlError'
				" Values: {{{
	call s:DefineEntityCommon_Root  (a:block, 'Group')
	call s:DefineEntityCommon_Nested(a:block, 'Group', a:included)
				" }}}
			" }}}
		" }}}
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
	
	execute 'highlight default link sql'.a:block.'OperationCalculation sqlOperationCalculation'
endfunction
		" }}}
		" Comparison: = != <> < <= > >= <! >! IN ANY ALL {{{
			" Operator: = != <> < <= > >= <! >! {{{
function! s:DefineEntity_OperationComparisonOperator(block)
	execute 'syntax match sql'.a:block.'OperationComparisonOperator nextgroup=@sqlCl'.a:block.'OperationComparisonOperatorNext skipwhite skipempty contained display /\(=\|!\(=\|<\|>\)\|<\(>\|=\)\?\|>\(=\)\?\)/'

	execute 'syntax cluster sqlCl'.a:block.'OperationComparisonOperatorNext add=sql'.a:block.'OperationComparisonMultipleOperator,@sqlCl'.a:block.'OperationPartNext'
	execute 'syntax cluster sqlCl'.a:block.'OperationComparison             add=sql'.a:block.'OperationComparisonOperator'
	
	execute 'highlight default link sql'.a:block.'OperationComparisonOperator sqlOperationComparisonOperator'
endfunction
			" }}}
			" Multiple: ANY ALL {{{
				" Operator: ANY ALL {{{
function! s:DefineEntity_OperationComparisonMultipleOperator(block)
	execute 'syntax keyword sql'.a:block.'OperationComparisonMultipleOperator nextgroup=@sqlCl'.a:block.'OperationComparisonMultipleOperatorBlock skipwhite skipempty contained display ANY ALL'
	
	execute 'highlight default link sql'.a:block.'OperationComparisonMultipleOperator sqlOperationComparisonMultiple'
endfunction
				" }}}

function! s:DefineEntity_OperationComparisonMultiple_real(block, included)
	call s:DefineEntity_OperationComparisonMultipleOperator(a:block)
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
	
	execute 'highlight default link sql'.a:block.'OperationCombination sqlOperationCombination'
endfunction
		" }}}
		" Test: [NOT] IS, IN, BETWEEN, LIKE {{{
			" NOT: {{{
function! s:DefineEntity_OperationTestNot(block)
	execute 'syntax keyword sql'.a:block.'OperationTestNot nextgroup=@sqlCl'.a:block.'OperationTestNotNext skipwhite skipempty contained display NOT'
	
	execute 'syntax cluster sqlCl'.a:block.'OperationTest        add=sql'.a:block.'OperationTestNot'
	execute 'syntax cluster sqlCl'.a:block.'OperationTestNotNext add=sqlError'
	
	execute 'highlight default link sql'.a:block.'OperationTestNot sqlOperationTestNot'
endfunction
			" }}}
			" IS [NOT] NULL {{{
function! s:DefineEntity_OperationTestIs(block)
				" IS: {{{
	execute 'syntax keyword sql'.a:block.'OperationTestIs nextgroup=@sqlCl'.a:block.'OperationTestIsNext   skipwhite skipempty contained IS'

	execute 'syntax cluster sqlCl'.a:block.'OperationTest       add=sql'.a:block.'OperationTestIs'
	execute 'syntax cluster sqlCl'.a:block.'OperationTestIsNext add=sql'.a:block.'OperationTestIsNot,sql'.a:block.'OperationTestIsNull,sqlError'

	execute 'highlight default link sql'.a:block.'OperationTestIs sqlOperationTestIs'
				" }}}
				" NOT: {{{
	execute 'syntax keyword sql'.a:block.'OperationTestIsNot nextgroup=@sqlCl'.a:block.'OperationTestIsNotNext skipwhite skipempty contained NOT'

	execute 'syntax cluster sqlCl'.a:block.'OperationTestIsNotNext add=sql'.a:block.'OperationTestIsNull,sqlError'

	execute 'highlight default link sql'.a:block.'OperationTestIsNot sqlOperationTestIsNot'
				" }}}
				" NULL: {{{
	execute 'syntax keyword sql'.a:block.'OperationTestIsNull nextgroup=@sqlCl'.a:block.'OperationTestIsNullNext skipwhite skipempty contained NULL'

	execute 'syntax cluster sqlCl'.a:block.'OperationTestIsNullNext add=@sqlCl'.a:block.'Operation,@sqlCl'.a:block.'ContentNext,sqlError'

	execute 'highlight default link sql'.a:block.'OperationTestIsNull sqlOperationTestIsNull'
				" }}}
endfunction
			" }}}
			" IN (...) {{{
function! s:DefineEntity_OperationTestIn_real(block, included)
				" IN: {{{
	execute 'syntax keyword sql'.a:block.'OperationTestIn nextgroup=@sqlCl'.a:block.'OperationTestInNext skipwhite skipempty contained display IN'
	
	execute 'syntax cluster sqlCl'.a:block.'OperationTest        add=sql'.a:block.'OperationTestIn'
	execute 'syntax cluster sqlCl'.a:block.'OperationTestNotNext add=sql'.a:block.'OperationTestIn'
	execute 'syntax cluster sqlCl'.a:block.'OperationTestInNext  add=sqlError'
	
	execute 'highlight default link sql'.a:block.'OperationTestIn sqlOperationTestIn'
				" }}}
				" (... ,) {{{
	execute 'syntax cluster sqlCl'.a:block.'OperationTestInBlock add=sqlError'
	execute 'syntax cluster sqlCl'.a:block.'OperationTestInNext  add=@sqlCl'.a:block.'OperationTestInBlock'

					" () {{{
	execute 'syntax region sql'.a:block.'OperationTestInBlock nextgroup=@sqlCl'.a:block.'OperationTestInBlockNext skipwhite skipempty contained transparent contains=@sqlCl'.a:block.'OperationTestInBlockContent matchgroup=sql'.a:block.'OperationTestInBlockDelimiter start=/(/ end=/)/'

	execute 'syntax cluster sqlCl'.a:block.'OperationTestInNext      add=sql'.a:block.'OperationTestInBlock'
	execute 'syntax cluster sqlCl'.a:block.'OperationTestInBlockNext add=@sqlCl'.a:block.'Operation,@sqlCl'.a:block.'ContentNext'

	execute 'highlight default link sql'.a:block.'OperationTestInBlockDelimiter sqlOperationTestInBlockDelimiter'
					" }}}
					" ... {{{
	execute 'syntax cluster sqlCl'.a:block.'OperationTestInBlockContent add=sqlError'

						" Values: {{{
	call s:DefineEntityCommon_Root  (a:block, 'OperationTestInBlock')
	call s:DefineEntityCommon_Nested(a:block, 'OperationTestInBlock', a:included)
						" }}}
					" }}}
					" , {{{
	execute 'syntax cluster sqlCl'.a:block.'OperationTestInBlockContentNext add=sqlError'
						" Values Separator: {{{
	execute 'syntax match sql'.a:block.'OperationTestInBlockContentComma nextgroup=@sqlCl'.a:block.'OperationTestInBlockContent skipwhite skipempty contained display /,/'

	execute 'syntax cluster sqlCl'.a:block.'OperationTestInBlockContentNext add=sql'.a:block.'OperationTestInBlockContentComma'

	execute 'highlight default link sql'.a:block.'OperationTestInBlockContentComma sqlOperationTestInComma'
						" }}}
				" }}}
endfunction
function! s:DefineEntity_OperationTestIn(block)
	call s:DefineEntity_OperationTestIn_real(a:block, 0)
endfunction
				" }}}
			" }}}
			" BETWEEN ... AND ... {{{
function! s:DefineEntity_OperationTestBetween_real(block, included)
				" BETWEEN: {{{
	execute 'syntax keyword sql'.a:block.'OperationTestBetween nextgroup=@sqlCl'.a:block.'OperationTestBetweenContent skipwhite skipempty contained BETWEEN'

	execute 'syntax cluster sqlCl'.a:block.'OperationTest        add=sql'.a:block.'OperationTestBetween'
	execute 'syntax cluster sqlCl'.a:block.'OperationTestNotNext add=sql'.a:block.'OperationTestBetween'

	execute 'highlight default link sql'.a:block.'OperationTestBetween sqlOperationTestBetween'
				" }}}
				" ... [1] {{{
					" Values: {{{
	call s:DefineEntityCommon_Nested(a:block, 'OperationTestBetween', a:included)
	call s:DefineEntityCommon_Root  (a:block, 'OperationTestBetween')
					" }}}
	
	execute 'syntax cluster sqlCl'.a:block.'OperationTestBetweenContentNext add=@sqlCl'.a:block.'Operation,sqlError'
				" }}}
				" AND: {{{
	execute 'syntax keyword sql'.a:block.'OperationTestBetweenAnd nextgroup=@sqlCl'.a:block.'OperationTestBetweenAndContent skipwhite skipempty contained AND'

	execute 'syntax cluster sqlCl'.a:block.'OperationTestBetweenContentNext add=sql'.a:block.'OperationTestBetweenAnd'

	execute 'highlight default link sql'.a:block.'OperationTestBetweenAnd sqlOperationTestBetweenAnd'
				" }}}
				" ... [2] {{{
					" Values: {{{
	call s:DefineEntityCommon_Root  (a:block, 'OperationTestBetweenAnd')
	call s:DefineEntityCommon_Nested(a:block, 'OperationTestBetweenAnd', a:included)
					" }}}
	
	execute 'syntax cluster sqlCl'.a:block.'OperationTestBetweenAndContentNext add=@sqlCl'.a:block.'Operation,@sqlCl'.a:block.'ContentNext,sqlError'
				" }}}
endfunction
function! s:DefineEntity_OperationTestBetween(block)
	call s:DefineEntity_OperationTestBetween_real(a:block, 0)
endfunction
			" }}}
			" LIKE ... {{{
function! s:DefineEntity_OperationTestLike_real(block, included)
				" LIKE: {{{
	execute 'syntax keyword sql'.a:block.'OperationTestLike nextgroup=@sqlCl'.a:block.'OperationTestLikeContent skipwhite skipempty contained display LIKE'
	
	execute 'syntax cluster sqlCl'.a:block.'OperationTest         add=sql'.a:block.'OperationTestLike'
	execute 'syntax cluster sqlCl'.a:block.'OperationTestNotNext  add=sql'.a:block.'OperationTestLike'
	
	execute 'highlight default link sql'.a:block.'OperationTestLike sqlOperationTestLike'
				" }}}
				" ... {{{
	execute 'syntax cluster sqlCl'.a:block.'OperationTestLikeContent add=sqlError'
						" Values: {{{
	call s:DefineEntityCommon_Root  (a:block, 'OperationTestLike')
	call s:DefineEntityCommon_Nested(a:block, 'OperationTestLike', a:included)

							" String : % {{{
	execute 'syntax match sql'.a:block.'OperationTestLikeStringPercent contained display /%/'

	execute 'syntax cluster sqlCl'.a:block.'OperationTestLikeStringContent add=sql'.a:block.'OperationTestLikeStringPercent'

	execute 'highlight default link sql'.a:block.'OperationTestLikeStringPercent sqlOperationTestLikeStringPercent'
							" }}}
						" }}}
				" }}}
endfunction
function! s:DefineEntity_OperationTestLike(block)
	call s:DefineEntity_OperationTestLike_real(a:block, 0)
endfunction
			" }}}

function! s:DefineEntity_OperationTest_real(block, included)
	call s:DefineEntity_OperationTestNot         (a:block)
	call s:DefineEntity_OperationTestIs          (a:block)
	call s:DefineEntity_OperationTestIn_real     (a:block, a:included)
	call s:DefineEntity_OperationTestBetween_real(a:block, a:included)
	call s:DefineEntity_OperationTestLike_real   (a:block, a:included)

	execute 'syntax cluster sqlCl'.a:block.'Operation add=@sqlCl'.a:block.'OperationTest'
endfunction
function! s:DefineEntity_OperationTest(block)
	call s:DefineEntity_OperationTest_real(a:block, 0)
endfunction
		" }}}

function! s:DefineEntity_Operation_real (block, included)
	call s:DefineEntity_OperationCalculation    (a:block)
	call s:DefineEntity_OperationComparison_real(a:block, a:included)
	call s:DefineEntity_OperationCombination    (a:block)
	call s:DefineEntity_OperationTest_real      (a:block, a:included)
endfunction
function! s:DefineEntity_Operation (block)
	call s:DefineEntity_Operation_real(a:block, 0)
endfunction
	" }}}

	" Null: {{{
function! s:DefineEntity_Null (block)
	execute 'syntax keyword sql'.a:block.'Null nextgroup=@sqlCl'.a:block.'NullNext skipwhite skipempty contained display NULL'

	execute 'syntax cluster sqlCl'.a:block.'NullNext          add=@sqlCl'.a:block.'Operation,@sqlCl'.a:block.'ContentNext'
	execute 'syntax cluster sqlCl'.a:block.'Content           add=sql'.a:block.'Null'
	execute 'syntax cluster sqlCl'.a:block.'OperationPartNext add=sql'.a:block.'Null'

	execute 'highlight default link sql'.a:block.'Null sqlNull'
endfunction
	" }}}
	" Number: {{{
function! s:DefineEntity_Number (block)
	execute 'syntax match sql'.a:block.'Number nextgroup=@sqlCl'.a:block.'NumberNext skipwhite skipempty contained display /[+-]\?[0-9]\+\(\.[0-9]\+\)\?/'

	execute 'syntax cluster sqlCl'.a:block.'NumberNext        add=@sqlCl'.a:block.'Operation,@sqlCl'.a:block.'ContentNext'
	execute 'syntax cluster sqlCl'.a:block.'Content           add=sql'.a:block.'Number'
	execute 'syntax cluster sqlCl'.a:block.'OperationPartNext add=sql'.a:block.'Number'

	execute 'highlight default link sql'.a:block.'Number sqlNumber'
endfunction
	" }}}
	" String: {{{
function! s:DefineEntity_String (block)
	execute 'syntax region sql'.a:block.'StringSingle nextgroup=@sqlCl'.a:block.'StringSingleNext skipwhite skipempty contained contains=@sqlCl'.a:block.'StringSingleContent matchgroup=sql'.a:block.'StringSingleDelimiter start=/''/ skip=/\\''/ end=/''/'
	execute 'syntax region sql'.a:block.'StringDouble nextgroup=@sqlCl'.a:block.'StringDoubleNext skipwhite skipempty contained contains=@sqlCl'.a:block.'StringDoubleContent matchgroup=sql'.a:block.'StringDoubleDelimiter start=/"/  skip=/\\"/  end=/"/ '

	execute 'syntax cluster sqlCl'.a:block.'StringSingleNext add=@sqlCl'.a:block.'StringNext'
	execute 'syntax cluster sqlCl'.a:block.'StringDoubleNext add=@sqlCl'.a:block.'StringNext'
	execute 'syntax cluster sqlCl'.a:block.'StringNext       add=@sqlCl'.a:block.'Operation,@sqlCl'.a:block.'ContentNext'

	execute 'syntax cluster sqlCl'.a:block.'StringSingleContent add=@sqlCl'.a:block.'StringContent'
	execute 'syntax cluster sqlCl'.a:block.'StringDoubleContent add=@sqlCl'.a:block.'StringContent'

	execute 'syntax cluster sqlCl'.a:block.'String            add=sql'.a:block.'StringSingle,sql'.a:block.'StringDouble'
	execute 'syntax cluster sqlCl'.a:block.'Content           add=@sqlCl'.a:block.'String'
	execute 'syntax cluster sqlCl'.a:block.'OperationPartNext add=@sqlCl'.a:block.'String'

	execute 'highlight default link sql'.a:block.'StringSingleDelimiter sql'.a:block.'StringDelimiter'
	execute 'highlight default link sql'.a:block.'StringDoubleDelimiter sql'.a:block.'StringDelimiter'

	execute 'highlight default link sql'.a:block.'StringSingle sql'.a:block.'String'
	execute 'highlight default link sql'.a:block.'StringDouble sql'.a:block.'String'

	execute 'highlight default link sql'.a:block.'StringDelimiter sqlStringDelimiter'
	execute 'highlight default link sql'.a:block.'String          sqlString'
endfunction
	" }}}
	" Table: {{{
function! s:DefineEntity_Table (block)
	execute 'syntax region sql'.a:block.'TableEscaped nextgroup=@sqlCl'.a:block.'TableNext skipwhite skipempty contained display transparent oneline contains=sql'.a:block.'Table matchgroup=sql'.a:block.'TableDelimiter start=/`/ end=/`/'
	execute 'syntax match  sql'.a:block.'Table        nextgroup=@sqlCl'.a:block.'TableNext skipwhite skipempty contained display /\h\w*/'

	execute 'syntax cluster sqlCl'.a:block.'TableNext add=@sqlCl'.a:block.'ContentNext'
	execute 'syntax cluster sqlCl'.a:block.'Content   add=sql'.a:block.'TableEscaped,sql'.a:block.'Table'

	execute 'highlight default link sql'.a:block.'TableDelimiter sqlTableDelimiter'
	execute 'highlight default link sql'.a:block.'Table          sqlTable'
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

	execute 'highlight default link sql'.a:block.'ColumnDelimiter sqlColumnDelimiter'
	execute 'highlight default link sql'.a:block.'Column          sqlColumn'
		" }}}
		" table. {{{
			" table {{{
	execute 'syntax region sql'.a:block.'ColumnTableEscaped nextgroup=sql'.a:block.'ColumnTableSeparator contained display transparent oneline contains=sql'.a:block.'ColumnTableSingle matchgroup=sql'.a:block.'ColumnTableDelimiter start=/`/ end=/`\(\.\)\@=/'
	execute 'syntax match  sql'.a:block.'ColumnTableSingle  nextgroup=sql'.a:block.'ColumnTableSeparator contained display /\h\w*/'
	execute 'syntax match  sql'.a:block.'ColumnTable        nextgroup=sql'.a:block.'ColumnTableSeparator contained display /\h\w*\(\.\)\@=/'

	execute 'syntax cluster sqlCl'.a:block.'Content add=sql'.a:block.'ColumnTableEscaped,sql'.a:block.'ColumnTable'

	execute 'highlight default link sql'.a:block.'ColumnTableSingle    sql'.a:block.'ColumnTable'

	execute 'highlight default link sql'.a:block.'ColumnTableDelimiter sqlColumnTableDelimiter'
	execute 'highlight default link sql'.a:block.'ColumnTable          sqlColumnTable'
			" }}}
			" . {{{
	execute 'syntax match sql'.a:block.'ColumnTableSeparator nextgroup=@sqlCl'.a:block.'Column contained display /\./'
	execute 'highlight default link sql'.a:block.'ColumnTableSeparator sqlColumnTableSeparator'
			" }}}
		" }}}
endfunction
	" }}}
	" Alias: AS {{{
function! s:DefineEntity_Alias (block)
		" AS: {{{
	execute 'syntax keyword sql'.a:block.'AliasAs nextgroup=@sqlCl'.a:block.'AliasName skipwhite skipempty contained AS'

	execute 'syntax cluster sqlCl'.a:block.'ContentNext add=sql'.a:block.'AliasAs'
	execute 'syntax cluster sqlCl'.a:block.'AliasNext   add=@sqlCl'.a:block.'Next'

	execute 'highlight default link sql'.a:block.'AliasAs sqlAliasAs'
		" }}}
		" Name: {{{
	execute 'syntax region sql'.a:block.'AliasEscaped nextgroup=@sqlCl'.a:block.'AliasNext skipwhite skipempty contained display transparent oneline contains=sql'.a:block.'AliasName matchgroup=sql'.a:block.'AliasNameDelimiter start=/`/ end=/`/'
	execute 'syntax match  sql'.a:block.'AliasName    nextgroup=@sqlCl'.a:block.'AliasNext skipwhite skipempty contained display /\h\w*/'

	execute 'syntax cluster sqlCl'.a:block.'AliasName add=sql'.a:block.'AliasEscaped,sql'.a:block.'AliasName'

	execute 'highlight default link sql'.a:block.'AliasNameDelimiter sqlAliasNameDelimiter'
	execute 'highlight default link sql'.a:block.'AliasName          sqlAliasName'
		" }}}
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
		execute 'syntax cluster sqlCl'.a:block.a:section.'Content   add=@sqlCl'.a:block.'Function,sql'.a:block.'Group,sql'.a:block.'Not'
		execute 'syntax cluster sqlCl'.a:block.a:section.'Operation add=@sqlCl'.a:block.'Operation'
	else
		call s:DefineEntity_Not_real      (a:block.a:section, 1)
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
	" SELECT: {{{
syntax keyword sqlSelect nextgroup=@sqlClSelectContentStart skipwhite skipempty SELECT

syntax cluster sqlClSelectContentNext  add=@sqlClSelectNext
syntax cluster sqlClSelectContentStart add=@sqlClSelectContent
	" }}}
	" __CONTENT__ {{{
		" DISTINCT: {{{
syntax keyword sqlSelectDistinct nextgroup=@sqlClSelectContent skipwhite skipempty contained DISTINCT

syntax cluster sqlClSelectContentStart add=sqlSelectDistinct

highlight default link sqlSelectDistinct sqlDistinct
		" }}}

		" Star: * {{{
syntax match sqlSelectStar nextgroup=@sqlClSelectContentNext skipwhite skipempty contained display /\*/
syntax cluster sqlClSelectContent add=sqlSelectStar

highlight default link sqlSelectStar sqlStar
		" }}}
		" Values: {{{
call s:DefineEntityCommon_Root  ('', 'Select')
call s:DefineEntityCommon_Nested('', 'Select', 0)

call s:DefineFunctionNames   ('Select', 0, 'concat group_concat')
		" }}}
		
		" Alias AS: {{{
call s:DefineEntity_Alias('Select')
		" }}}
		
		" Values Separator: {{{
syntax match sqlSelectContentComma nextgroup=@sqlClSelectContent skipwhite skipempty contained display /,/

syntax cluster sqlClSelectContentNext add=sqlSelectContentComma
syntax cluster sqlClSelectAliasNext   add=sqlSelectContentComma

highlight default link sqlSelectContentComma sqlComma
		" }}}
	" }}}
" }}}
" INTO: {{{
	" INTO: {{{
syntax keyword sqlInto nextgroup=@sqlClIntoContent skipwhite skipempty INTO

syntax cluster sqlClSelectNext add=sqlInto
	" }}}
	" __CONTENT__ {{{
		" Variable: {{{
syntax match sqlIntoVarName nextgroup=@sqlClIntoContentNext skipwhite skipempty contained display /\h\w*/
syntax cluster sqlClIntoContent add=sqlIntoVarName
		" }}}

		" Variable Separator: {{{
syntax match sqlIntoContentComma nextgroup=@sqlClIntoContent skipwhite skipempty contained display /,/
syntax cluster sqlClIntoContentNext add=sqlIntoContentComma

highlight default link sqlIntoContentComma sqlComma
		" }}}
	" }}}
" }}}
" FROM: {{{
	" FROM: {{{
syntax keyword sqlFrom nextgroup=@sqlClFromContent skipwhite skipempty FROM

syntax cluster sqlClSelectNext add=sqlFrom
	" }}}
	" __CONTENT__ {{{
		" Table: {{{
call s:DefineEntity_Table('From')
			" Alias: AS {{{
call s:DefineEntity_Alias('From')
			" }}}
		" }}}
	
		" Jointure: norme 87 : , {{{
syntax match sqlFromJoin87 nextgroup=@sqlClFromContent skipwhite skipempty /,/

syntax cluster sqlClFromContentNext add=sqlFromJoin87
		" }}}
		" Jointure: norme 92 : JOIN {{{
			" JOIN: {{{
syntax keyword sqlFromJoin92Common     nextgroup=sqlFromJoin92Join                         skipwhite skipempty contained INNER CROSS NATURAL
syntax keyword sqlFromJoin92Outer      nextgroup=sqlFromJoin92OuterOuter,sqlFromJoin92Join skipwhite skipempty contained LEFT RIGHT FULL
syntax keyword sqlFromJoin92OuterOuter nextgroup=sqlFromJoin92Join                         skipwhite skipempty contained OUTER
syntax keyword sqlFromJoin92Join       nextgroup=@sqlClFromJoin92Content                   skipwhite skipempty contained JOIN

syntax cluster sqlClFromJoin92 add=sqlFromJoin92Common,sqlFromJoin92Outer,sqlFromJoin92OuterOuter,sqlFromJoin92Join

highlight default link sqlFromJoin92Common     sqlFromJoin92
highlight default link sqlFromJoin92Outer      sqlFromJoin92
highlight default link sqlFromJoin92OuterOuter sqlFromJoin92
highlight default link sqlFromJoin92Join       sqlFromJoin92

syntax cluster sqlClFromContentNext add=@sqlClFromJoin92
syntax cluster sqlClFromAliasNext   add=@sqlClFromJoin92
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
			" }}}
		" }}}
	" }}}
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
					"
delfunction s:DefineEntity_OperationComparisonMultiple
delfunction s:DefineEntity_OperationComparisonMultiple_real
				" }}}

delfunction s:DefineEntity_OperationComparison
delfunction s:DefineEntity_OperationComparison_real
			" }}}
delfunction s:DefineEntity_OperationCombination
			" Test: {{{
delfunction s:DefineEntity_OperationTestNot
delfunction s:DefineEntity_OperationTestIs
				" IN {{{
delfunction s:DefineEntity_OperationTestIn
delfunction s:DefineEntity_OperationTestIn_real
				" }}}
				" BETWEEN ... AND {{{
delfunction s:DefineEntity_OperationTestBetween
delfunction s:DefineEntity_OperationTestBetween_real
				" }}}
				" LIKE {{{
delfunction s:DefineEntity_OperationTestLike
delfunction s:DefineEntity_OperationTestLike_real
				" }}}

delfunction s:DefineEntity_OperationTest
delfunction s:DefineEntity_OperationTest_real
			" }}}

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
	" Internal: {{{
highlight default link sqlSelect                         sqlStructure
highlight default link sqlInto                           sqlStructure
highlight default link sqlFrom                           sqlStructure

highlight default link sqlDistinct                       sqlStructureSecondary

highlight default link sqlAliasAs                        sqlLink
highlight default link sqlAliasName                      sqlName

highlight default link sqlStringDelimiter                sqlString
highlight default link sqlColumnDelimiter                sqlDelimiter
highlight default link sqlTableDelimiter                 sqlDelimiter
highlight default link sqlColumnTableDelimiter           sqlDelimiter
highlight default link sqlAliasNameDelimiter             sqlDelimiter

highlight default link sqlColumn                         sqlName
highlight default link sqlTable                          sqlName
highlight default link sqlColumnTable                    sqlName

highlight default link sqlFunctionCallDelimiter          sqlOperator
highlight default link sqlGroupDelimiter                 sqlOperator

highlight default link sqlOperationCalculation           sqlOperator
highlight default link sqlOperationComparisonOperator    sqlOperator

highlight default link sqlOperationTestNot				 sqlTest

highlight default link sqlOperationTestIn                sqlTest
highlight default link sqlOperationTestInBlockDelimiter  sqlOperator
highlight default link sqlOperationTestInComma           sqlComma

highlight default link sqlOperationTestIs                sqlTest
highlight default link sqlOperationTestIsNot             sqlTest
highlight default link sqlOperationTestIsNull            sqlTest

highlight default link sqlOperationTestBetween           sqlTest
highlight default link sqlOperationTestBetweenAnd        sqlTest

highlight default link sqlOperationTestLike              sqlTest
highlight default link sqlOperationTestLikeStringPercent sqlCharSpecial

highlight default link sqlOperationCombination           sqlLink

highlight default link sqlFunctionContentStar            sqlStar

highlight default link sqlComma                          sqlOperator
highlight default link sqlStar                           sqlOperator
highlight default link sqlNot                            sqlTest

highlight default link sqlFromJoin87                     sqlOperator
highlight default link sqlFromJoin92                     sqlLink
highlight default link sqlFromJoin92On                   sqlLinkSecondary
	" }}}
	" External: {{{
highlight default link sqlError              Error
highlight default link sqlStructure          Structure
highlight default link sqlStructureSecondary StorageClass

highlight default link sqlLink               Statement
highlight default link sqlLinkSecondary      Special

highlight default link sqlNull				 Keyword
highlight default link sqlNumber			 Number
highlight default link sqlString             String

highlight default link sqlName               None
highlight default link sqlDelimiter          Delimiter

highlight default link sqlFunction           Function
highlight default link sqlFunctionUser       Operator

highlight default link sqlOperator           Operator

highlight default link sqlTest               Conditional

highlight default link sqlCharSpecial        SpecialChar
	" }}}
" }}}

let b:current_syntax = "sql"
