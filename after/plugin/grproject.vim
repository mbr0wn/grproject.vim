" vim: set list:
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
"autocmd grproject BufEnter *.cc,*.h,*.py,CMakeLists.txt call GRCheckForProject()

" Check if this file is part of a GNU Radio project
func! GRCheckForProject()
    if exists('b:grproject_check')
        " Then this was already called
        if exists('b:grproject_name') && b:grproject_iscomponent==1
            if (&l:ft == 'cpp' || &l:ft == 'c')
                setlocal noexpandtab
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
python << EOP
import vim
import os
import subprocess

def setup_buffer(mod_info):
    if not 'modname' in mod_info.keys():
        return
    vim.command("let b:grproject_name = '%s'" % mod_info['modname'])
    try:
        include_cpp_flags = ' '.join(['-I%s' % x for x in mod_info['incdirs']])
        vim.command("let b:syntastic_cpp_cflags = '%s'" % include_cpp_flags)
    except KeyError:
        pass
    try:
        vim.command("let &l:makeprg = 'cd %s; make'" % mod_info['build_dir'])
    except KeyError:
        pass
    try:
        paths = ','.join([x.replace(' ', r'\\\ ') for x in mod_info['incdirs']])
        vim.command("let &l:path = &g:path . '%s'" % paths)
    except KeyError:
        pass
    filetype = vim.eval("&l:ft")
    if 'is_component' in mod_info.keys():
        vim.command("let b:grproject_iscomponent = 1")
        vim.command("setlocal noexpandtab")
        vim.command("setlocal softtabstop=2")
        vim.command("setlocal shiftwidth=2")
        vim.command("setlocal tabstop=8")
    else:
        vim.command("let b:grproject_iscomponent = 0")

try:
    output = subprocess.check_output(['gr_modtool info --python-readable'],
                                     shell=True, stderr=subprocess.STDOUT)
    mod_info = eval(output.strip())
    setup_buffer(mod_info)
except subprocess.CalledProcessError:
    pass

EOP
endfunc

