vim9script

if !has('vim9script') ||  v:version < 900
    # Needs Vim version 9.0 and above
    echo "You need at least Vim 9.0"
    finish
endif

def Echoerr(msg: string)
  echohl ErrorMsg | echom $'[vim9-conversion-aid] {msg}' | echohl None
enddef

# if exists('g:vim9_conversion_aid_loaded')
#     Echoerr('Plugin already loaded')
#     finish
# endif
# g:vim9_conversion_aid_loaded = true

import autoload '../lib/vim9_convert_functions.vim' as vim9conv

command! -nargs=? -complete=buffer Vim9Convert vim9conv.TransformBuffer(<f-args>)

# vim: sw=2 sts=2 et
