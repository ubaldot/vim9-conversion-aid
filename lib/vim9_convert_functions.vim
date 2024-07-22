vim9script

export def TransformBuffer(...bufnr: list<string>)

  var source_bufnr = bufnr('%')
  if empty(source_bufnr)
    source_bufnr = bufnr(bufnr[0])
  endif

  new
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
       # Replace all occurrences of 'func' with 'def'
      ->substitute('\v(func!?|function!?)\s', 'def ', 'g')
      ->substitute('abort', '', 'g')
       # Remove all occurrences of 'call', Remove all occurrences of 'a:' and 's:'
      ->substitute('\v(a:|s:|call\s)', '', 'g')
      ->substitute('endfunction', 'enddef', 'g')
      # Replace '#{' with '{' in dictionaries
      ->substitute('#{', '{', 'g')
      # Remove function('')
      ->substitute('function([''"]\(\w*\)[''"])', '\1', 'g')
      # Space before and after =
      ->substitute('=\(\S\)', '= \1', 'g')
      ->substitute('\(\S\)=', '\1 =', 'g')
      # space after ':' or ',' - no space before ':' or ','
      ->substitute('\([,:]\)\(\w\)', '\1 \2', 'g')
      ->substitute('\(\w\)\s*\([,:]\)', '\1\2', 'g')
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
    # echom transformed_line

    # Replace 'let' with 'var' where it is needed
    if transformed_line =~ '^\s*let\s'
      # If it is g:, b:, etc. OBS! You have it already spaced as g: a, see
      # previous substitute
      if transformed_line =~ '^\s*let\s\+\w:'
        # Use 'let\s\+' to move the variable to the left of the screen
        transformed_line = transformed_line
            ->substitute('let\s', '', 'g')
            ->substitute(':\s', ':', 'g')
      # If it is script-local
      else
        # Exclude initial 'let' string before appending the variable name to
        # the list already_declared_vars, e.g. 'let foo = bar' becomes 'foo'
        # echom already_declared_vars
        var var_name = transformed_line->substitute('\s*let\s\+\(\w\+\)\(\s*[=.\[]\s*.*\)', '\1', '')
        if index(already_declared_vars, var_name) == -1
          transformed_line = transformed_line->substitute('let\s', 'var ', 'g')
          # echom transformed_line
          add(already_declared_vars, var_name)
        else
          transformed_line = transformed_line->substitute('let\s', '', 'g')
        endif
      endif
    endif

    # Append the transformed line to the list
    add(transformed_lines, transformed_line)
  endfor

  # Set the content of the new buffer to the transformed lines
  setbufline(new_bufnr, 1, transformed_lines)

  # Set the new buffer as the current buffer
  execute $'buffer {new_bufnr}'
enddef
