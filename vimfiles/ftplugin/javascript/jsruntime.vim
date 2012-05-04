" Maintainer: michal liu <sophia.smth@gmail.com>
" Description: javascript runtime in vim powered by google V8 and PyV8 http://code.google.com/p/pyv8/
"              This plugin required python 2.7 and vim must compile with python
"
"              Command
"
"              :RJ run javascript
"              :RR run html javascript mixed
" Version: 1.0

if exists("b:did_jsruntime_plugin")
    finish
else
    let b:did_jsruntime_plugin = 1
endif

if !has('python')
    finish
endif

let s:install_dir = expand("<sfile>:p:h")

    python << EOF
import vim
import sys

if sys.version_info[:2] < (2, 5):
    raise AssertionError('jsruntime requires Vim must be compiled with Python 2.5 or higher; you have ' + sys.version)
    
sys.path.insert(0, vim.eval('s:install_dir'))

from jsruntime import w3c
from jsruntime.browser import *

# Thinking a tab in a real browser
class BrowserTab(object):
    # it take url and makeup as input
    # generate documentElement and Global Window Object
    def __init__(self,url='about:blank',html='<html><head></head><body><p></p></body></html>'):
        self.doc = w3c.parseString(html)
        self.win = HtmlWindow(url,  self.doc)
EOF

" this function run context in pure js
function! s:RunJS(startline,...)
    " Detect range
    if a:startline < 1
        let b:startline=1
    else 
        let b:startline=a:startline
    endif
    if !exists("a:1")
        let b:endline='$'
    else 
        let b:endline=a:1
    endif
    python << EOF
NewTab=BrowserTab()
NewTab.win.evalScript(vim.eval("join(getline(b:startline, b:endline),'\n')"))
EOF
endfunction

" this function run all the document like a real browser does
function! s:RunBrowser(startline,...)
    " Detect range
    if a:startline < 1
        let b:startline=1
    else 
        let b:startline=a:startline
    endif
    if !exists("a:1")
        let b:endline='$'
    else 
        let b:endline=a:1
    endif
    python << EOF
NewTab=BrowserTab(url='http://localhost:8080/path?query=key#frag',html=vim.eval("join(getline(b:startline, b:endline),'\n')"))
NewTab.win.fireOnloadEvents()
EOF
endfunction

" addCommand to RunJS
if !exists(":RunJS")
    command RunJS :call s:RunJS(1)
endif

if !exists(":RunJSBlock")
    command -nargs=? RunJSBlock :call s:RunJS(<args>)
endif

if !exists(":RunHtml")
    command RunHtml :call s:RunBrowser(1)
endif

" addCommand to MixedHTMLAndJs
if !exists(":RunHtmlBlock")
    command -nargs=? RunHtmlBlock :call s:RunBrowser(<args>)
endif

