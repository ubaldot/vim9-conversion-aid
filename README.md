# vim9-conversion-aid

A little help for upgrading to Vim9.

The tool is nothing but an aid to convert legacy Vim scripts to Vim 9
language. It does not make miracles, nor it is bullet proof, it is certainly
buggy and have a questionable design, but it may help you in speeding up the
conversion process.

What it is supposed to do:

* replace all occurrences of `func`, `function`, `func!`, `function!` with
  `def` and `endfunction` and `endfunc` with `enddef`,
* fix `let` with `var` and remove `let` from global and buffer-local variables
  definitions,
* remove all occurrences of `call`,
* remove all occurrences of `a:` and `s:`,
* replace `#{` with `{` in dictionaries,
* replace comment string `"` with `#`,
* add spaces before and after `=`,
* add spaces before and after `:` in list slicing (e.g. [1:3] becomes [1 :
  3]),
* place a space after `,` and remove spaces before `,`.

There is only one command available which is `Vim9Convert` that takes a buffer
as optional argument.

The remaining work of adding types, fixing dictionaries, handling line
continuations, etc. shall be done manually. If you source the converted script
you will most likely have errors, but the error messages should tell you what
shall be fixed and how. Also, mind that `:h vim9` can be a great support for
fixing the remaining errors.
