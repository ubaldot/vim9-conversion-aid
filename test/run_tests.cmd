@echo off

REM Script to run the unit-tests for the vim9_conversion_aid.vim Vim plugin on MS-Windows

SETLOCAL
REM Define the paths and files
SET "VIMPRG=vim.exe"
SET "VIMRC=vimrc_for_tests"
SET "VIM_CMD=%VIMPRG% -U NONE -i NONE -N --not-a-term"


REM Run Vim with the specified configuration and additional commands
%VIM_CMD% -c "vim9cmd g:TestName='test_vim9_conversion_aid.vim'" -S "runner.vim"

REM Check the exit code of Vim command
if %ERRORLEVEL% EQU 0 (
    echo Vim command executed successfully.
) else (
    echo ERROR: Vim command failed with exit code %ERRORLEVEL%.
    exit /b 1
)

REM Check test results
echo VIM9-CONVERSION-AID unit test results
type results.txt

REM Check for FAIL in results.txt
findstr /I "FAIL" results.txt > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ERROR: Some test failed.
    exit /b 1
) else (
    echo All tests passed.
)

REM Exit script with success
exit /b 0
