""" Utility functions for grproject.vim, a tool to facilitate working
    with GNU Radio out-of-tree modules. """

import re
import sys
import os
import vim
import subprocess

def setup_buffer(mod_info):
    """ Set up all local variables for a buffer. """
    if not 'modname' in mod_info.keys():
        return
    vim.command("let b:grproject_name = '%s'" % mod_info['modname'])
    try:
        include_cpp_flags = ' '.join(['-I%s' % x for x in mod_info['incdirs']])
        vim.command("let b:syntastic_cpp_cflags = '%s'" % include_cpp_flags)
    except KeyError:
        pass
    try:
        vim.command("let b:grproject_builddir = '{}'".format(mod_info['build_dir']))
        vim.command("let &l:makeprg = 'make --directory={}'".format(mod_info['build_dir']))
    except KeyError:
        pass
    try:
        paths = ','.join([x.replace(' ', r'\\\ ') for x in mod_info['incdirs']])
        vim.command("let &l:path = &g:path . '%s'" % paths)
    except KeyError:
        pass
    filetype = vim.eval("&l:ft")
    if 'is_component' in mod_info.keys():
        vim.command("let b:grproject_iscomponent=1")
        if filetype in ('cpp', 'c'):
            vim.command("setlocal expandtab")
            vim.command("setlocal softtabstop=2")
            vim.command("setlocal shiftwidth=2")
            vim.command("setlocal tabstop=8")
    else:
        vim.command("let b:grproject_iscomponent=0")


def setup_project():
    """ Tries to run gr_modtool to get infos, if successful,
        call setup_buffer()
    """
    try:
        output = subprocess.check_output(['gr_modtool info --python-readable'],
                                         shell=True, stderr=subprocess.STDOUT)
        mod_info = eval(output.strip())
        setup_buffer(mod_info)
    except subprocess.CalledProcessError:
        pass

def run_buffer():
    """
    Tries to run something corresponding to whatever file is open.
    Rules:
    - qa_*.py: Run this unit test.
    - *.py: If the file has a line such as "if __name__=='__main__'",
            run the file. Otherwise, guess which unit test corresponds
            to this file, and run it.
    - qa_*.cc: Run this modules C++-based unit tests.
    - *.cc, *.h: Guess which unit test corresponds to this file, run it.
    - CMakeLists.txt: Re-run cmake.

    TODO: Cache run cmd!
    """
    def get_test_cmd_for_py(filename, build_dir, is_component):
        # If it's a QA file, we can directly infer the corresponding
        # test shell file:
        if not re.match('^qa_', filename) \
           and re.search("if\s*__name__\s*==\s*.__main__.:", open(full_filename).read()):
            return 'python {}'.format(full_filename)
        if re.match('^qa_', filename):
            test_cmd = filename + '_test.sh'
        else:
            test_cmd = 'qa_{}_test.sh'.format(filename)
        if is_component:
            test_cmd = os.path.join(build_dir, 'gr-'+modname, 'python', modname, test_cmd)
        else:
            test_cmd = os.path.join(build_dir, 'python', test_cmd)
        full_filename == vim.eval("expand('%')")
        return 'qa_{}_test.sh'.format(filename)
    def get_test_cmd_for_cpp(filename, is_component):
        if re.match('^qa_', filename):
            return None
        filename = filename.replace('_impl', '')
        return 'qa_{}_test.sh'.format(filename)
    def get_test_cmd_for_cmake(filename):
        return 'cmake {}'.format(os.path.join(build_dir, '..'))


    # Go, go, go:
    filename, ext = os.path.splitext(vim.eval("expand('%:t')"))
    test_cmd = None
    build_dir = vim.eval('b:grproject_builddir')
    is_component = int(vim.eval('b:grproject_iscomponent'))
    modname = vim.eval('b:grproject_name')
    # Identify the test executable:
    if ext == '.py':
        test_cmd = get_test_cmd_for_py(filename)
    elif ext in ('.cc', '.h'):
        test_cmd = get_test_cmd_for_cpp(filename)
    elif ext == '.txt' and filename == 'CMakeLists':
        test_cmd = get_test_cmd_for_cmake(build_dir)
    if test_cmd is not None:
        if is_component:
            test_cmd = os.path.join(build_dir, 'gr-'+modname, 'python', modname, test_cmd)
        else:
            test_cmd = os.path.join(build_dir, 'python', test_cmd)
        if os.path.isfile(test_cmd):
            vim.command('!{}'.format(test_cmd))


if __name__ == "__main__":
    func_dispatcher = {
        "setup_project": setup_project,
        "run_buffer": run_buffer,
    }
    cmd = sys.argv[0]
    if cmd in func_dispatcher.keys():
        func_dispatcher[cmd]()
    else:
        print "grproject: Unkown command."
