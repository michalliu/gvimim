set nocompatible
source $VIMRUNTIME/vimrc_example.vim
"source $VIMRUNTIME/mswin.vim
"behave mswin

set diffexpr=MyDiff()
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction

" 本文件须保存为utf-8(BOM)格式

" 让Vim自动检测文件类型并加载相关插件
filetype on
filetype plugin on

" pyflakes
filetype plugin indent on

" filetype detection
augroup filetypemore
    au!
    au BufRead,BufNewFile *.json setf json
	au BufRead,BufNewFile *.smali set filetype=smali
augroup end

" 开启语法高亮
syntax on

" 颜色主题
colorscheme zellner

" http://vim.wikia.com/wiki/Converting_tabs_to_spaces
" insert space when <tab> is down
" set expandtab
" insert four spaces when <tab> is down
set tabstop=4
" insert 4 spaces when indent
set shiftwidth=4

" 出错时用闪屏代替声音
set vb

" 常规设置
if has("win32")

    " vim在与屏幕/键盘交互时用的编码
    "set termencoding = 
    
    " 打开文件时用的编码
    set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
     
    " 文件存储时的编码
    " set fileencoding =

    set lines=30
    set columns=120

    " 显示行号
    set nu

    " 不换行
    "set nowrap

    " 状态栏不自动消失
    " set laststatus=2

    " 设置缩进
    set shiftwidth=4
    set tabstop=4

    " 关闭备份
    set nobackup
    set nowritebackup

    " 移除菜单栏、工具栏和滚动条
    "set guioptions-=m
    "set guioptions-=T
    "set guioptions-=r
    "set guioptions-=b
    
    " 代码折叠 
    set foldmethod=syntax

    " 使用中文帮助
    set helplang=cn
    
    " gvim设置
    if has("gui_running")

        " vim内部编码
        set encoding=utf-8

        " 解决起始画面及标题乱码
        language messages zh_CN.utf-8

        " 解决菜单乱码
        source $VIMRUNTIME/delmenu.vim
        source $VIMRUNTIME/menu.vim
        
        " 字体设置
        set guifont=Menlo:h10
        "set guifont=Monaco:h9
        "set guifont=Consolas:h10
        "set guifont=Courier_New:h10
        set guifontwide=微软雅黑:h10

        " 设置窗口的起始位置和大小
        winpos 250 200

        " vimtweak 命令映射
        " 透明度设置
        command -nargs=1 SetAlpha call libcallnr("vimtweak.dll", "SetAlpha", <args>)
        " 窗口总在最前
        command -nargs=1 SetTopMost call libcallnr("vimtweak.dll", "EnableTopMost", <args>)
        " 窗口最大化
        command -nargs=1 SetMaximize call libcallnr("vimtweak.dll", "EnableMaximize", <args>)

    endif
else
	" see help 'backspace'
	set backspace=2
	set nobackup
endif

" 插件设置
let appdata = expand('$VIM/.appdata')
" jshint
let g:jshint_rcfile = appdata.'/jshint/.jshintrc'
" loadtemplate
let g:template_path = appdata.'/load_template/templates/'

" 反注释条目以禁用javascript自动检查错误,可用<Leader>al手动激活
" let g:jsflakes_autolint=0

" javascript dictionary
au FileType javascript set dictionary=$VIM\vimfiles\dict\javascript.dict

" 常用快捷键
" F2取消高亮
nmap <F2> :nohlsearch<CR>:echo <CR>

" F3删掉windows换行符^M
nmap <F3> :%s/\r\(\n\)/\1/g<CR>:echo <CR>

" F4高亮当前光标所在列
nmap <F4> :call SetColorColumn()<CR>:echo <CR>
function! SetColorColumn()
    let col = virtcol(".")
    let ccs = split(&cc,',')
    if count(ccs, string(col)) <= 0
        let op = "+"
    else
        let op = "-"
    endif
    exec "set cc".op."=".col
endfunction

" F5新标签,跟winmanager自带的fileexplorer冲突
" norenmap <F5> :tabnew<CR>

" F6 已注册为切换不可见字符显示
"
" F7删除无内容的行，但保留换行
nmap <F7> :%s/^\(\s\+\)$//g<CR>:echo <CR>

" F8切换taglist的显示
" nmap <F8> :TlistToggle<CR>

" minibufexplorer
" C-S-TAB and C-TAB is not working in xterm
noremap <TAB>   :MBEbn<CR>
noremap <S-TAB> :MBEbp<CR>

" winmanager设置
" let g:winManagerWindowLayout="BufExplorer,FileExplorer|TagList"
let g:winManagerWidth=30
let g:defaultExplorer=0

" nerdtree设置
let g:NERDTree_title="[NERDTree]"
let g:winManagerWindowLayout="BufExplorer,NERDTree|TagList"

function! NERDTree_Start()
    exec 'NERDTree'
endfunction

function! NERDTree_IsValid()
    return 1
endfunction

" F8切换taglist的显示
nmap <C-W><C-F> :FirstExplorerWindow<CR>
nmap <C-W><C-B> :BottomExplorerWindow<CR>
nmap <F8> :WMToggle<CR>
" nmap wm :WMToggle<CR>

" F12在当前目录生成ctags
noremap <F12> :call Do_CsTag()<CR>
function Do_CsTag()
	let iswindows=0
	if has("win32")
		let iswindows=1
	endif
    let dir = getcwd()
    if filereadable("tags")
        if(iswindows==1)
            let tagsdeleted=delete(dir."\\"."tags")
        else
            let tagsdeleted=delete("./"."tags")
        endif
        if(tagsdeleted!=0)
            echohl WarningMsg | echo "Fail to do tags! I cannot delete the tags, code=" . tagsdeleted . " permission error?" | echohl None
            return
        endif
    endif
    if has("cscope")
        silent! execute "cs kill -1"
    endif
    if filereadable("cscope.files")
        if(iswindows==1)
            let csfilesdeleted=delete(dir."\\"."cscope.files")
        else
            let csfilesdeleted=delete("./"."cscope.files")
        endif
        if(csfilesdeleted!=0)
            echohl WarningMsg | echo "Fail to do cscope! I cannot delete the cscope.files code=" . csfileseleted . " permission error?" | echohl None
            return
        endif
    endif
    if filereadable("cscope.out")
        if(iswindows==1)
            let csoutdeleted=delete(dir."\\"."cscope.out")
        else
            let csoutdeleted=delete("./"."cscope.out")
        endif
        if(csoutdeleted!=0)
            echohl WarningMsg | echo "Fail to do cscope! I cannot delete the cscope.out code=" . csoutdeleted . " permission error?" | echohl None
            return
        endif
    endif
    if(executable('ctags'))
        "silent! execute "!ctags -R --c-types=+p --fields=+S *"
        silent! execute "!ctags -R --c++-kinds=+p --fields=+iaS --extra=+fq .>/dev/null 2>&1"
    endif
    if(executable('cscope') && has("cscope") )
        if(iswindows!=1)
            silent! execute "!find . -name '*.h' -o -name '*.c' -o -name '*.cpp' -o -name '*.java' -o -name '*.cs' > cscope.files"
        else
            silent! execute "!dir /s/b *.c,*.cpp,*.h,*.java,*.cs >> cscope.files"
        endif
        silent! execute "!cscope -b"
        execute "normal :"
        if filereadable("cscope.out")
            silent! execute "cs add cscope.out"
        endif
    endif
	redraw!
	echo "Refresh ctags okay!"
endfunction

if has("gui_running")
    " au VimEnter * if line('$') > &lines | set go+=r | else | set go-=r | endif
    " au VimResized * if line('$') > &lines | set go+=r | else | set go-=r | endif
    au CursorMoved * if line('$') > &lines | set go+=r | else | set go-=r | endif
    au CursorMovedI * if line('$') > &lines | set go+=r | else | set go-=r | endif
endif
