if exists("current_compiler")
    finish
endif
let current_compiler = "ninja"

if exists(":CompilerSet") != 2
    command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet errorformat&
CompilerSet makeprg=ninja\ -C\ build
