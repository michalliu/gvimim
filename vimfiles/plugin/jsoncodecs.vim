" Maintainer: yf liu <sophia.smth@gmail.com>
" Description: json encoding/decoding in vim
"              http://json.org/
"              http://www.ietf.org/rfc/rfc4627.txt?number=4627
" Version: 1.0

if exists("b:did_jsoncodecs_plugin")
    finish
endif

let b:did_jsoncodecs_plugin = 1

" iternal usage encode to json string
if !exists("*s:json_encode_basestring")
    function s:json_encode_basestring(str)
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
endif

if !exists("*b:json_dump_string")
    function b:json_dump_string(linelist)
        let json=[]
        for line in a:linelist
            call add(json, s:json_encode_basestring(line))
        endfor
        return printf('"%s"', join(json,'\n').'\n')
    endfunction
endif

if !exists('*b:json_dumplines')
    function b:json_dumplines() range
        echo b:json_dump_string(getline(a:firstline,a:lastline))
    endfunction
endif

" no error happens
let g:loaded_jsoncodecs = 1
