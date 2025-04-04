vim9script

import autoload '../autoload/vim9_convert_functions.vim' as vim9conv
command! -nargs=? -complete=buffer -buffer Vim9Convert vim9conv.TransformBuffer(<f-args>)
