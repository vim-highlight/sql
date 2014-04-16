" Vim syntax file for PHP
" Language:		PHP 4 / 5
" Maintainer:	Julien Rosset <jul.rosset@gmail.com>
"
" URL:			https://github.com/darkelfe/vim-php
" Version:		0.0.1

if version < 600 || exists("b:current_syntax")
	finish
endif

runtime! syntax/html.vim
unlet b:current_syntax

" Initialize options {{{
function! s:DefineOption (name, value)
	if exists('b:php_'.a:name)
		return b:{'php_'.a:name}
	elseif exists('g:php_'.a:name)
		return g:{'php_'.a:name}
	else
		return a:value
	endif
endfunction

	" Fold {{{
let s:fold_root     = s:DefineOption('fold_root', 0)
let s:fold_comments = s:DefineOption('fold_comments', 1)
let s:fold_classes = s:DefineOption('fold_classes', 1)
	" }}}

delfunction s:DefineOption
" }}}

syntax case match

runtime! syntax/php_contents.vim

" ROOT: <?php ... ?> {{{
if s:fold_root
	syntax region phpRoot fold contains=@phpClRoot,phpError matchgroup=phpBounds keepend extend start=/<?\(php\)\?/ end=/?>/
else
	syntax region phpRoot      contains=@phpClRoot,phpError matchgroup=phpBounds keepend extend start=/<?\(php\)\?/ end=/?>/
endif
" }}}

" ERROR: {{{
syntax match phpError contained /\S.*$/
" }}}

" COMMENTS:	// ou /* ... */ {{{
syntax match phpComment contained #//.*$#

if s:fold_comments
	syntax region phpComment fold contained keepend extend start=#/\*# end=#\*/#
else
	syntax region phpComment      contained keepend extend start=#/\*# end=#\*/#
endif

syntax cluster phpClRoot add=phpComment

function! s:DefineCustomComment (name, next)
	execute 'syntax match '.a:name.' contained nextgroup='.a:next.' skipwhite skipempty #//.*$#'

	if s:fold_comments
		execute 'syntax region '.a:name.' fold contained nextgroup='.a:next.' skipwhite skipempty contained keepend extend start=#/\*# end=#\*/#'
	else
		execute 'syntax region '.a:name.'      contained nextgroup='.a:next.' skipwhite skipempty contained keepend extend start=#/\*# end=#\*/#'
	endif
	
	execute 'highlight link '.a:name.' phpComment'
endfunction
" }}}

" ENDS: {{{
	" END OF INSTRUCTION: {{{
call s:DefineCustomComment('phpSemicolonComment', 'phpSemicolon')

syntax match phpSemicolon contained nextgroup=phpComments skipwhite /;/
highlight link phpSemicolon phpOperator

syntax cluster phpClSemicolon contains=phpSemicolonComment,phpSemicolon
	" }}}
" }}}

" NAMESPACE: namespace foo\bar {{{
	" {{{
syntax keyword phpNamespace contained nextgroup=phpNamespaceName,phpNamespaceComment skipwhite skipempty namespace
syntax match phpNamespaceName contained nextgroup=@phpClSemicolon skipwhite skipempty /\(\\\|\h\w*\)*\h\w*/

call s:DefineCustomComment('phpNamespaceComment', 'phpNamespaceName')

syntax cluster phpClRoot add=phpNamespace
highlight link phpNamespace phpStructure
	" }}}

	" USE: {{{
syntax keyword phpNamespaceUse contained nextgroup=phpNamespaceUseName,phpNamespaceUseComment skipwhite skipempty use
syntax match phpNamespaceUseName contained contains=@phpClExtensionClasses nextgroup=@phpClNamespaceUse skipwhite skipempty /\(\\\|\h\w*\)*\h\w*/
" TODO phpNamespaceUseName match @phpClExtensionClasses only as root class

		" use Foo\Bar {{{
syntax cluster phpClNamespaceUse contains=@phpClSemicolon
		" }}}
		" use Foo\Bar as FooBar {{{
syntax keyword phpNamespaceUseAs contained nextgroup=phpNamespaceUseAsName,phpNamespaceUseAsComment skipwhite skipempty as
syntax match phpNamespaceUseAsName contained nextgroup=@phpClNamespaceUse skipwhite skipempty /\h\w*/

syntax cluster phpClNamespaceUse add=phpNamespaceUseAs
highlight link phpNamespaceUseAs phpStructure
		" }}}
		" use Foo\Bar, ... {{{
syntax match phpNamespaceUseComma contained nextgroup=phpNamespaceUseName,phpNamespaceUseCommaComment skipwhite skipempty /,/

syntax cluster phpClNamespaceUse add=phpNamespaceUseComma
highlight link phpNamespaceUseComma phpOperator
		" }}}

syntax cluster phpClNamespaceUse add=phpNamespaceUseNameComment

call s:DefineCustomComment('phpNamespaceUseComment', 		'phpNamespaceUseName')
call s:DefineCustomComment('phpNamespaceUseNameComment', 	'@phpClNamespaceUse')
call s:DefineCustomComment('phpNamespaceUseAsComment', 		'phpNamespaceUseAsName')
call s:DefineCustomComment('phpNamespaceUseCommaComment', 	'phpNamespaceUseName')

syntax cluster phpClRoot add=phpNamespaceUse
highlight link phpNamespaceUse phpStructure
	" }}}
" }}}

" CLASS: {{{
	" [abstract] class myFoo {{{
syntax keyword phpClassAbstract contained nextgroup=phpClass,phpClassAbstractComment skipwhite skipempty abstract
syntax keyword phpClass contained nextgroup=phpClassName,phpClassComment skipwhite skipempty class

syntax match phpClassName contained nextgroup=@phpClClass skipwhite skipempty /\h\w*/

highlight link phpClass			phpStructure
highlight link phpClassAbstract	phpStructure

syntax cluster phpClRoot add=phpClass,phpClassAbstract
	" }}}
	" extends Foo\Bar {{{
syntax keyword phpClassExtends contained nextgroup=phpClassExtendsName,phpClassExtendsName skipwhite skipempty extends
syntax match phpClassExtendsName contained contains=@phpClExtensionClasses nextgroup=@phpClClassExtends skipwhite skipempty /\(\\\|\h\w*\)*\h\w*/

highlight link phpClassExtends	phpStructure

syntax cluster phpClClass add=phpClassExtends
	" }}}
	" implements \Foo\Bar {{{
		" implements + <class name>
syntax keyword phpClassImplements contained nextgroup=phpClassImplementsName,phpClassImplementsComment skipwhite skipempty implements
syntax match phpClassImplementsName contained contains=@phpClExtensionClasses nextgroup=@phpClClassImplements skipwhite skipempty /\(\\\|\h\w*\)*\h\w*/

highlight link phpClassImplements	phpStructure

syntax cluster phpClClass	add=phpClassImplements
syntax cluster phpClExtends	add=phpClassImplements

		" , XXX if present
syntax match phpClassImplementsComma contained nextgroup=phpClassImplementsName,phpClassImplementsCommaComment skipwhite skipempty /,/

highlight link phpNamespaceUseComma phpOperator

syntax cluster phpClClassImplements add=phpClassImplementsComma
	" }}}
	" <class block> {{{
if s:fold_classes
	syntax region phpClassBlock fold contains=@phpClClassContent matchgroup=phpClassBlockBounds start=/{/ end=/}/
else
	syntax region phpClassBlock      contains=@phpClClassContent matchgroup=phpClassBlockBounds start=/{/ end=/}/
endif

highlight link phpClassBlockBounds	phpOperator

syntax cluster phpClClass		add=phpClassBlock
syntax cluster phpClClassExtends	add=phpClassBlock
syntax cluster phpClClassImplements	add=phpClassBlock
	" }}}

syntax cluster phpClClass		add=phpClassNameComment
syntax cluster phpClClassExtends	add=phpClassExtendsNameComment
syntax cluster phpClClassImplements	add=phpClassImplementsNameComment

call s:DefineCustomComment('phpClassAbstractComment',		'phpClass')
call s:DefineCustomComment('phpClassComment',			'phpClassName')
call s:DefineCustomComment('phpClassNameComment',		'@phpClClass')
call s:DefineCustomComment('phpClassExtendsComment',		'phpClassExtendsName')
call s:DefineCustomComment('phpClassExtendsNameComment',	'@phpClClassExtends')
call s:DefineCustomComment('phpClassImplementsComment',		'phpClassImplementsName')
call s:DefineCustomComment('phpClassImplementsNameComment',	'@phpClClassImplements')
call s:DefineCustomComment('phpClassImplementsCommaComment',	'phpClassImplementsName')
" }}}


" COLORS {{{
highlight link phpBounds		Debug
highlight link phpError			Error
highlight link phpOperator		Operator

highlight link phpComment		Comment

highlight link phpStructure		Structure

highlight link phpExtensionConstants	Constant
highlight link phpExtensionFunctions	Function
highlight link phpExtensionClasses		Function
" }}}

