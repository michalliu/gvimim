"======================================================================
" cream-showinvisibles.vim
" 
" Cream -- An easy-to-use configuration of the famous Vim text editor
" [ http://cream.sourceforge.net ] Copyright (C) 2002-2004  Steve Hall
"
" License:
"
" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation; either version 2 of  the  License,  or
" (at your option) any later version.
" [ http://www.gnu.org/licenses/gpl.html ]
"
" This program is distributed in the hope that it will be useful,  but
" WITHOUT  ANY  WARRANTY;  without  even  the  implied   warranty   of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR  PURPOSE.  See  the  GNU
" General Public License for more details.
"
" You should have received a copy of the GNU  General  Public  License
" along with  this  program;  if  not,  write  to  the  Free  Software
" Foundation,  Inc.,  59  Temple  Place  -  Suite  330,   Boston,   MA
" 02111-1307, USA.
"
" Description:
"
" Toggle view of invisible characters such as tabs, trailing spaces
" and hard returns. The script includes intuitive presets for these
" characters, a global environmental variable (g:LIST) that is
" retained and initialized across sessions if you use a viminfo, and a
" familiar (to some of us) keyboard shortcut mapping to F6.
"
" This configuration includes characters as beautiful as your specific
" setup will allow, determined by hardware, operating system and Vim
" version. (Vim version 6.1.469 supports multi-byte characters, used
" with UTF-8 encoding.)
"
" This is one of the many custom utilities and functions for gVim from
" the Cream project (http://cream.sourceforge.net), a configuration of
" Vim for those of us familiar with Apple and Windows software. 
"
" Updated: 2004 March 20
" Version: 3.01
" Source:  http://vim.sourceforge.net/scripts/script.php?script_id=363
" Author:  Steve Hall  [ digitect@mindspring.com ]
" License: GPL (http://www.gnu.org/licenses/gpl.html)
"
" Instructions:
"
" o Simply copy this file and paste it into your vimrc. Or you can
"   drop the entire file into your plugins directory.
" o As long as you don't already have keyboard mappings to the F6 key,
"   it will toggle invisible characters.
"
" Notes:
"
" For more information see Vim's ":help 'list", ":help 'listchars",
" and ":help viminfo".
"
" ChangeLog:
"
" 2004-03-20 -- v.3.01
" o Fixed typos in trail multi-byte test and extends definitions.
"
" 2004-03-20 -- v.3.0
" o We no longer guess at encodings. Instead we choose characters on
"   the basis of whether they are printable or not.
"
" 2003-12-13 -- v.2.1
" o Repair of utf-8 chars for Vim versions >= 6.2.
" o Addition of mappings and autocmd for use outside of Cream.
" o Renamed functions:
"   * List_init()             =>  Cream_list_init()
"   * List_toggle()           =>  Cream_list_toggle()
"
" 2003-04-17 -- v.2.0
" o New multi-byte sets, contingent upon Vim version 6.1.469+. Note
"   that your particular OS and Font capabilities impact the display
"   of multi-byte characters, your usage may vary.
" o Abstracted multi-byte characters to decimal values so the current
"   editing session doesn't affect them.
"
" 2002-10-06 -- v.1.2
" o Modified state variable types from string to numbers
" o Extracted autocommand and mappings for the sake of the project. ;)
"
" 2002-08-03 -- v.1.1
" o New normal mode mapping and slightly saner visual and insert mode
"   mappings.
"
" 2002-08-03 -- v.1.0
" o Initial Release
"

" don't load mappings or autocmd if used with Cream (elsewhere)
if !exists("$CREAM")

	" mappings
	imap <silent> <F6> <C-o>:call Cream_list_toggle("i")<CR>
	vmap <silent> <F6> :<C-u>call Cream_list_toggle("v")<CR>
	nmap <silent> <F6>      :call Cream_list_toggle("n")<CR>

	" initialize on Buffer enter/new
	autocmd BufNewFile,BufEnter * call Cream_list_init()

endif


" initialize characters used to represent invisibles (global)
function! Cream_listchars_init()
" Sets &listchars to sophisticated extended characters as possible.
" Gracefully falls back to 7-bit ASCII per character if one is not
" printable.
"
" WARNING:
" Do not try to enter multi-byte characters below, use decimal
" abstractions only! It's the only way to guarantee that all encodings
" can edit this file.

	set listchars=

	" tab
	if     strlen(substitute(strtrans(nr2char(187)), ".", "x", "g")) == 1
		" right angle quote, guillemotright followed by space (digraph >>)
		execute "set listchars+=tab:" . nr2char(187) . '\ '
	else
		" greaterthan, followed by space
		execute "set listchars+=tab:" . nr2char(62) . '\ '
	endif
		
	" eol
	if     strlen(substitute(strtrans(nr2char(182)), ".", "x", "g")) == 1
		" paragrah symbol (digraph PI)
		execute "set listchars+=eol:" . nr2char(182)
	else
		" dollar sign
		execute "set listchars+=eol:" . nr2char(36)
	endif

	" trail space
	if     strlen(substitute(strtrans(nr2char(183)), ".", "x", "g")) == 1
		" others digraphs: 0U 0M/M0 sB .M 0m/m0 RO
		" middle dot (digraph .M)
		execute "set listchars+=trail:" . nr2char(183)
	else
		" period
		execute "set listchars+=trail:" . nr2char(46)
	endif

	" space
	if     strlen(substitute(strtrans(nr2char(183)), ".", "x", "g")) == 1
		" others digraphs: 0U 0M/M0 sB .M 0m/m0 RO
		" middle dot (digraph .M)
		execute "set listchars+=space:" . nr2char(183)
	else
		" period
		execute "set listchars+=space:" . nr2char(46)
	endif

	" precedes
	if     strlen(substitute(strtrans(nr2char(133)), ".", "x", "g")) == 1
		" ellipses
		execute "set listchars+=precedes:" . nr2char(133)
	elseif strlen(substitute(strtrans(nr2char(8249)), ".", "x", "g")) == 1
		" mathematical lessthan (digraph <1)
		execute "set listchars+=precedes:" . nr2char(8249)
	elseif strlen(substitute(strtrans(nr2char(8592)), ".", "x", "g")) == 1
		" left arrow  (digraph <-)
		execute "set listchars+=precedes:" . nr2char(8592)
	else
		" underscore
		execute "set listchars+=precedes:" . nr2char(95)
	endif

	" extends
	if     strlen(substitute(strtrans(nr2char(133)), ".", "x", "g")) == 1
		" ellipses
		execute "set listchars+=extends:" . nr2char(133)
	elseif strlen(substitute(strtrans(nr2char(8250)), ".", "x", "g")) == 1
		" mathematical greaterthan (digraph >1)
		execute "set listchars+=extends:" . nr2char(8250)
	elseif strlen(substitute(strtrans(nr2char(8594)), ".", "x", "g")) == 1
		" right arrow (digraph ->)
		execute "set listchars+=extends:" . nr2char(8594)
	else
		" underscore
		execute "set listchars+=extends:" . nr2char(95)
	endif


	"if &encoding == "latin1"
	"    " decimal 187 followed by a space (032)
	"    execute "set listchars+=tab:" . nr2char(187) . '\ '
	"    " decimal 182
	"    execute "set listchars+=eol:" . nr2char(182)
	"    " decimal 183
	"    execute "set listchars+=trail:" . nr2char(183)
	"    " decimal 133 (ellipses Â)
	"    execute "set listchars+=precedes:" . nr2char(133)
	"    execute "set listchars+=extends:" . nr2char(133)
	"
	"" patch 6.1.469 fixes list with multi-byte chars! (2003-04-16)
	"elseif &encoding == "utf-8" && v:version >=602
	"\|| &encoding == "utf-8" && v:version == 601 && has("patch469")
	"    " decimal 187 followed by a space (032)
	"    execute "set listchars+=tab:" . nr2char(187) . '\ '
	"    " decimal 182
	"    execute "set listchars+=eol:" . nr2char(182)
	"    " decimal 9642 (digraph sB âª )
	"    " decimal 9675 (digraph m0 â )
	"    " decimal 9679 (digraph M0 â )
	"    " decimal 183
	"    execute "set listchars+=trail:" . nr2char(183)
	"    " decimal 8222 (digraph :9 â )
	"    " decimal 8249 (digraph <1 â¹ )
	"    execute "set listchars+=precedes:" . nr2char(8249)
	"    " decimal 8250 (digraph >1 âº )
	"    execute "set listchars+=extends:" . nr2char(8250)
	"
	"else
	"    set listchars+=tab:>\ 		" decimal 62 followed by a space (032)
	"    set listchars+=eol:$		" decimal 36
	"    set listchars+=trail:.		" decimal 46
	"    set listchars+=precedes:_	" decimal 95
	"    set listchars+=extends:_	" decimal 95
	"endif

endfunction
call Cream_listchars_init()

function! Cream_list_gray()
	hi NonText guifg=gray
	hi SpecialKey guifg=gray
endfunction

function! Cream_list_restore()
	:exe "hi NonText guifg=".s:initialNonTextFG
	:exe "hi NonText guifg=".s:initialSpecialKeyFG
endfunction

" initialize environment on BufEnter (local)
function! Cream_list_init()
	if !exists("s:initialNonTextFG")
		let s:initialNonTextFG = synIDattr(hlID("NonText"),"fg")
	endif
	if !exists("s:initialSpecialKeyFG")
		let s:initialSpecialKeyFG = synIDattr(hlID("SpecialKey"),"fg")
	endif
	if !exists("g:LIST")
		" initially off
		set nolist
		let g:LIST = 0
	else
		if g:LIST == 1
			set list
			call Cream_list_gray()
		else
			set nolist
		endif
	endif
endfunction

" toggle on/off
function! Cream_list_toggle(mode)
	if exists("g:LIST")
		if g:LIST == 0
			set list
			call Cream_list_gray()
			let g:LIST = 1
		elseif g:LIST == 1
			set nolist
			call Cream_list_restore()
			let g:LIST = 0
		endif
	else
		call confirm(
		\"Error: global uninitialized in Cream_list_toggle()", "&Ok", 1, "Error")
	endif
	if a:mode == "v"
		normal gv
	endif
endfunction

"---------------------------------------------------------------------
" Note: we put this here so our beautiful little character
" representations aren't affected by encoding changes. ;)
"
" vim:fileencoding=utf-8
