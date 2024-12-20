vim9script

if !has('vim9script') ||  v:version < 900
    # Needs Vim version 9.0 and above
    echo "You need at least Vim 9.0"
    finish
endif

var DEBUG = false

def Echoerr(msg: string)
  echohl ErrorMsg | echom $'[vim9-conversion-aid] {msg}' | echohl None
enddef

if exists('g:vim9_conversion_aid_loaded')
  if DEBUG
    Echoerr('Plugin already loaded')
  endif

  finish
endif
g:vim9_conversion_aid_loaded = true


# vim: sw=2 sts=2 et
