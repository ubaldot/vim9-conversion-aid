#!/bin/bash

# Script to run the unit-tests for the vim-conversion-aid.vim
# Copied and adapted from Vim LSP plugin

GITHUB=1

# No arguments passed, then no exit
if [ "$#" -eq 0 ]; then
  GITHUB=0
fi

VIM_PRG=${VIM_PRG:=$(which vim)}
if [ -z "$VIM_PRG" ]; then
  echo "ERROR: vim (\$VIM_PRG) is not found in PATH"
  if [ "$GITHUB" -eq 1 ]; then
	exit 1
  fi
fi

# Construct the VIM_CMD with correct variable substitution and quoting
VIM_CMD="$VIM_PRG -U NONE -i NONE --noplugin -N --not-a-term"

# Add space separated tests, i.e. "test_vim9_conversion_aid.vim test_pippo.vim etc"
TESTS="test_vim9_conversion_aid.vim"

RunTestsInFile() {
  testfile=$1
  echo "Running tests in $testfile"
  # If you want to see the output remove the & from the line below
  eval $VIM_CMD " -c \"vim9cmd g:TestName = '$testfile'\" -S runner.vim"

  if ! [ -f results.txt ]; then
    echo "ERROR: Test results file 'results.txt' is not found."
	if [ "$GITHUB" -eq 1 ]; then
	   # rm VIMRC
	   exit 2
	fi
  fi

  cat results.txt

  if grep -qw FAIL results.txt; then
    echo "ERROR: Some test(s) in $testfile failed."
		if [ "$GITHUB" -eq 1 ]; then
			exit 3
		fi
	else
		echo "SUCCESS: All the tests in $testfile passed."
		echo
  fi

}

for testfile in $TESTS
do
  RunTestsInFile $testfile
done

# UBA: uncomment the line below
if [ "$GITHUB" -eq 1 ]; then
  exit 0
fi

# kill %- > /dev/null
# vim: shiftwidth=2 softtabstop=2 noexpandtab
