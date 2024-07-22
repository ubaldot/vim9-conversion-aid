vim9script

export def TransformBuffer(...bufnr: list<string>)

  var source_bufnr = bufnr('%')
  if empty(source_bufnr)
    source_bufnr = bufnr(bufnr[0])
  endif

  vertical new
  setlocal bufhidden=wipe
  var new_bufnr = bufnr('%')

  # Get the content of the source buffer
  var source_lines = getbufline(source_bufnr, 1, '$')

  # Initialize a list to append transformed lines
  var transformed_lines = ['vim9script', '']

  var already_declared_vars = []
  var transformed_line = ''
  for line in source_lines
    # Comments " -> #
    transformed_line = line ->substitute('^\s*"', (m) => $'{m[0][: -2]}#', 'g')

    if !(transformed_line =~ '^\s*#')
    transformed_line = transformed_line
       # Replace all occurrences of 'func', etc. with 'def', etc
      ->substitute('\v(^func!?|^function!?)\s', 'def ', 'g')
      ->substitute('abort', '', 'g')
      ->substitute('\v(endfunction|endfunc)', 'enddef', 'g')
       # Remove all occurrences of 'call', Remove all occurrences of 'a:' and 's:'
      ->substitute('\v(a:|s:|call\s)', '', 'g')
      # Replace '#{' with '{' in dictionaries
      ->substitute('#{', '{', 'g')
      # Remove function('') for funcref
      ->substitute('function([''"]\(\w*\)[''"])', '\1', 'g')
      # Leading and trailing white-space for = and ==
      ->substitute('\(=\+\)\(\S\)', '\1 \2', 'g')
      ->substitute('\(\S\)\(=\+\)', '\1 \2', 'g')
      # space after ':' or ',' - no space before ':' or ','
      # TODO: It replaces only the first match
      ->substitute('\([,:]\)\(\S\)', '\1 \2', 'g')
      ->substitute('\s*\([,:]\)', '\1', 'g')
      # ->substitute('\([,:]\)\(\w\)', '\1 \2', 'g')
      # ->substitute('\(\w\)\s*\([,:]\)', '\1\2', 'g')
      # Surrounding space between : in brackets[1:3] => [1 : 3]
      # I assumes that what is inside a list is a \w* and not a \S*
      ->substitute('\[\s*\(\w\+\)\s*:\s*\(\w\+\)\s*\]', '[\1 : \2]', 'g')
      # String concatenation
      ->substitute('\s\+\.\s\+', ' \.\.\ ', 'g')
      # Remove line continuation
      ->substitute('\(^\s*\)\\', '\1', 'g')
      # Replace v:true, v:false with true, false (OBS! We need to remove v:
      # spaces)
      ->substitute('v:\([true, false]\)', '\1'[2 : ], 'g')
    endif
    # echom transformed_line->substitute('\[\s*\(\w\+\)\s*:\s*\(\w\+\)\s*\]', '[\1 : \2]', 'g')

    if transformed_line =~ '^\s*let\s'
      # If it is g:, b:, etc.
      # OBS! At this point you should have the form 'g: foo' because the ':'
      # should be already manipulated
      if transformed_line =~ '^\s*let\s\+[bwtgv]:'
        transformed_line = transformed_line->substitute('let\s', '', 'g')
      # If it is script-local
      else
        # Exclude initial 'let' string before appending the variable name to
        # the list already_declared_vars, e.g. 'let foo = bar' becomes 'foo'
        # echom already_declared_vars
        # var var_name = transformed_line->substitute('\s*let\s\+\(\w\+\)\(\s*[=.\[]\s*.*\)', '\1', '')
        var var_name = transformed_line->substitute('\s*let\s\+\(\w\+\)\(\s*.*\)', '\1', '')
        if index(already_declared_vars, var_name) == -1
          transformed_line = transformed_line->substitute('let\s', 'var ', 'g')
          # echom transformed_line
          add(already_declared_vars, var_name)
        else
          transformed_line = transformed_line->substitute('let\s', '', 'g')
        endif
      endif
    endif

    # Recompact b: w: t: g: v: from b : foo to b:foo.
    transformed_line = transformed_line->substitute('\(\W\)\([bwtgv]\)\s:\s', '\1\2:', 'g')

    # Append the transformed line to the list
    add(transformed_lines, transformed_line)
  endfor
  echom already_declared_vars

  # Set the content of the new buffer to the transformed lines
  setbufline(new_bufnr, 1, transformed_lines)

  # Set the new buffer as the current buffer
  execute $'buffer {new_bufnr}'
enddef


# def FixLet(line: string): string
#     # Replace 'let' with 'var' where it is needed
#     var manipulated_line = line
#     if manipulated_line =~ '^\s*let\s'
#       # If it is g:, b:, etc.
#       # OBS! At this point you should have the form 'g: foo' because the ':'
#       # should be already manipulated
#       if manipulated_line =~ '^\s*let\s\+[bwtgv]:'
#         manipulated_line = manipulated_line->substitute('let\s', '', 'g')
#       # If it is script-local
#       else
#         # Exclude initial 'let' string before appending the variable name to
#         # the list already_declared_vars, e.g. 'let foo = bar' becomes 'foo'
#         # echom already_declared_vars
#         # var var_name = manipulated_line->substitute('\s*let\s\+\(\w\+\)\(\s*[=.\[]\s*.*\)', '\1', '')
#         var var_name = manipulated_line->substitute('\s*let\s\+\(\w\+\)\(\s*.*\)', '\1', '')
#         if index(already_declared_vars, var_name) == -1
#           manipulated_line = manipulated_line->substitute('let\s', 'var ', 'g')
#           # echom manipulated_line
#           add(already_declared_vars, var_name)
#         else
#           manipulated_line = manipulated_line->substitute('let\s', '', 'g')
#         endif
#       endif
#     endif

#     return manipulated_line
# enddef
