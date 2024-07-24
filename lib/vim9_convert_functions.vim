vim9script

export def TransformBuffer(...bufnr: list<string>)

  var fix_let = false

  if exists('g:vim9_conversion_aid_fix_let')
    fix_let = g:vim9_conversion_aid_fix_let
  endif

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

  # In very-magic form
  # var comparison_operators_regex = '(\=*[\^\=\~]|!\=|\<\=|\>\=|\<|\>|\=\~|!\~)'
  var comparison_operators_regex = '(\=+|!\=|\<\=|\>\=|\<|\>|!\~)'

  for line in source_lines
    # Comments " -> #
    transformed_line = line ->substitute('^\s*"', (m) => $'{m[0][: -2]}#', 'g')

    if !(transformed_line =~ '^\s*#')
      transformed_line = transformed_line
        # Replace all occurrences of 'func', etc. with 'def', etc
        ->substitute('\v(^func!?|^function!?)\s', 'def ', 'g')
        ->substitute('abort', '', 'g')
        ->substitute('\v(endfunction|endfunc)', 'enddef', 'g')
        # Remove all occurrences of 'call'
        ->substitute('call\s', '', 'g')
        # Replace '#{' with '{' in dictionaries
        ->substitute('#{', '{', 'g')
        # Remove function('') for funcref
        ->substitute('\vfunction\([''"](\w*)[''"]\)', '\1', 'g')

        # Leading and trailing white-space around comparison operators and '='
        # TODO; it add leading and trailing space no matter what.
        # If you already have a space, now you will have two, and then remove
        # the extras with the next 2 substitute functions
        ->substitute($'\v{comparison_operators_regex}([#?]?)', ' \0 ', 'g')
        ->substitute($'\v{comparison_operators_regex}([#?]?)\s\s', '\1\2 ', 'g')
        ->substitute($'\v\s\s{comparison_operators_regex}([#?]?)', ' \1\2', 'g')

        # HACK: Special case for '=~' because now you have '= ~'
        ->substitute('\v\=\s\~(\S)', '=~\1 ', 'g')
        ->substitute('\v\=\s\~\s', '=~ ', 'g')

        # space after ':' or ',' - no space before ':' or ','
        # TODO: It replaces only the first match
        ->substitute('\v([,:])(\S)', '\1 \2', 'g')
        ->substitute('\v\s*([,:])', '\1', 'g')
        # Surrounding space between : in brackets[1:3] => [1 : 3]
        # I assumes that what is inside a list is a \w* and not a \S*
        # TODO FIX
        ->substitute('\v\[\s*(\w+)\s*:\s*(\w+)\s*\]', '[\1 : \2]', 'g')
        # String concatenation
        ->substitute('\s\+\.\s\+', ' \.\.\ ', 'g')
        # Remove line continuation
        ->substitute('\v(^\s*)\\', '\1', 'g')
        # Replace v:true, v:false with true, false (OBS! We need to remove v:
        # spaces)
        ->substitute('v:\([true, false]\)', '\1'[2 : ], 'g')
    endif

    # Re-compact b: w: t: g: v: a:, s: e.g. from 'b : foo' to 'b:foo'.
    transformed_line = transformed_line->substitute('\(\W\|^\)\([asbwtgv]\)\s*:\s*', '\1\2:', 'g')


    # ------------------------ let management ---------------------------
    # OBS! All the : have a trailing space, e.g. 'b: foo', 's: bar' , etc.
    # This will be taken into account below.

    if fix_let
      if transformed_line =~ '^def'
        inside_function = true
      elseif transformed_line =~ '^enddef'
        inside_function = false
        already_declared_function_local_vars = []
      endif

      # OBS! At this point you should have the form 'g: foo' because you
      # already added a trailing white-space white-space to all the ':' before.
      if transformed_line =~ '^\s*let\s'
        # Store variable name without 'let'.
        var var_name = transformed_line->matchlist('\v\s*let\s+([sabwtgv]:)?(\w+)\W')[1 : 2]->join('')
        echom var_name

        # Remove 'let' from all the lines containing variables, with the exception of s: and
        # '' (e.g. 'let foo'). The latter because 'let foo" can be either
        # global or function scoped and must be handled in both cases
        if var_name =~ '^[bwtgv]:'
          transformed_line = transformed_line->substitute('let\s\+', '', 'g')
        endif

        # For s: you need 'var' or '' but you have to also consider possible function scopes
        # For 'let foo' you need 'g:' or 'var', depending where 'let foo' appears
        # Script scope
        if !inside_function
          if var_name =~ '^s:'
            if index(already_declared_script_local_vars, var_name) == -1
              transformed_line = transformed_line->substitute('let\s\+', 'var ', '')
              add(already_declared_script_local_vars, var_name)
            elseif index(already_declared_script_local_vars, var_name) != -1
              transformed_line = transformed_line->substitute('let\s\+', '', '')
            endif
          elseif var_name !~ '^[sabwtgv]: '
            transformed_line = transformed_line->substitute('let\s\+', 'g:', '')
          endif
        # Function scope
        else
          if var_name =~ '^s:'
            if index(already_declared_function_local_vars, var_name) == -1 && index(already_declared_script_local_vars, var_name) == -1
              transformed_line = transformed_line->substitute('let\s\+', 'var ', '')
              add(already_declared_function_local_vars, var_name)
            else
              transformed_line = transformed_line->substitute('let\s\+', '', '')
            endif
          elseif var_name !~ '^[sabwtgv]:'
            if index(already_declared_function_local_vars, var_name) == -1
              transformed_line = transformed_line->substitute('let\s\+', 'var ', '')
              add(already_declared_function_local_vars, var_name)
            else
              transformed_line = transformed_line->substitute('let\s\+', '', '')
            endif
          endif
        endif
      endif
    endif

      # Also, get rid off the old s: and a:.
      # transformed_line = transformed_line->substitute('\v(s:|a:)', '', 'g')

      # Append the transformed line to the list
      add(transformed_lines, transformed_line)
  endfor
  # echom already_declared_script_local_vars

  # Set the content of the new buffer to the transformed lines
  setbufline(new_bufnr, 1, transformed_lines)

  # Set the new buffer as the current buffer
  execute $'buffer {new_bufnr}'
enddef

# vim: sw=2 sts=2 et
