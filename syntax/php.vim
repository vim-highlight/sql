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
	" }}}

" }}}

delfunction s:DefineOption

syntax case match

runtime! syntax/php_contents.vim

" ROOT: <?php ... ?> {{{
if s:fold_root
	syntax region phpRoot fold contains=@phpClRoot,phpError matchgroup=phpBounds keepend extend start=/<?\(php\)\?/ end=/?>/
else
	syntax region phpRoot      contains=@phpClRoot,phpError matchgroup=phpBounds keepend extend start=/<?\(php\)\?/ end=/?>/
endif
" }}}

" COMMENTS:	// ou /* ... */ {{{
syntax match phpComment contained extend #//.*#

if s:fold_comments
	syntax region phpComment fold contained containedin=ALL keepend extend start=#/\*# end=#\*/#
else
	syntax region phpComment      contained containedin=ALL keepend extend start=#/\*# end=#\*/#
endif

syntax cluster phpClRoot add=phpComment
" }}}

" NAMESPACE: namespace foo\bar {{{
	" {{{
syntax keyword phpNamespace contained nextgroup=phpNamespaceName skipwhite skipempty namespace
syntax match phpNamespaceName contained nextgroup=phpSemicolon skipwhite skipempty /\(\\\|\h\w*\)*\h\w*/

syntax cluster phpClRoot add=phpNamespace
highlight link phpNamespace phpStructure
	" }}}

	" USE: {{{
syntax keyword phpNamespaceUse contained nextgroup=phpNamespaceUseName skipwhite skipempty use
syntax match phpNamespaceUseName contained contains=@phpClExtensionClasses nextgroup=@phpClNamespaceUse skipwhite skipempty /\(\\\|\h\w*\)*\h\w*/
" TODO phpNamespaceUseName match @phpClExtensionClasses only as root class

		" use Foo\Bar {{{
syntax cluster phpClNamespaceUse contains=phpSemicolon
		" }}}
		" use Foo\Bar as FooBar {{{
syntax keyword phpNamespaceUseAs contained nextgroup=phpNamespaceUseAsName skipwhite skipempty as
syntax match phpNamespaceUseAsName contained nextgroup=@phpClNamespaceUse skipwhite skipempty /\h\w*/

syntax cluster phpClNamespaceUse add=phpNamespaceUseAs
highlight link phpNamespaceUseAs phpStructure
		" }}}
		" use Foo\Bar, ... {{{
syntax match phpNamespaceUseComma contained nextgroup=phpNamespaceUseName skipwhite skipempty /,/

syntax cluster phpClNamespaceUse add=phpNamespaceUseComma
highlight link phpNamespaceUseComma phpOperator
		" }}}

syntax cluster phpClRoot add=phpNamespaceUse
highlight link phpNamespaceUse phpStructure
	" }}}
" }}}

" ENDS: {{{
	" END OF INSTRUCTION: {{{
syntax match phpSemicolon contained nextgroup=phpComments skipwhite /;/

highlight link phpSemicolon phpOperator
	" }}}
	" ERROR: {{{
syntax match phpError contained /.\+$/
	" }}}
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

