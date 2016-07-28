"==============================================================
"    file: gencode.vim
"   brief: 
" VIM Version: 7.4
"  author: tenfyzhong
"   email: 364755805@qq.com
" created: 2016-06-03 14:34:41
"==============================================================

function! gencode#ConstructIndentLine(content) "{{{
    let l:returnContent = a:content
    if &expandtab
        let l:returnContent = repeat(' ', &tabstop) . l:returnContent
    else
        let l:returnContent = '	' . l:returnContent
        let l:returnContent = substitute(l:returnContent, ' ', '\t', '')
    endif
    return l:returnContent
endfunction "}}}

