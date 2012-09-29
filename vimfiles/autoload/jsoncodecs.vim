" Maintainer: yf liu <sophia.smth@gmail.com>
" Description: json encoding/decoding in vim
"              http://json.org/
"              http://www.ietf.org/rfc/rfc4627.txt?number=4627
" Version: 1.0

let s:save_cpo = &cpo
set cpo&vim

" iternal usage encode to json string
function! jsoncodecs#encode_basestring(str)
    let l:ret = a:str
    "let l:ret = substitute(l:ret,'\\','\\\\','g')
    "let l:ret = escape(l:ret,'"')
    "let l:ret = substitute(l:ret,'\b','\\b','g')
    "let l:ret = substitute(l:ret,'\%x0c','\\f','g')
    "let l:ret = substitute(l:ret,'\n','\\n','g')
    "let l:ret = substitute(l:ret,'\r','\\r','g')
    "let l:ret = substitute(l:ret,'\t','\\t','g')
    let l:ret = substitute(l:ret,'\%x5C','\\\\','g')
    let l:ret = substitute(l:ret,'\%x22','\\"','g')
    let l:ret = substitute(l:ret,'\%x2F','/','g')
    let l:ret = substitute(l:ret,'\%x08','\\b','g')
    let l:ret = substitute(l:ret,'\%x0C','\\f','g')
    let l:ret = substitute(l:ret,'\%x0A','\\n','g')
    let l:ret = substitute(l:ret,'\%x0D','\\r','g')
    let l:ret = substitute(l:ret,'\%x09','\\t','g')
    " TODO unicode escape
    " http://www.ietf.org/rfc/rfc4627
    return l:ret
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
