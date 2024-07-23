# vim9-conversion-aid (WIP)

A little help for upgrading to Vim9.

The tool is nothing but an aid to convert legacy Vim scripts to Vim 9
language. It does not make miracles, nor it is bullet proof, it is certainly
buggy and have a questionable design, but it may help you in speeding up the
conversion process.

What it is supposed to do:

* replace all occurrences of `func`, `function`, etc. with `def` and `enddef`,
* replace comment string `"` with `#`,
* replace `v:true, v:false` with `true, false`,
* add needed leading/trailing space for symbols like `=, :`, etc. as needed,
* Remove line continuation symbol `\`,
* ... and more.

There is only one command available which is `Vim9Convert` that takes a buffer
as optional argument.

To be on the safe side, start Vim with `vim --clean` and then source the
plugin manually (i.e.
`:source /path/to/vim9-conversion-aid/plugin/vim9-conversion-aid.vim`), and
then use `Vim9Convert`.

At this point, if you source the converted script you will most likely have
errors, but the error messages should tell you what shall be fixed and how.
Also, mind that `:h vim9` can be a great support for fixing the remaining
errors if you really don't know how.

To see how the tool perform the upgrade you can take a look at the
`testfile.vim` and `targetfile.vim` in the test folder of this repo. As you
will see, some manual work is still required, but the starting point is rather
favorable compared to starting from scratch.

## Limitations

The tool works better if the original script is not written in a fancy way. As
said, don't expect miracles and consider the following limitations:

* no inline comments, e.g. the following won't be fixed:

```
let s:a = 3 " This is a comment
```

The following will be fixed:

```
" This is a comment
let s:a = 3
```

* it won't fix string concatenation if `.` does not have a leading and a
  trailer white-space,
* functions with variable number of arguments won't be fixed,
* it won't remove `eval`,
* lambda expressions will not be fixed,
* Vim9 syntax/semantics updates and datatypes shall be handled manually.

... but there is certainly more that you will need to fix manually. If you
find bugs or have improvements suggestions, please open an issue or send a PR.

## `let`

The Vim9 upgrading of `let` defined variables is a bit tricky, yet the tool
tries to do its best to make it. However, by default, the `let` conversion is
disabled. You can enable it by setting `g:vim9_conversion_aid_fix_let = true`.

Such a feature removes all the `let` statements, and the variables
declarations are adjusted by further taking into account their scope.

However, this feature **fix the variables definitions, but not their usage.**
For example, if you have the following statement:

```
let newdict = CreateDict()
call PrintDictContent(newdict)
```

it will be converted to the following:

```
g:newdict = CreateDict()
PrintDictContent(newdict)
```

i.e. the argument to the function call shall be manually fixed.

Furthermore, given that variables names can be easily shadowed, we decided to
keep `s:` and `a:` to help you in checking if your script semantic is still
valid, and eventually perform the necessary adjustments Once done, you can
remove the `s:`and the `a:` with a simple `:%s/\v(a:|s:)//g`. Nevertheless, it
would be the best if you prepare your script by avoiding shadowing variables.
