" Maintainer: michal liu <sophia.smth@gmail.com>
" Description: javascript lint tool on the fly
"
"              Global Options
"             
"              Enable/Disable highlighting of errors in source.
"              Default is Enable
"              To disable the highlighting put the line
"              let g:JSHintHighlightErrorLine = 0
"              in your .vimrc
" Version: 1.0
"
if exists("b:did_jshint_plugin")
    finish
else
    let b:did_jshint_plugin = 1
endif

let s:install_dir = expand("<sfile>:p:h")

" this script aslo works on html
" it just lint those text wraped by <script> tag
" we use python parse html and ignore scripts in one line
if &ft == 'html'
    if has('python')
    python << EOF
import vim
from HTMLParser import HTMLParser

# create a subclass and override the handler methods
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
        count = len(self.scriptBlocks)
        # requires scripts must be paried otherwise we dont lint it
        i = 0
        if (count % 2 == 0):
            return [self.scriptBlocks[i:i+2] for i in range(0, count, 2) if self.scriptBlocks[i] != self.scriptBlocks[i+1]]
        return None

EOF
    endif
    let b:muti_seprate_scriptblock = 1
else
    let b:muti_seprate_scriptblock = 0
endif

if b:muti_seprate_scriptblock
    au BufEnter <buffer> call s:MJSHint()
    au InsertLeave <buffer> call s:MJSHint()
    au BufWritePost <buffer> call s:MJSHint()
    au CursorMoved <buffer> call s:GetJSHintMessage()
else
    au BufEnter <buffer> call s:JSHint(1)
    au InsertLeave <buffer> call s:JSHint(1)
    au BufWritePost <buffer> call s:JSHint(1)
    au CursorMoved <buffer> call s:GetJSHintMessage()
    
    "au InsertEnter <buffer> call s:JSHint(1)
    " due to http://tech.groups.yahoo.com/group/vimdev/message/52115
    " if(!has("win32") || v:version>702)
    "     au CursorHold <buffer> call s:JSHint(1)
    "     au CursorHoldI <buffer> call s:JSHint(1)
    " 
    "     au CursorHold <buffer> call s:GetJSHintMessage()
    " endif
endif

au BufLeave <buffer> call s:JSHintClear()

noremap <buffer><silent> dd dd:JSHintUpdate<CR>
noremap <buffer><silent> dw dw:JSHintUpdate<CR>
noremap <buffer><silent> u u:JSHintUpdate<CR>
noremap <buffer><silent> <C-R> <C-R>:JSHintUpdate<CR>

if !exists("g:JSHintHighlightErrorLine")
  let g:JSHintHighlightErrorLine = 1
endif

" updateNow
if !exists("*s:JSHintUpdate")
    function s:JSHintUpdate()
        if b:muti_seprate_scriptblock
            silent call s:JSHintClear() "clear previous
            silent call s:MJSHint() " lintnow w/o clear
        else
            silent call s:JSHint(1) " clear and lint
        endif
        call s:GetJSHintMessage() " show messages
    endfunction
endif

if !exists(":JSHintUpdate")
    command JSHintUpdate :call s:JSHintUpdate()
endif

" PyV8 engine has the highest priority https://code.google.com/p/pyv8/
if has('python')
    python << EOF
import vim
import os.path
import sys

if sys.version_info[:2] < (2, 5):
    raise AssertionError('jshint requires Vim must be compiled with Python 2.5 or higher; you have ' + sys.version)
    
Scriptdir = vim.eval('s:install_dir')

sys.path.insert(0, Scriptdir)

import json
from PyV8.PyV8 import * 

class JSHint(JSClass):

    def __init__(self):
        pass

    @property
    def context(self):
        if not hasattr(self,"_context"):
            self._context = JSContext(self)
            with self._context as ctxt:
                self._context.eval(open(os.path.join(Scriptdir,'jshint','jshint.js'), 'r').read())
        return self._context

    def evalScript(self, script):
        if isinstance(script,unicode):
            script = script.encode('utf-8')
        with self.context as ctxt:
            return ctxt.eval(script)

    def lint(self, script):
        return self.evalScript("""
var ok = JSHINT(%s)
      , i
      , error
      , errorCount, messages=[];

if (!ok) {
    errorCount = JSHINT.errors.length;
    for (i = 0; i < errorCount; i += 1) {
        error = JSHINT.errors[i];
        if (error && error.reason && error.reason.match(/^Stopping/) === null) {
            messages.push([error.line, error.character, error.reason].join(":"));
        }
    }
}
messages.join('\\n');
""" % json.dumps(script))

Jshint=JSHint()
vim.command("let b:loaded_pyv8=1")
EOF
else
    let b:loaded_pyv8 = 0
endif

" Set up command and parameters
if has("win32")
  let s:cmd = 'cscript /NoLogo '
  let s:runjshint_ext = 'wsf'
else
  let s:runjshint_ext = 'js'
  if exists("$JS_CMD")
    let s:cmd = "$JS_CMD"
  elseif executable('/System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc')
    let s:cmd = '/System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc'
  elseif executable('node')
    let s:cmd = 'node'
  elseif executable('js')
    let s:cmd = 'js'
  else
    echoerr('No JS interpreter found. Checked for jsc, js (spidermonkey), and node')
  endif
endif

let s:plugin_path = s:install_dir . '\jshint\'
let s:cmd = "cd " . s:plugin_path . " && " . s:cmd . " " . s:plugin_path . "runjshint." . s:runjshint_ext

if !exists("g:jshint_rcfile")
    let s:rc_file = expand('~\.jshintrc')
else
    let s:rc_file = g:jshint_rcfile
endif

if filereadable(s:rc_file)
  let s:jshintrc = readfile(s:rc_file)
else
  let s:jshintrc = []
end

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


" let b:matched = []
" save messages for line no.
let b:matchedlines = {}

function! s:JSHintClear()
  " Delete previous matches
  let s:matches = getmatches()
  for s:matchId in s:matches
    if s:matchId['group'] == 'JSHintError'
        call matchdelete(s:matchId['id'])
    endif
  endfor
  " let b:matched = []
  let b:matchedlines = {}
  " let b:cleared = 1
endfunction

" autoclear
" if true will clear lint result each this function called
" if false will not clear lint result util JSHintClear is called
function! s:JSHint(autoclear,...)
  highlight link JSHintError SpellBad

  if a:autoclear
      " if exists("b:cleared")
          " if b:cleared == 0
             silent call s:JSHintClear()
          " endif
          " let b:cleared = 1
      " endif
  endif

  " Detect range
  if !exists("a:1")
      let b:startline=1
  else 
      let b:startline=a:1
  endif

  if !exists("a:2")
      let b:endline='$'
  else 
      let b:endline=a:2
  endif

  let b:code = join(s:jshintrc + getline(b:startline, b:endline), "\n") . "\n"

  if b:loaded_pyv8
      python << EOF
vim.command("let b:jshint_output = %s" % json.dumps(Jshint.lint(vim.eval("b:code"))))
EOF
  else
      let b:jshint_output = system(s:cmd, b:code)
  endif

  if v:shell_error
     echoerr 'could not invoke JSHint!'
  end

  for error in split(b:jshint_output, "\n")
    " Match {line}:{char}:{message}
    let b:parts = matchlist(error, "\\(\\d\\+\\):\\(\\d\\+\\):\\(.*\\)")
    if !empty(b:parts)
      let l:line = b:parts[1] + (b:startline - 1 - len(s:jshintrc)) " Get line relative to selection

        " Store the error for an error under the cursor
      let s:matchDict = {}
      let s:matchDict['lineNum'] = l:line
      let s:matchDict['message'] = b:parts[3]
      let b:matchedlines[l:line] = s:matchDict
      if g:JSHintHighlightErrorLine == 1
          let s:mID = matchadd('JSHintError', '\%' . l:line . 'l\S.*\(\S\|$\)')
      endif
      " Add line to match list
      " call add(b:matched, s:matchDict)
    endif
  endfor
  " let b:cleared = 0
endfunction

function! s:MJSHint()
    silent call s:JSHintClear()
    python << EOF
import vim
parser = htmlParser()
parser.feed(vim.eval("join(getline(1,'$'),'\n')"))
for start,end in parser.lintableScripts:
    vim.command('call s:JSHint(0,%d,%d)' % (start+1,end-1))
EOF
endfunction

let b:showing_message = 0

function! s:GetJSHintMessage()
    let s:cursorPos = getpos(".")

    " Bail if RunJSHint hasn't been called yet
    if !exists('b:matchedlines')
        return
    endif

    if has_key(b:matchedlines, s:cursorPos[1])
        let s:jshintMatch = get(b:matchedlines, s:cursorPos[1])
        call s:WideMsg(s:jshintMatch['message'])
        let b:showing_message = 1
        return
    endif

    if b:showing_message == 1
        echo
        let b:showing_message = 0
    endif
endfunction
