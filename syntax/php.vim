" Vim syntax file for PHP
" Language:	PHP 4 / 5
" Maintainer:	Julien Rosset <jul.rosset@gmail.com>
"
" URL:
" Version:	0.0.1

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

syntax case ignore

" ROOT: <?php ... ?> {{{
if s:fold_root
	syntax region phpRoot fold contains=@phpClRoot,phpError matchgroup=phpBounds keepend extend start=/<?\(php\)\?/ end=/?>/
else
	syntax region phpRoot      contains=@phpClRoot,phpError matchgroup=phpBounds keepend extend start=/<?\(php\)\?/ end=/?>/
endif
" }}}

" COMMENTS:	// ou /* ... */ {{{
syntax match phpCommentOne contained extend #//.*#

if s:fold_comments
	syntax region phpCommentMulti fold contained containedin=ALL keepend extend start=#/\*# end=#\*/#
else
	syntax region phpCommentMulti      contained containedin=ALL keepend extend start=#/\*# end=#\*/#
endif

syntax cluster phpClComment contains=phpCommentOne,phpCommentMulti
syntax cluster phpClRoot add=@phpClComment
" }}}

" NAMESPACE: namespace foo\bar {{{
	" Definition {{{
syntax keyword phpStructure contained nextgroup=phpNamespaceName skipwhite skipempty namespace
syntax match phpNamespaceName contained nextgroup=phpSemicolon skipwhite skipempty /\(\\\|\h\w*\)*\h\w*/

syntax cluster phpClRoot add=phpStructure,phpNamespaceName
	" }}}
" }}}

" ENDS: {{{
	" END OF INSTRUCTION: {{{
syntax match phpSemicolon contained nextgroup=@phpClComments skipwhite /;/
	" }}}
	" ERROR: {{{
syntax match phpError contained /.\+$/
	" }}}
" }}}


" COLORS {{{
highlight link phpBounds		Debug
highlight link phpError			Error
highlight link phpSemicolon		Operator

highlight link phpCommentOne	phpComment
highlight link phpCommentMulti	phpComment
highlight link phpComment		Comment

highlight link phpStructure		Structure
highlight link phpNamespaceName	Normal
" }}}

