" Maintainer: yf liu <sophia.smth@gmail.com>
" Description: haml live compiler
" Version: 1.0
"
if exists("b:did_haml_instant_plugin") || &cp
    finish
endif

" fail silently
if exists("g:disabled_haml_instant_plugin") && g:disabled_haml_instant_plugin 
    finish
endif

let b:did_haml_instant_plugin = 1

" a flag to know if preview window is opened
let s:haml_buf_no = bufnr('%')
let s:preview_opened = 0
let s:html = expand("%:p:r").'.html'
let s:firstrun = 0

" open the preview window
function! s:openPreview()
	if !s:preview_opened
		let haml = expand("%")
		let html = s:html
		let s:preview_opened = 1
		if !filereadable(html)
			execute 'vertical rightbelow new '.html
			:w
		else
			execute 'vertical rightbelow new '.html
		endif
		" the preview window buffer no
		let s:html_buf_no = bufnr('%')
		if !s:firstrun
			" these code only at first time not 'toggle preview window'
			" we don't use autoread here,it only works when call system
			" method, we will do manaually reload
			" http://stackoverflow.com/questions/2490227/how-does-vims-autoread-work
    		" setl autoread
			let s:firstrun = 1
		else
			"these code runs except first time
		endif
		execute("normal \<c-w>\<c-h>")
		call s:hamlCompile()
	endif
endfunction

" close the preview window
function! s:closePreview()
	if s:preview_opened
		" close preview buffer
		" basicly it just hide the buffer
		" see the difference of bdelete and bwipe
		" if we use bwipe the buffer no. may increased
		" cause problems
		execute(":".s:html_buf_no."bd")
		lclose
		let s:preview_opened = 0
	endif
endfunction

" toggle the preview window
function! s:togglePreview()
	if s:preview_opened
		call s:closePreview()
	else
		call s:openPreview()
	endif
endfunction

" combile haml source to html
function! s:hamlCompile()
	" this function can only be called inside haml buffer
	let error_list = []
	let haml_output = haml#compiler#compile(join(getline(1, '$'), "\n"))
	" just for debug purpose, noted the newline is replaced with NL in vim
	" internal @see help system; help writefile;
	" call writefile([haml_output], "debug.txt")
	for line in split(haml_output, "\n")
		let errormatch = matchlist(line, '\v\C(.{-}) on line ([0-9]{-}): (.*)')
		" there is an error in haml
		if errormatch != []
			let errorType = errormatch[1]
			let errorLine = errormatch[2]
			let errorMessage = errormatch[3]
			
			if (stridx(errorType, "error") != -1)
				let eType = "E"
			else 
				let eType = "W"
			endif
			let err = {}
			let err.bufnr = bufnr('%')
			let err.filename = expand('%')
			let err.lnum = errorLine
			let err.text = errorMessage
			let err.type = eType
			call add(error_list, err)
		endif
	endfor
	if error_list != []
		call setloclist(s:haml_buf_no, error_list)
		lopen
		" move curor from quickfix window to haml window
		execute("normal \<c-w>\<c-k>")
	else
		let html = []
		for line in split(haml_output, "\n")
			call add(html,line)
		endfor
		if html != []
			call writefile(html,s:html)
			if s:preview_opened
				" reload preview
				execute("normal \<c-w>\<c-l>")
				execute("edit!")
				" the syntax highlight will not working if use the
				" autocmd mapping(InsertLeave, BufWritePost)
				" you can use setf html to force the syntax highlight
				" working. the disadvantage is the scrollbar will be
				" really annoying
				" execute("edit! | setf html")
				execute("normal \<c-w>\<c-h>")
			endif
		endif
		lclose
	endif
endfunction

au InsertLeave,BufWritePost <buffer> call s:hamlCompile()
"au BufWritePost <buffer> call s:hamlCompile()

" Commands
if !exists(":Refresh")
    command Refresh :call s:hamlCompile()
endif

if !exists(":OpenPreview")
    command OpenPreview :call s:openPreview()
endif

if !exists(":ClosePreview")
    command ClosePreview :call s:closePreview()
endif

" keymaps
" refresh preview
noremap <buffer> dd dd:Refresh<CR>
noremap <buffer> dw dw:Refresh<CR>
noremap <buffer> u u:Refresh<CR>
noremap <buffer> <C-R> <C-R>:Refresh<CR>

nnoremap <silent> <leader>op :call <SID>openPreview()<cr>
nnoremap <silent> <leader>cp :call <SID>closePreview()<cr>
nnoremap <silent> <leader>tp :call <SID>togglePreview()<cr>

call s:openPreview()
