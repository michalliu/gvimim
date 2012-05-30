" Maintainer: yf.liu <sophia.smth@gmail.com>
" Description: javascript runtime in vim powered by google V8 and PyV8 http://code.google.com/p/pyv8/
"
" Version: 1.0

if exists("b:did_jsruntime_plugin")
    finish
endif

let b:did_jsruntime_plugin = 1

" jsruntime status
" not exists jsruntime not loaded
" 0 loaded but not working
" 1 everything is ok
let g:loaded_jsruntime = 0

" plugin path
let s:install_dir = expand("<sfile>:p:h")

" See if we have python and PyV8 is installed
let s:python_support = 0

if has('python')
    python << EOF
import sys,os,vim
#if sys.version_info[:2] < (2,7):
#    vim.command("jsruntime.vim complains \"Vim must be compiled with Python 2.7, you have %s\"" % sys.version)
sys.path.insert(0, vim.eval('s:install_dir'))

try:
  # PyV8 js runtime use minimal namespace to avoid conflict with other plugin
  from PyV8 import PyV8
  vim.command('let s:python_support = 1')
except ImportError,e:
    err = str(e)
    if err.startswith("libboost_python.so.1.50.0"):
        print "Hint:" 
        print "(PyV8) - A Javascript interpreter can be enabled by execute the follwing command"
        print " "
        print "sudo ln -s %s /usr/lib" % os.path.join(vim.eval("s:install_dir"),'PyV8','libboost_python.so.1.50.0')
        print " "
EOF
endif

if s:python_support
    python << EOF
import re
class VimJavascriptConsole(PyV8.JSClass):

    def __init__(self):
        pass

    def _out(self,obj,name=''):
        if not obj:
            obj = "undefined"
        print '%s%s' % (name,obj)

    def log(self,obj):
        return self._out(obj)

    def debug(self,obj):
        return self._out(obj,name="DEBUG: ")

    def info(self,obj):
        return self._out(obj,name="INFO: ")

    def warn(self,obj):
        return self._out(obj,name="WARN: ")

    def error(self,obj):
        return self._out(obj,name="ERROR: ")

class VimJavascriptRuntime(PyV8.JSClass):

    def __init__(self):
        self._console = VimJavascriptConsole()

    def alert(self, msg):
        """Displays an alert box with a message and an OK button"""
        if not msg:
            msg = "undefined"
        print "ALERT: ", msg

    @property
    def console(self):
        return self._console

    @property
    def context(self):
        if not hasattr(self,"_context"):
            self._context = PyV8.JSContext(self)
            self._context.enter()
        return self._context

    def evalScript(self, script):
        if not isinstance(script, unicode):
            script = unicode(script, vim.eval("&encoding"))
        # pyv8 likes unicode
        # script = script.encode("utf-8")
        with self.context as ctxt:
            return ctxt.eval(script)

# vim javascript runtime instance
jsRuntimeVim = VimJavascriptRuntime()

# PyV8 js runtime in browser context
# Think a tab in a real browser
import PyWebBrowser.w3c
import PyWebBrowser.browser
class BrowserTab(object):
    def __init__(self,url='about:blank',html='<html><head></head><body><p></p></body></html>'):
        if not isinstance(html, unicode):
            html = unicode(html, vim.eval("&encoding"))
        self.doc = PyWebBrowser.w3c.parseString(html)
        self.win = PyWebBrowser.browser.HtmlWindow(url,  self.doc)
EOF
    let s:js_interpreter = 'pyv8'
else
    if has('win32')
        let s:js_interpreter='cscript /NoLogo'
        let s:runjs_ext='wsf'
    else
        let s:runjs_ext='js'
        if exists("$JS_CMD")
            let s:js_interpreter = "$JS_CMD"
        elseif executable('/System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc')
            let s:js_interpreter = '/System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc'
        elseif executable('node')
            let s:js_interpreter = 'node'
        elseif executable('js')
            let s:js_interpreter = 'js'
        else
            echoerr("jsruntime.vim complains Not found a valid JS interpreter. Checked for jsc, js (spidermonkey), and node")
            finish
        endif
    endif
endif

" no error
let g:loaded_jsruntime = 1

" expose to other plugin to know
if s:js_interpreter == 'pyv8'
    let g:jsruntime_support_living_context = 1
else
    let g:jsruntime_support_living_context = 0
endif

" let g:jsruntime_support_living_context = 0
" let s:js_interpreter='cscript /NoLogo'
" let s:runjs_ext='wsf'
"
" something you need to know as a vim scripter
" :help CR-used-for-NL
" http://vim.wikia.com/wiki/Newlines_and_nulls_in_Vim_script
if !exists('*b:jsruntimeEvalScript')
    function b:jsruntimeEvalScript(script,...)
        let l:result=''
        if !exists("a:1")
            let l:renew_context = 0
        else
            let l:renew_context = a:1
        endif

        if !g:jsruntime_support_living_context
            let l:renew_context = 0
        endif

        " pyv8 eval
        if s:js_interpreter == 'pyv8'
    python << EOF
import vim,json
if int(vim.eval('l:renew_context')) and jsRuntimeVim:
    #print 'context cleared'
    jsRuntimeVim.context.leave()
    jsRuntimeVim = VimJavascriptRuntime()
try:
    ret = jsRuntimeVim.evalScript(vim.eval('a:script'))
except Exception,e:
    print 'jsruntime.vim complains, %s' % e
    ret = None
if not ret:
    ret = 'undefined'
else:
    ret = str(ret)
    #ret = str(type(ret))
vim.command('let l:result=%s' % json.dumps(ret))
EOF
        else
            let s:cmd = s:js_interpreter . ' "' . s:install_dir . '/jsrunner/runjs.' . s:runjs_ext . '"'
            let l:result = system(s:cmd, a:script)
            if v:shell_error
               echoerr 'jsruntime is not working properly. plz visit http://www.vim.org/scripts/script.php?script_id=4050 for more info'
            end
        endif
        return l:result
    endfunction
endif

if !exists('*b:jsruntimeEvalScriptInBrowserContext') && s:js_interpreter == 'pyv8'
    function b:jsruntimeEvalScriptInBrowserContext(script)
        python << EOF
NewTab=BrowserTab(url='http://localhost:8080/path?query=key#frag',html=vim.eval("a:script"))
NewTab.win.fireOnloadEvents()
EOF
    endfunction
endif
