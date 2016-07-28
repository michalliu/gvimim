"==============================================================
"    file: gencode.vim
"   brief: 
" VIM Version: 7.4
"  author: tenfyzhong
"   email: 364755805@qq.com
" created: 2016-06-02 21:53:58
"==============================================================

if !exists(':A')
    echom 'need a.vim plugin'
    finish
endif

command! GenDefinition call gencode#definition#Generate()
command! GenDeclaration call gencode#declaration#Generate()
