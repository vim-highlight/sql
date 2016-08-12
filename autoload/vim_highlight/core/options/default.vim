if exists("g:autoload_vim_highlight_core_options_default")
    finish
endif
let g:autoload_vim_highlight_core_options_default = 1

" common : default common options {{{
let g:vim_highlight#core#options#default#common = { 'contained': 0, 'containedin': [], 'nextgroup': [], 'transparent': 0, 'skipempty': 0, 'skipnl': 0, 'skipwhite': 0 }
" }}}
" keyword : default keyword options {{{
let vim_highlight#core#options#default#keyword = {}
" }}}
" match : default match options {{{
let g:vim_highlight#core#options#default#match = { 'contains': [], 'fold': 0, 'display': 0, 'extend': 0, 'excludenl': 0 }
" }}}
" region : default region options {{{
let vim_highlight#core#options#default#region = { 'contains': [], 'oneline': 0, 'fold': 0, 'display': 0, 'extend': 0, 'matchgroup': [], 'keepend': 0, 'excludenl': 0 }
" }}}
