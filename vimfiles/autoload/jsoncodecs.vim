" Maintainer: yf liu <sophia.smth@gmail.com>
" Description: json encoding/decoding in vim
"              http://json.org/
"              http://www.ietf.org/rfc/rfc4627.txt?number=4627
" Version: 1.0

let s:save_cpo = &cpo
set cpo&vim

" iternal usage encode to json string
function! jsoncodecs#encode_basestring(str)
    let ret = a:str
   "let ret = substitute(ret,'\\','\\\\','g')
   "let ret = escape(ret,'"')
   "let ret = substitute(ret,'\b','\\b','g')
   "let ret = substitute(ret,'\%x0c','\\f','g')
   "let ret = substitute(ret,'\n','\\n','g')
   "let ret = substitute(ret,'\r','\\r','g')
   "let ret = substitute(ret,'\t','\\t','g')
    let ret = substitute(ret,'\%x5C','\\\\','g')
    let ret = substitute(ret,'\%x22','\\"','g')
    let ret = substitute(ret,'\%x2F','/','g')
    let ret = substitute(ret,'\%x08','\\b','g')
    let ret = substitute(ret,'\%x0C','\\f','g')
    let ret = substitute(ret,'\%x0A','\\n','g')
    let ret = substitute(ret,'\%x0D','\\r','g')
    let ret = substitute(ret,'\%x09','\\t','g')
    " TODO unicode escape
    " http://www.ietf.org/rfc/rfc4627
    return ret
endfunction

function! jsoncodecs#dump_string(linelist)
    let json=[]
    for line in a:linelist
        call add(json, jsoncodecs#encode_basestring(line))
    endfor
    return printf('"%s"', join(json,'\n').'\n')
endfunction

function! jsoncodecs#dump_lines() range
    echo jsoncodecs#dump_string(getline(a:firstline,a:lastline))
endfunction

let &cpo = s:save_cpo
