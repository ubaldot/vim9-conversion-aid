# vim9-conversion-aid

A little help for upgrading to Vim9.

The tool is nothing but an aid to convert legacy Vim scripts to Vim 9
language.

<!-- It does not make miracles, nor it is bullet proof, it is certainly -->
<!-- buggy and have a questionable design, but it may help you in speeding up the -->
<!-- conversion process. -->

It does not make miracles, nor it is bullet proof, but it may help you in
speeding up the conversion process.

What it is supposed to do:

- replace all occurrences of `func`, `function`, etc. with `def` and `enddef`,
- replace comment string `"` with `#`,
- replace `v:true, v:false` with `true, false`,
- add leading/trailing space to `=` and to comparison signs as needed,
- Remove line continuation symbol `\`,
- ... and more.

There is only one command available which is `Vim9Convert` that takes a buffer
as optional arguments.

The various `let` around won't be converted automatically, but you have to set
`g:vim9_conversion_aid_fix_let = true`. However, this feature **fix the
variables definitions, but not their usage.** For example, if at script level
you have the following statement:

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

Finally, `a:, l:` and `s:` are not removed automatically. In this way you can
better inspect if your script semantic is still valid. You can run a simple
`:%s/\v(a:|s:|l:)//g` once done.

It is recommended to use the tool with a clean `.vimrc` file. That is, you can
start Vim with `vim --clean` and then source the plugin manually (e.g.
`:source /path/to/vim9-conversion-aid/plugin/vim9-conversion-aid.vim` or you
can just download the `vim9-conversion-aid.vim` file and source it), and then
use `Vim9Convert`.

The converted file will most likely have errors, but the error messages should
tell you what shall be fixed and how. Also, mind that `:h vim9` can be a great
support for fixing the remaining errors if you really don't know how.

Finally, if you add a couple of lines on top of your legacy script, then you
can perform an eye-candy line-by-line comparison between the old and the
converted script. (Tip: use `:set scrollbind` or `:diffthis` on both buffers.)

To see how the tool perform the upgrade you can take a look at the
`./test/test_script.vim` and `./test/expected_script.vim` scripts. As you will
see, some manual work is still required, but the starting point is rather
favorable compared to starting from scratch. Note that
`./test/test_script.vim` does not do anything special, it has been written
with the sole purpose of hitting a reasonable amount of corners.

## Limitations

The tool works better if the original script is not written in a fancy way. As
said, don't expect miracles and consider the following limitations:

- no inline comments, e.g. the following won't be fixed:

```
let s:a = 3 " This is a comment
```

The following will be fixed:

```
" This is a comment
let s:a = 3
```

- it won't fix string concatenation if the concatenation operator `.` does not
  have a leading and a trailer white-space,
- functions with variable number of arguments won't be fixed,
- it won't remove `eval`,
- lambda expressions will not be converted in the new format,
- Vim9 syntax/semantics updates and datatypes shall be handled manually.

... but there is certainly more that you will need to fix manually. If you
find bugs or have improvements suggestions, please open an issue or send a PR.
In the latter case, don't forget to update the tests.

To circumnavigate some of the above limitations, prepare your script to don't
hit the above limitations. Plus, avoid using script-local variable names that
shadow vim builtin keywords (e.g. avoid to call a variable `let s:vertical`
because `vertical` is a builtin keyword.
