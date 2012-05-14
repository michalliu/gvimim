" Maintainer: yf liu <sophia.smth@gmail.com>
" Requires: jsruntime http://www.vim.org/scripts/script.php?script_id=4050
"           jsoncodecs http://www.vim.org/scripts/script.php?script_id=4056
" Description: javascript lint tool on the fly
" Version: 1.0
"
if exists("b:did_jsflakes_plugin")
    finish
endif

" fail silently
if exists("g:disabled_jsflakes_plugin") && g:disabled_jsflakes_plugin 
    finish
endif

let b:did_jsflakes_plugin = 1

if !exists("g:loaded_jsruntime")
    echoerr('jsruntime.vim is required, plz visit http://www.vim.org/scripts/script.php?script_id=4050')
    finish
endif

if !g:loaded_jsruntime
    echoerr("jsflakes disabled automaticly, because jsruntime.vim report not working properly")
    " set a flag to disable jsfalkes
    let g:disabled_jsflakes_plugin = 1
    finish
endif

if !exists("g:loaded_jsoncodecs")
    echoerr('jsoncodecs.vim is required, plz visit http://www.vim.org/scripts/script.php?script_id=4056')
    finish
endif

if &ft == 'html'
    if has('python')
    python << EOF
import vim
from HTMLParser import HTMLParser

class htmlParser(HTMLParser):

    def __init__(self):
        HTMLParser.__init__(self)
        self.scriptBlocks=[]

    def handle_starttag(self, tag, attrs):
        if (tag=="script"):
            self.scriptBlocks.append(self.getpos()[0])

    def handle_endtag(self, tag):
        if (tag=="script"):
            self.scriptBlocks.append(self.getpos()[0])

    def handle_data(self, data):
        pass

    @property
    def lintableScripts(self):
        # throw the last one if script tag not pairs
        if (len(self.scriptBlocks) % 2 != 0):
            self.scriptBlocks = self.scriptBlocks[0:-1]
        #
        i = 0
        count = len(self.scriptBlocks)
        if (count % 2 == 0):
            return [self.scriptBlocks[i:i+2] for i in range(0, count, 2) if self.scriptBlocks[i] != self.scriptBlocks[i+1]]
        return None

EOF
    else
        echoerr('jsflakes requires Vim must be compiled with Python to parse html')
        finish
    endif
endif

let s:install_dir = expand("<sfile>:p:h")
let s:jshint_context = join(readfile(s:install_dir.'/jshint.js'), "\n")
let s:jshint_run = join(readfile(s:install_dir.'/jshint_run.js'), "\n")

" a flag to know is jshint message is shown
let b:showing_message = 0

" load option file for jshint
if !exists("g:jshint_rcfile")
    let s:rc_file = expand('~/.jshintrc')
else
    let s:rc_file = g:jshint_rcfile
endif

if filereadable(s:rc_file)
  let s:jshintrc = readfile(s:rc_file)
else
  let s:jshintrc = []
end

if &ft == 'html'
    au BufEnter <buffer> call s:htmlJSHint()
    au InsertLeave <buffer> call s:htmlJSHint()
    au BufWritePost <buffer> call s:htmlJSHint()
    au CursorMoved <buffer> call s:GetJSHintMessage()
else
    " execute jshint when certain event happens
    au BufEnter <buffer> call s:JSHint(1)
    au InsertLeave <buffer> call s:JSHint(1)
    au BufWritePost <buffer> call s:JSHint(1)
    au CursorMoved <buffer> call s:GetJSHintMessage()
endif

" call jshint while content modified
noremap <buffer><silent> dd dd:JSHintUpdate<CR>
noremap <buffer><silent> dw dw:JSHintUpdate<CR>
noremap <buffer><silent> u u:JSHintUpdate<CR>
noremap <buffer><silent> <C-R> <C-R>:JSHintUpdate<CR>

" map a command to run jshint
if !exists(":JSHintUpdate")
    command JSHintUpdate :call s:JSHintUpdate()
endif

" jshint clear
if !exists('*s:JSHintClear')
    function s:JSHintClear()
      " Delete previous matches
      let s:matches = getmatches()
      for s:matchId in s:matches
        if s:matchId['group'] == 'JSHintError'
            call matchdelete(s:matchId['id'])
        endif
      endfor
      let s:matchedlines = {}
	  call setqflist([])
    endfunction
endif

" jshint
if !exists('*s:JSHint')
    function s:JSHint(clear,...)

        highlight link JSHintError SpellBad

        if !exists('s:did_jshint_context')
            if g:jsruntime_support_living_context
                call b:jsruntimeEvalScript(s:jshint_context,0)
                let s:did_jshint_context = 1
            else
                let s:did_jshint_context = 0
            endif
        endif

        " jshint context created
        if s:did_jshint_context
            let js = ""
        else
            let js = s:jshint_context
        endif

        if a:clear
             silent call s:JSHintClear()
        endif

        " Detect line range
        if !exists("a:1")
            let startline=1
        else 
            let startline=a:1
        endif

        if !exists("a:2")
            let endline='$'
        else 
            let endline=a:2
        endif


		" Store quickfix list
		let qf_list = []

		let lintscript = s:jshintrc + getline(startline, endline)
		let js = js . printf(s:jshint_run,b:json_dump_string(lintscript))

        " printout scripts to be eval for debug
        " echo js
		" call writefile([js],'debug.txt','b')
        let jshint_output = b:jsruntimeEvalScript(js)
        for error in split(jshint_output, "\n")
            " Match {line}:{char}:{message}
            let parts = matchlist(error, '\v(\d+):(\d+):([A-Z]+):(.*)')
            if !empty(parts)
                let line = parts[1] + (startline - 1 - len(s:jshintrc)) " Get line relative to selection
				let errorMessage = parts[4]

				if line < 1
					echoerr 'jsflakes found error in your jshintrc <' . s:rc_file .'>, line ' . parts[1] . ', character ' . parts[2] . (errorMessage == '' ? '' : ': ' . errorMessage) . ' plz visit http://www.jshint.com/options/ for more info'
				else
                    " Store the error for an error under the cursor
                    let matchDict = {}
                    let matchDict['lineNum'] = line
                    let matchDict['message'] = errorMessage
                    if !exists('s:matchedlines')
                        let s:matchedlines = {}
                    endif
                    let s:matchedlines[line] = matchDict
					if parts[3] == 'ERROR'
					    let errorType = 'E'
					else
						let errorType = 'W'
					endif
                    call matchadd('JSHintError', '\%' . line . 'l\S.*\(\S\|$\)')

			    	" Store the error for quickfix window
			    	let qf = {}
			    	let qf.bufnr = bufnr('%')
			    	let qf.filename = expand('%')
			    	let qf.lnum = line
			    	let qf.text = errorMessage
			    	let qf.type = errorType

					" Add line to quickfix list
					call add(qf_list, qf)
				endif
            endif
        endfor
		call setqflist(qf_list, 'a')
    endfunction
endif

" run jshint in html file
if !exists("*s:htmlJSHint")
    function s:htmlJSHint()
        silent call s:JSHintClear()
    python << EOF
import vim
parser = htmlParser()
parser.feed(vim.eval("join(getline(1,'$'),'\n')"))
# start <script> end </script>
if parser.lintableScripts:
    for start,end in parser.lintableScripts:
        vim.command('call s:JSHint(0,%d,%d)' % (start+1,end-1))
EOF
    endfunction
endif

" get hint message
if !exists("*s:GetJSHintMessage")
    function s:GetJSHintMessage()
        let cursorPos = getpos(".")

        " Bail if RunJSHint hasn't been called yet
        if !exists('s:matchedlines')
            return
        endif

        if has_key(s:matchedlines, cursorPos[1])
            let jshintMatch = get(s:matchedlines, cursorPos[1])
            call s:WideMsg(jshintMatch['message'])
            let b:showing_message = 1
            return
        endif

        if b:showing_message == 1
            echo
            let b:showing_message = 0
        endif
    endfunction
endif

" WideMsg() prints [long] message up to (&columns-1) length
" guaranteed without "Press Enter" prompt.
if !exists("*s:WideMsg")
    function s:WideMsg(msg)
        let x=&ruler | let y=&showcmd
        set noruler noshowcmd
        redraw
        echo a:msg
        let &ruler=x | let &showcmd=y
    endfun
endif

" updateNow
if !exists("*s:JSHintUpdate")
    function s:JSHintUpdate()
        if &ft == 'html'
            silent call s:JSHintClear() "clear previous
            silent call s:htmlJSHint() " lintnow w/o clear
        else
            silent call s:JSHint(1) " clear and lint
        endif
        call s:GetJSHintMessage() " show messages
    endfunction
endif

" ADD ABILITY TO RUN JAVASCRIPT INSIDE VIM
" run js inside vim
if !exists("*s:RunJavascript")
	function s:RunJavascript(startline,...)
        " Detect range
        if a:startline < 1
            let startline=1
        else 
            let startline=a:startline
        endif
        if !exists("a:1")
            let endline='$'
        else 
            let endline=a:1
        endif
		call b:jsruntimeEvalScript(join(getline(startline, endline),"\n"))
	endfunction
endif

" addCommand to RunJS
if !exists(":RunJS")
    command RunJS :call s:RunJavascript(1)
endif

if !exists(":RunJSBlock")
    command -nargs=? RunJSBlock :call s:RunJavascript(<args>)
endif

" run html inside vim
" RunBrowser depend jsruntimeEvalScriptInBrowserContext 
if exists("*b:jsruntimeEvalScriptInBrowserContext") && &ft == 'html'

	if !exists("*s:RunJavascriptInBrowserContext")
		function s:RunJavascriptInBrowserContext(startline,...)
            " Detect range
            if a:startline < 1
                let startline=1
            else 
                let startline=a:startline
            endif
            if !exists("a:1")
                let endline='$'
            else 
                let endline=a:1
            endif
			call b:jsruntimeEvalScriptInBrowserContext(join(getline(startline, endline),"\n"))
		endfunction
	endif

    if !exists(":RunHtml")
        command RunHtml :call s:RunJavascriptInBrowserContext(1)
    endif
    
    " addCommand to MixedHTMLAndJs
    if !exists(":RunHtmlBlock")
        command -nargs=? RunHtmlBlock :call s:RunJavascriptInBrowserContext(<args>)
    endif

endif
