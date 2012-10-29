GNU Radio project utility for VIM
=================================

This is a nice plugin that makes the editing of GNU Radio out-of-tree
modules with VIM a lot easier.

What does it do?
----------------

1) Set make paths -- If you call :make, it does the right thing.
2) Set search paths. You can now use 'gf' on all the includes.
3) Configure Syntastic. If you're using Syntastic (that's a static syntax
   checker, FYI), it makes sure that knows where includes are etc.


Prerequisites
-------------

The only prerequisite (right now) is that your VIM must have Python support,
and gr-modtool must be installed and reachable in your path.
Basically, if you can call gr\_modtool.py in your standard shell, you're fine.

Installation (the easy way -- with pathogen and git submodule)
--------------------------------------------------------------

Assuming you're using pathogen (if you're not, you should really, really
check it out) all you have to do is go to copy the grproject dir into
the bundle/ dir of your vim settings.

Something like this:

    $ cd .vim
    $ git submodule add git@github.com:mbant/grproject.vim.git bundle/grproject
    $ git submodule init

That's it.

Using
-----

At this point, it only sets up stuff internally, so all you have to do is
edit your files in your module. The module will spring up automatically and
configure paths etc.

