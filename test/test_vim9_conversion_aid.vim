vim9script

# Test for the vim-vim9-conversion-aid.vim plugin
# Copied and adjusted from Vim distribution

import "./common.vim"
var WaitForAssert = common.WaitForAssert


# Tests start here
def g:Test_converted_script()

  # Full test
  g:vim9_conversion_aid_fix_let = true

  var test_script_name = 'test_script.vim'
  var expected_script_name = 'expected_script.vim'

  exe $"edit {test_script_name}"
  var test_script_bufnr = bufnr()

  Vim9Convert
  WaitForAssert(() => assert_equal(2, winnr('$')))
  var actual_script_bufnr = bufnr('$')

  # Open expected buffer
  new
  exe $"edit {expected_script_name}"
  var expected_script_bufnr = bufnr()

  # Compare expected VS actual
  for lnum in range(1, line('$'))
      var expected_line = getbufoneline(expected_script_bufnr, lnum)
      var actual_line =  getbufoneline(actual_script_bufnr, lnum)
      assert_equal(expected_line, actual_line)
  endfor

  :%bw!

  unlet g:vim9_conversion_aid_fix_let

enddef
