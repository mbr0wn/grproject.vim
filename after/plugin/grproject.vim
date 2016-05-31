" vim:list:listchars=tab\:>-:et:sw=4:
" Plugin: grproject
"
" Version: 0.1-alpha-hack
"
" Description:
" Helps working with GNU Radio projects.
"
" Maintainer: Martin Braun
"
" Credits: I took some inspiration from dirsettings.vim by Tye Zdrojewski
"

if version < 700
    finish
endif

" Define a group so we can delete them when this file is sourced, and we don't
" end up with multiple autocmd entries if this file is sourced more than once.
augroup grproject
autocmd! grproject
autocmd grproject BufEnter *.cc,*.h,*.py,CMakeLists.txt call GRCheckForProject()

" Check if this file is part of a GNU Radio project
func! GRCheckForProject()
    if exists('b:grproject_check')
        " Then this was already called
        if exists('b:grproject_name') && b:grproject_iscomponent==1
            if (&l:ft == 'cpp' || &l:ft == 'c')
                setlocal softtabstop=2"
                setlocal shiftwidth=2"
                setlocal tabstop=8"
            endif
        endif
        return
    else
        call GRSetupProject()
        let b:grproject_check = 1
    endif
endfunc

func! GRSetupProject()
" Calls 'gr_modtool info' and sets up:
" * include dirs (for syntastic)
" * search paths
" * make command
    if has('python3')
        python3 sys.argv = ["setup_project",]
        py3file ~/.vim/bundle/grproject/after/plugin/grproject.py
    elseif has('python')
        python sys.argv = ["setup_project",]
        pyfile ~/.vim/bundle/grproject/after/plugin/grproject.py
    endif
    if exists('b:grproject_name')
        nnoremap <buffer> <F5> :w<CR>:call GRRunThisBuffer()<CR>
        inoremap <buffer> <F5> <ESC>:w<CR>:call GRRunThisBuffer()<CR>
    endif
endfunc

func! GRRunThisBuffer()
    if has('python3')
        python3 sys.argv = ["run_buffer",]
        py3file ~/.vim/bundle/grproject/after/plugin/grproject.py
    elseif has('python')
        python sys.argv = ["run_buffer",]
        pyfile ~/.vim/bundle/grproject/after/plugin/grproject.py
    endif
endfunc

