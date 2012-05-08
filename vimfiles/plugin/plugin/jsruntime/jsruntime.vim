" Maintainer: michal.liu <sophia.smth@gmail.com>
" Description: javascript runtime in vim powered by google V8 and PyV8 http://code.google.com/p/pyv8/
"
" Version: 1.0

if exists("b:did_jsruntime_plugin")
    finish
else
    let b:did_jsruntime_plugin = 1
endif

let s:install_dir = expand("<sfile>:p:h")

if has('python')
    python << EOF
import vim
sys.path.insert(0, vim.eval('s:install_dir'))

# PyV8 js runtime
from PyV8.PyV8 import *

class VimJavascriptConsole(JSClass):

    def __init__(self):
        pass

    def _out(self,obj,name=''):
        print '%s%s\n' % (name,obj)

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

class VimJavascriptRuntime(JSClass):

    def __init__(self):
        self._console = VimJavascriptConsole()

    def alert(self, msg):
        """Displays an alert box with a message and an OK button"""
        print "ALERT: ", msg

    @property
    def console(self):
        return self._console

    @property
    def context(self):
        if not hasattr(self,"_context"):
            self._context = JSContext(self)
            self._context.enter()
        return self._context

    def evalScript(self, script):
        if isinstance(script,unicode):
            script = script.encode('utf-8')
        with self.context as ctxt:
            return ctxt.eval(script)

# vim javascript runtime instance
jsRuntimeVim = VimJavascriptRuntime()

# PyV8 js runtime in browser context
from PyWebBrowser import w3c
from PyWebBrowser.browser import *

# Think a tab in a real browser
class BrowserTab(object):
    def __init__(self,url='about:blank',html='<html><head></head><body><p></p></body></html>'):
        self.doc = w3c.parseString(html)
        self.win = HtmlWindow(url,  self.doc)
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
            echoerr('No JS interpreter found. Checked for jsc, js (spidermonkey), and node')
        endif
    endif

endif

" expose to other plugin to know
if s:js_interpreter == 'pyv8'
	let b:jsruntime_support_living_context = 1
else
	let b:jsruntime_support_living_context = 0
endif

" let s:js_interpreter='cscript /NoLogo'
" let s:runjs_ext='wsf'
"
if !exists('b:jsruntimeEvalScript')
    function b:jsruntimeEvalScript(script,...)
        let l:result=''
        if !exists("a:1")
            let l:renew_context = 0
        else
            let l:renew_context = a:1
        endif

		if !b:jsruntime_support_living_context
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
ret = jsRuntimeVim.evalScript(vim.eval('a:script'));
if not ret:
    ret = 'undefined'
else:
    ret = str(ret)
    #ret = str(type(ret))
vim.command('let l:result=%s' % json.dumps(ret))
EOF
        else
            let s:cmd = s:js_interpreter . ' "' . s:install_dir . '\jsrunner\runjs.' . s:runjs_ext . '"'
            let l:result = system(s:cmd, a:script)
        endif
        return l:result
    endfunction
endif

if !exists('b:jsruntimeEvalScriptInBrowserContext') && s:js_interpreter == 'pyv8'
    function b:jsruntimeEvalScriptInBrowserContext(script)
        python << EOF
NewTab=BrowserTab(url='http://localhost:8080/path?query=key#frag',html=vim.eval("a:script"))
NewTab.win.fireOnloadEvents()
EOF
    endfunction
endif
