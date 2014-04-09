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

" Initialize options {{{1
function! s:DefineOption (name, value)
	if exists('g:php_'.a:name)
		return g:{'php_'.a:name}
	else
		return a:value
	endif
endfunction

	" Fold {{{2
let s:fold_root     = s:DefineOption('fold_root', 0)
let s:fold_comments = s:DefineOption('fold_comments', 1)

" }}}1

delfunction s:DefineOption

syntax case ignore

" ROOT: <?php ... ?> {{{1
if s:fold_root
	syntax region phpRoot fold contains=@phpClRoot,phpError matchgroup=phpBounds keepend extend start=/<?\(php\)\?/ end=/?>/
else
	syntax region phpRoot      contains=@phpClRoot,phpError matchgroup=phpBounds keepend extend start=/<?\(php\)\?/ end=/?>/
endif
" }}}1

" COMMENTS:	// ou /* ... */ {{{1
syntax match phpCommentOne contained extend #//.*#

if s:fold_comments
	syntax region phpCommentMulti fold contained containedin=ALL keepend extend start=#/*# end=#*/#
else
	syntax region phpCommentMulti      contained containedin=ALL keepend extend start=#/*# end=#*/#
endif
" }}}1

" NAMESPACE: namespace foo\bar {{{1
	" Definition {{{2
syntax keyword phpStructure contained nextgroup=phpNamespaceName,phpError skipwhite skipempty namespace

syntax match phpNamespaceName contained nextgroup=phpEndInstruction,phpError skipwhite skipempty /\(\\\|\h\w*\)*\h\w*/
" }}}1

" ENDS: {{{1
	" END OF INSTRUCTION: {{{2
syntax match phpEndInstruction contained nextgroup=@phpClComments skipwhite /;/

	" ERROR: {{{2
syntax match phpError contained /.+/
" }}}1

