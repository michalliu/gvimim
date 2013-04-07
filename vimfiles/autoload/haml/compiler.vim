" Maintainer: yf liu <sophia.smth@gmail.com>
" Description: haml live compiler
" Version: 1.0
"

let s:save_cpo = &cpo
set cpo&vim

" constant
let s:haml_stdin_cmd = "haml -s"
let s:haml_js_cmd = "jsruntime"

let install_dir = expand("<sfile>:p:h")
let s:hamljs = join(readfile(install_dir.'/haml.js'),"\n")
let s:hamljs_compiler=join(readfile(install_dir.'/compiler.js'),"\n")
let s:html_beautifier = join(readfile(install_dir.'/html-beautify.js'),"\n")

" test if javascript runtime is available
try
    call javascript#runtime#evalScript("")
    let jsruntimePluginAvailable = 1
catch E117
	let jsruntimePluginAvailable = 0
endtry

if exists("$HAML_COMPILER")
	let s:haml_compiler = "$HAML_COMPILER"
elseif jsruntimePluginAvailable && has("win32")
	let s:haml_compiler = s:haml_js_cmd
elseif executable("haml")
	let s:haml_compiler = s:haml_stdin_cmd
else
	echoerr "haml compiler not found"
	finish
endif

function! s:system(cmd, stdin)
	if strlen(a:stdin) == 0
		return system(a:cmd)
	else
		return system(a:cmd, a:stdin)
	endif
endfunction

function! haml#compiler#compile(source)
	let result = ""
	if strlen(a:source) == 0
		return result
	endif
	if s:haml_compiler == s:haml_stdin_cmd
		let result = s:system(s:haml_compiler,a:source)
	elseif s:haml_compiler == s:haml_js_cmd
		" check javascript execution enviroment
		if !exists("s:did_hamljs_context")
			if javascript#runtime#isSupportLivingContext()
				call javascript#runtime#evalScript(s:hamljs)
				call javascript#runtime#evalScript(s:html_beautifier)
				let s:did_hamljs_context = 1
			else
				let s:did_hamljs_context = 0
			endif
		endif

		" load context
		if s:did_hamljs_context
			let context = ""
		else
			let context = s:hamljs."\n".s:html_beautifier
		endif

		let js =context.printf(s:hamljs_compiler, jsoncodecs#dump_string([a:source]))
		" call writefile([js],"hamlcompiler_source.txt")
		let result = javascript#runtime#evalScript(js)
		" call writefile([result],"hamlcompiler_result.txt")
	endif
	return result
endfunction

let &cpo = s:save_cpo
