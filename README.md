# vim9-conversion-aid

A little help for upgrading to Vim9.

The tool is nothing but an aid to convert legacy Vim scripts to Vim 9
language. It does not make miracles, nor it is bullet proof, it is certainly
buggy and have a questionable design, but it may help you in speeding up the
conversion process.

What it is supposed to do:

* replace all occurrences of `func`, `function`, etc. with `def` and `enddef`,
* replace comment string `"` with `#`,
* fix variables defined as `let`,
* remove all occurrences of `a:` and `s:`,
* add needed leading/trailing space for symbols like `=, , , :`, etc. as
  needed,
* Remove line continuation symbol `\`,
* ... and more.

There is only one command available which is `Vim9Convert` that takes a buffer
as optional argument.

If you source the converted script you will most likely have errors, but the
error messages should tell you what shall be fixed and how. Also, mind that
`:h vim9` can be a great support for fixing the remaining errors.

## Limitations

The tool works better if the original script is not written in a fancy way. As
said, don't expect miracles and consider the following limitations;

* No inline comments, e.g. the following won't be fixed:

```
let s:a = 3 # This is a comment
```

The following will be fixed:

```
# This is a comment
let s:a = 3
```

* It won't fix string concatenation if `.` does not have a leading and a
  trailer whitespace
* Lambda expressions will not be fixed,
* Vim9 semantics updates and datatypes shall be handled manually.
