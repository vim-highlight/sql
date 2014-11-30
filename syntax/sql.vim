" Vim syntax file for SQL
" Language:     SQL standard / Support for drivers specifics
" Maintainer:   Julien Rosset <jul.rosset@gmail.com>
"
" URL:          https://github.com/darkelfe/vim-highlight
" Version:      0.0.1

" For VIM version 5.x: Clear all syntax items
" For VIM version 6.x: Quit when a syntax file was already loaded
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
"   source! sql/s:driver.vim
"endif
" }}}

" Tools: define {{{
function Tool_addToContainerGroups (block, entity, options, cluster)
    let in_groups = []
    if has_key(a:options, 'in')
        if has_key(a:options.in, 'root')
            call extend(in_groups, a:options.in.root)
        endif
        if has_key(a:options.in, 'sub')
            call extend(in_groups, map(copy(a:options.in.sub), '"'.a:block.'".v:val'))
        endif
    endif

    let begin = 'sql'
    if a:cluster == 1
        let begin = '@'.begin.'Cl'
    endif

    for group in in_groups
        execute 'syntax cluster sqlCl'.group.' add='.begin.a:block.a:entity
    endfor
endfunction
function Tool_addNextGroupsTo (block, entity, options)
    let next_groups = []
    if has_key(a:options, 'next')
        if has_key(a:options.next, 'common')
            if type(a:options.next.common) != type(0) || a:options.next.common != 0
                call add(next_groups, '@sqlCl'.a:block.'Content'.a:options.next.common.'Next')
            endif
        endif

        if has_key(a:options.next, 'group')
            if has_key(a:options.next.group, 'root')
                call extend(next_groups, map(copy(a:options.next.group.root), '"@sqlCl".v:val'))
            endif
            if has_key(a:options.next.group, 'sub')
                call extend(next_groups, map(copy(a:options.next.group.sub), '"@sqlCl'.a:block.'".v:val'))
            endif
        endif

        if has_key(a:options.next, 'element')
            if has_key(a:options.next.element, 'root')
                call extend(next_groups, map(copy(a:options.next.element.root), '"sql".v:val'))
            endif
            if has_key(a:options.next.element, 'sub')
                call extend(next_groups, map(copy(a:options.next.element.sub), '"sql'.a:block.'".v:val'))
            endif
        endif
    endif
    if !empty(next_groups)
        execute 'syntax cluster sqlCl'.a:block.a:entity.'Next add='.join(next_groups, ',')
    endif
endfunction
" }}}
" Entities: define {{{
    " NULL: {{{
function DefineEntity_Null (block, options)
    execute 'syntax keyword sql'.a:block.'Null nextgroup=@sqlCl'.a:block.'NullNext skipwhite skipempty contained display NULL'

    call Tool_addToContainerGroups(a:block, 'Null', a:options, 0)
    call Tool_addNextGroupsTo     (a:block, 'Null', a:options   )

    execute 'highlight default link sql'.a:block.'Null sqlNull'
endfunction
    " }}}
    " Number: {{{
function DefineEntity_Number (block, options)
    execute 'syntax match sql'.a:block.'Number nextgroup=@sqlCl'.a:block.'NumberNext skipwhite skipempty contained display /[+-]\?[0-9]\+\(\.[0-9]\+\)\?/'

    call Tool_addToContainerGroups(a:block, 'Number', a:options, 0)
    call Tool_addNextGroupsTo     (a:block, 'Number', a:options   )

    execute 'highlight default link sql'.a:block.'Number sqlNumber'
endfunction
    " }}}
    " String: {{{
function DefineEntity_String (block, options)
    execute 'syntax region sql'.a:block.'StringSingle nextgroup=@sqlCl'.a:block.'StringSingleNext skipwhite skipempty contained contains=@sqlCl'.a:block.'StringSingleContent matchgroup=sql'.a:block.'StringSingleDelimiter start=/''/ skip=/\\''/ end=/''/'
    execute 'syntax region sql'.a:block.'StringDouble nextgroup=@sqlCl'.a:block.'StringDoubleNext skipwhite skipempty contained contains=@sqlCl'.a:block.'StringDoubleContent matchgroup=sql'.a:block.'StringDoubleDelimiter start=/"/  skip=/\\"/  end=/"/ '

    execute 'syntax cluster sqlCl'.a:block.'StringSingleNext add=@sqlCl'.a:block.'StringNext'
    execute 'syntax cluster sqlCl'.a:block.'StringDoubleNext add=@sqlCl'.a:block.'StringNext'

    execute 'syntax cluster sqlCl'.a:block.'StringSingleContent add=@sqlCl'.a:block.'StringContent'
    execute 'syntax cluster sqlCl'.a:block.'StringDoubleContent add=@sqlCl'.a:block.'StringContent'

    execute 'syntax cluster sqlCl'.a:block.'String            add=sql'.a:block.'StringSingle,sql'.a:block.'StringDouble'
    
    call Tool_addToContainerGroups(a:block, 'String', a:options, 1)
    call Tool_addNextGroupsTo     (a:block, 'String', a:options   )

    execute 'highlight default link sql'.a:block.'StringSingleDelimiter sql'.a:block.'StringDelimiter'
    execute 'highlight default link sql'.a:block.'StringDoubleDelimiter sql'.a:block.'StringDelimiter'

    execute 'highlight default link sql'.a:block.'StringSingle sql'.a:block.'String'
    execute 'highlight default link sql'.a:block.'StringDouble sql'.a:block.'String'

    execute 'highlight default link sql'.a:block.'StringDelimiter sqlStringDelimiter'
    execute 'highlight default link sql'.a:block.'String          sqlString'
endfunction
    " }}}
    " Column: {{{
function DefineEntity_Column (block, options)
        " column {{{
	execute 'syntax region sql'.a:block.'ColumnEscaped nextgroup=@sqlCl'.a:block.'ColumnNext skipwhite skipempty contained display transparent oneline contains=sql'.a:block.'Column matchgroup=sql'.a:block.'ColumnDelimiter start=/`/ end=/`/'
	execute 'syntax match  sql'.a:block.'Column        nextgroup=@sqlCl'.a:block.'ColumnNext skipwhite skipempty contained /\h\w*/'

    execute 'syntax cluster sqlCl'.a:block.'Column     add=sql'.a:block.'ColumnEscaped,sql'.a:block.'Column'

    call Tool_addToContainerGroups(a:block, 'Column', a:options, 1)
    call Tool_addNextGroupsTo     (a:block, 'Column', a:options   )

    execute 'highlight default link sql'.a:block.'ColumnDelimiter sqlColumnDelimiter'
    execute 'highlight default link sql'.a:block.'Column          sqlColumn'
        " }}}
        " table. {{{
            " table {{{
    execute 'syntax region sql'.a:block.'ColumnTableEscaped nextgroup=sql'.a:block.'ColumnTableSeparator contained display transparent oneline contains=sql'.a:block.'ColumnTableSingle matchgroup=sql'.a:block.'ColumnTableDelimiter start=/`/ end=/`\(\.\)\@=/'
    execute 'syntax match  sql'.a:block.'ColumnTableSingle  nextgroup=sql'.a:block.'ColumnTableSeparator contained display /\h\w*/'
    execute 'syntax match  sql'.a:block.'ColumnTable        nextgroup=sql'.a:block.'ColumnTableSeparator contained display /\h\w*\(\.\)\@=/'

    execute 'syntax cluster sqlCl'.a:block.'ColumnTable     add=sql'.a:block.'ColumnTableEscaped,sql'.a:block.'ColumnTable'

    call Tool_addToContainerGroups(a:block, 'ColumnTable', a:options, 1)

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
" }}}

" ERROR: {{{
syntax match sqlError /\S.*/
" }}}

" SELECT: {{{
    " SELECT: {{{
syntax keyword sqlSelect nextgroup=@sqlClSelectContent skipwhite skipempty SELECT
    " }}}
    " __CONTENT__ {{{
        " __FIRST__ {{{
syntax cluster sqlClSelectContent add=@sqlClSelectContentFirst

            " DISTINCT: {{{
syntax keyword sqlSelectDistinct nextgroup=@sqlClSelectContentFirstNext skipwhite skipempty contained DISTINCT

syntax cluster sqlClSelectContentFirst add=sqlSelectDistinct

highlight default link sqlSelectDistinct sqlDistinct
            " }}}
        " }}}
        " __MID__ {{{        
syntax cluster sqlClSelectContent          add=@sqlClSelectContentMid
syntax cluster sqlClSelectContentFirstNext add=@sqlClSelectContentMid

            " Star: * {{{
syntax match sqlSelectStar nextgroup=@sqlClSelectContentMidNextSeparator skipwhite skipempty contained display /\*/

syntax cluster sqlClSelectContentMid add=sqlSelectStar

highlight default link sqlSelectStar sqlStar
            " }}}
            " Values: {{{
call DefineEntity_Null  ('Select', {'in':{'sub':['ContentMid']}, 'next':{'common':'Mid'}})
call DefineEntity_Number('Select', {'in':{'sub':['ContentMid']}, 'next':{'common':'Mid'}})
call DefineEntity_String('Select', {'in':{'sub':['ContentMid']}, 'next':{'common':'Mid'}})
call DefineEntity_Column('Select', {'in':{'sub':['ContentMid']}, 'next':{'common':'Mid'}})
            " }}}
        " }}}
    " }}}
" }}}

" Tools: {{{
delfunction Tool_addToContainerGroups
delfunction Tool_addNextGroupsTo
" }}}
" Entities: delete {{{
delfunction DefineEntity_Null
delfunction DefineEntity_Number
delfunction DefineEntity_String
delfunction DefineEntity_Column
" }}}

" COLORS: {{{
    " Internal: {{{
highlight default link sqlColumn               sqlName
highlight default link sqlColumnDelimiter      sqlDelimiter
highlight default link sqlColumnTable          sqlName
highlight default link sqlColumnTableDelimiter sqlDelimiter
highlight default link sqlColumnTableSeparator sqlOperator
highlight default link sqlDistinct             sqlStructureSecondary
highlight default link sqlSelect               sqlStructure
highlight default link sqlStar                 sqlOperator
highlight default link sqlStringDelimiter      sqlString
    " }}}
    " External: {{{
highlight default link sqlDelimiter			 Delimiter
highlight default link sqlError              Error
highlight default link sqlName               None
highlight default link sqlNull               Keyword
highlight default link sqlNumber             Number
highlight default link sqlOperator           Operator
highlight default link sqlString             String
highlight default link sqlStructure          Structure
highlight default link sqlStructureSecondary StorageClass
    " }}}
" }}}

let b:current_syntax = "sql"
