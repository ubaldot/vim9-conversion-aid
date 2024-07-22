vim9script

export def TransformBuffer(...bufnr: list<string>)

  var source_bufnr = bufnr('%')
  if empty(source_bufnr)
    source_bufnr = bufnr(bufnr[0])
  endif

  enew
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
      # TODO: the following two could be merged
      # space after ',' - no space before ','
      ->substitute(',\(\w\)', ', \1', 'g')
      ->substitute('\s*,', ',', 'g')
      # space after ':' - no space before ':'
      ->substitute(':\(\w\)', ': \1', 'g')
      ->substitute('\s*:', ':', 'g')
      # String concatenation
      ->substitute('\s*\.\s*', ' \.\.\ ', 'g')
      # Surrounding space between : in brackets[1:3] => [1 : 3]
      ->substitute('[\(\S*\):', '[\1 :', 'g')
      ->substitute('[*:\(\S*\)\]', ': \1] ', 'g')
      # In dictionaries, space after : (TODO: verify)
      #  . to .. in string concatenation (TODO:)
      #  Maybe you cannot do that if there is line continuation
    endif


    # Replace 'let' with 'var' where it is needed
    if transformed_line =~ '^\s*let\s'
      # If it is g:, b:, etc.
      if transformed_line =~ '^\s*let\s\w:'
        transformed_line = transformed_line
            ->substitute('let\s', '', 'g')
            ->substitute(':\s', ':', 'g')
      # If it is script-local
      else
        # Exclude initial 'let' string before appending the variable name to
        # the list already_declared_vars, e.g. 'let foo = bar' becomes 'foo'
        var var_name = line->matchstr('let\s*\w*')[4 : ]
        if index(already_declared_vars, var_name) == -1
          transformed_line = transformed_line->substitute('let\s', 'var ', 'g')
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
