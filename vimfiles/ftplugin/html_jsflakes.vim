" Helper function for (x)html snippets
if exists('s:did_html_jsflakes')
	finish
endif
let s:did_html_jsflakes = 1

" Automatically activate jsflakes if in xhtml
runtime! ftplugin/javascript/*.vim
