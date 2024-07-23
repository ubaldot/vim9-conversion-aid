vim9script

export def TransformBuffer(...bufnr: list<string>)

  var source_bufnr = bufnr('%')
  if empty(source_bufnr)
    source_bufnr = bufnr(bufnr[0])
  endif

  vertical new
  # UBA
  setlocal bufhidden=wipe
  var new_bufnr = bufnr('%')

  # Get the content of the source buffer
  var source_lines = getbufline(source_bufnr, 1, '$')

  # Initialize a list to append transformed lines
  var transformed_lines = ['vim9script', '']

  var already_declared_script_local_vars = []
  var already_declared_function_local_vars = []
  var transformed_line = ''
  var inside_function = false

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
      ->substitute('call\s', '', 'g')
      # Replace '#{' with '{' in dictionaries
      ->substitute('#{', '{', 'g')
      # Remove function('') for funcref
      ->substitute('\vfunction\([''"](\w*)[''"]\)', '\1', 'g')
      # Leading and trailing white-space for = and ==
      ->substitute('\v(\=+)(\S)', '\1 \2', 'g')
      ->substitute('\v(\S)(\=+)', '\1 \2', 'g')
      # space after ':' or ',' - no space before ':' or ','
      # TODO: It replaces only the first match
      ->substitute('\v([,:])(\S)', '\1 \2', 'g')
      ->substitute('\v\s*([,:])', '\1', 'g')
      # Surrounding space between : in brackets[1:3] => [1 : 3]
      # I assumes that what is inside a list is a \w* and not a \S*
      ->substitute('\v\[\s*(\w+)\s*:\s*(\w+)\s*\]', '[\1 : \2]', 'g')
      # String concatenation
      ->substitute('\s\+\.\s\+', ' \.\.\ ', 'g')
      # Remove line continuation
      ->substitute('\v(^\s*)\\', '\1', 'g')
      # Replace v:true, v:false with true, false (OBS! We need to remove v:
      # spaces)
      ->substitute('v:\([true, false]\)', '\1'[2 : ], 'g')
    endif

    # OBS! All the : have a trailing space, e.g. 'b: foo', 's: bar' , etc.
    # This will be taken into account below.

    if transformed_line =~ '^def'
        inside_function = true
    elseif transformed_line =~ '^enddef'
        inside_function = false
        already_declared_function_local_vars = []
    endif

    # UBA: Adjust based on if you are inside a function.
    if transformed_line =~ '^\s*let\s'
      # Exclude initial 'let' string before appending the variable name to
      # the list already_declared_script_local_vars, e.g. 'let foo = bar' becomes 'foo'
      var var_name = transformed_line->matchlist('\v\s*let\s+([sabwtgv]:\s)?(\w+)\W')[1 : 2]->join('')
      echom var_name

      # Scope explicitly present, i.e. 'let g:foo', 'let b:bar', 'let t:baz',
      if transformed_line =~ '^\s*let\s\+[bwtgv]:'
        # OBS! At this point you should have the form 'g: foo' because you
        # already added a trailing white-space ad removed leading white-space to all the ':' before.
        transformed_line = transformed_line->substitute('let\s\+', '', 'g')

      # Otherwise, if it is script-local....
      elseif !inside_function
        # s: handling
        if index(already_declared_script_local_vars, var_name) == -1 && var_name =~ '^s: '
          transformed_line = transformed_line->substitute('let\s\+', 'var ', 'g')
          add(already_declared_script_local_vars, var_name)
        elseif index(already_declared_script_local_vars, var_name) != -1 && var_name =~ '^s: '
          transformed_line = transformed_line->substitute('let\s\+', '', 'g')
          add(already_declared_script_local_vars, var_name)
        # g: handling
        else
          transformed_line = transformed_line->substitute('let\s\+', 'g:', 'g')
        endif
      # Otherwise if it is function local
      elseif inside_function
        if transformed_line =~ 'let\s\+a:'
          transformed_line = transformed_line->substitute('let\s\+', '', 'g')
        elseif index(already_declared_function_local_vars, var_name) == -1 && index(already_declared_script_local_vars, var_name) == -1
          transformed_line = transformed_line->substitute('let\s\+', 'var ', 'g')
          add(already_declared_function_local_vars, var_name)
        elseif index(already_declared_function_local_vars, var_name) != -1 && index(already_declared_script_local_vars, var_name) == -1
          transformed_line = transformed_line->substitute('let\s\+', '', 'g')
        # Already declared script-local. It can be s: or g:
        elseif transformed_line =~ 'let\s\+s:'
          transformed_line = transformed_line->substitute('let\s\+', '', 'g')
        else
          transformed_line = transformed_line->substitute('let\s\+', 'g:', 'g')
        endif
      endif
    endif

    # Re-compact b: w: t: g: v: a:, s: e.g. from 'b : foo' to 'b:foo'. The leading char of
    # b: could be a non-word OR the beginning of the line
    # Also, get rid off the old s: and a:.
    transformed_line = transformed_line->substitute('\(\W\|^\)\([asbwtgv]\)\s*:\s*', '\1\2:', 'g')
    transformed_line = transformed_line->substitute('\v(s:|a:)', '', 'g')

    #
    # Append the transformed line to the list
    add(transformed_lines, transformed_line)
  endfor
  echom already_declared_script_local_vars

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
#         # the list already_declared_script_local_vars, e.g. 'let foo = bar' becomes 'foo'
#         # echom already_declared_script_local_vars
#         # var var_name = manipulated_line->substitute('\s*let\s\+\(\w\+\)\(\s*[=.\[]\s*.*\)', '\1', '')
#         var var_name = manipulated_line->substitute('\s*let\s\+\(\w\+\)\(\s*.*\)', '\1', '')
#         if index(already_declared_script_local_vars, var_name) == -1
#           manipulated_line = manipulated_line->substitute('let\s', 'var ', 'g')
#           # echom manipulated_line
#           add(already_declared_script_local_vars, var_name)
#         else
#           manipulated_line = manipulated_line->substitute('let\s', '', 'g')
#         endif
#       endif
#     endif

#     return manipulated_line
# enddef
