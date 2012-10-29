"
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
autocmd grproject BufNewFile,BufReadPost *.cc,*.h,*.py,CMakeLists.txt call GRCheckForProject()
"autocmd grproject BufEnter *.cc,*.h,*.py,CMakeLists.txt call GRCheckForProject()

" Check if this file is part of a GNU Radio project
func! GRCheckForProject()
	if exists('b:grproject_check')
		" Then this was already called
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

try:
	mod_info = eval(os.popen('gr_modtool.py info --python-readable').read().strip())
	setup_buffer(mod_info)
except OSError:
    pass

EOP
endfunc

