vim9script

const package_fullpath = expand('<sfile>')->fnamemodify(':h:h')

# Needed if you run :packadd vim9-conversion-aid from an already opened .vim file
if &filetype == 'vim'
  execute $"source {package_fullpath}/ftplugin/vim_9.vim"
endif
