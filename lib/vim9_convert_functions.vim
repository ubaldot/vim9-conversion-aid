vim9script

export def TransformBuffer(...bufnr: list<string>)

  var fix_let = get(g:, 'vim9_conversion_aid_fix_let', false)
  var fix_asl = get(g:, 'vim9_conversion_aid_fix_asl', false)

  var source_bufnr = bufnr('%')
  if empty(source_bufnr)
    source_bufnr = bufnr(bufnr[0])
  endif

  vnew
  setlocal filetype=vim
  # UBA
  # setlocal bufhidden=wipe
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
  var comparison_operators_regex = '(\=[\=\~]?|!\=|\<\=|\>\=|\<|\>|!\~)'

  for line in source_lines
    # Comments " -> #
    transformed_line = line ->substitute('^\s*"', (m) => $'{m[0][: -2]}#', 'g')

    if !(transformed_line =~ '^\s*#')
      transformed_line = transformed_line
        # Replace all occurrences of 'func', etc. with 'def', etc
        ->substitute('^\s*fu\l*[!]\?\s', 'def ', '')
        ->substitute(')\s*\(abort\|range\|dict\)', ')', '')
        # 'endf'  can be the leading part of both 'endfunc' and 'endfor'
        ->substitute('\(^\s*\)endf\l*', (m) => m[0] =~ 'endfor' ? m[1] .. 'endfor' : m[1] .. 'enddef', '')
        # Remove all occurrences of 'call'
        ->substitute('cal[l]\?\s', '', '')
        # Replace '#{' with '{' for dictionaries
        ->substitute('#{', '{', 'g')
        # Remove function('') for funcref
        ->substitute('\vfunction\([''"](\w*)[''"]\)', '\1', '')

        # Leading and trailing white-space around comparison operators and '='
        # If you already have a space, it will add another one. Hence, you remove
        # the extra spaces with the next two substitute functions
        ->substitute($'\v{comparison_operators_regex}([#?]?)', ' \0 ', '')
        ->substitute($'\v{comparison_operators_regex}([#?]?)\s\s', '\1\2 ', '')
        ->substitute($'\v\s\s{comparison_operators_regex}([#?]?)', ' \1\2', '')

        # Trailing space AND no leading space for [:,]
        # TODO: It replaces only the first match
        ->substitute('\v([,:])(\S)', '\1 \2', 'g')
        ->substitute('\v\s*([,:])', '\1', 'g')
        # Surrounding space between : in brackets[1:3] => [1 : 3]
        # I assumes that what is inside a list is a \w* and not a \S*
        ->substitute('\v\[\s*(\S+)\s*:\s*(\S+)\s*\]', '[\1 : \2]', '')
        # String concatenation
        ->substitute('\s\+\.\s\+', ' \.\.\ ', 'g')
        # Remove line continuation
        ->substitute('\v(^\s*)\\', '\1', '')
        # Replace v:true, v:false with true, false
        ->substitute('\vv:\s(true|false)', '\1', 'g')
    endif

    # Re-compact b: w: t: g: v: a:, s: e.g. from 'b : foo' to 'b:foo'.
    transformed_line = transformed_line->substitute('\(\W\|^\)\([asbwtgvl]\)\s*:\s*', '\1\2:', 'g')


    # ------------------------ let management ---------------------------

    if fix_let
      if transformed_line =~ '^def'
        inside_function = true
      elseif transformed_line =~ '^enddef'
        inside_function = false
        already_declared_function_local_vars = []
      endif

      if transformed_line =~ '^\s*let\s'
        # Store variable name without 'let'.
        var var_name = transformed_line->matchlist('\v\s*let\s+([sabwtgvl]:)?(\w+)\W')[1 : 2]->join('')
        # echom var_name

        # Remove 'let' from all the lines containing variables, with the exception of s:, l: and
        # '' (e.g. 'let foo'). The latter because 'let foo" can be either
        # global or function scoped and must be handled in both cases
        if var_name =~ '^[bwtgv]:'
          transformed_line = transformed_line->substitute('let\s\+', '', 'g')
        endif

        # For s: you need 'var' or '' but you have to also consider possible function scopes
        # For 'let foo' you need 'g:' or 'var', depending where 'let foo' appears
        # Script scope
        if !inside_function
          if var_name =~ '\v^(s:|l:)'
            if index(already_declared_script_local_vars, var_name) == -1
              transformed_line = transformed_line->substitute('let\s\+', 'var ', '')
              add(already_declared_script_local_vars, var_name)
            elseif index(already_declared_script_local_vars, var_name) != -1
              transformed_line = transformed_line->substitute('let\s\+', '', '')
            endif
          elseif var_name !~ '^[sabwtgvl]: '
            transformed_line = transformed_line->substitute('let\s\+', 'g:', '')
          endif
        # Function scope
        else
          if var_name =~ '\v^(s:|l:)'
            if index(already_declared_function_local_vars, var_name) == -1 && index(already_declared_script_local_vars, var_name) == -1
              transformed_line = transformed_line->substitute('let\s\+', 'var ', '')
              add(already_declared_function_local_vars, var_name)
            else
              transformed_line = transformed_line->substitute('let\s\+', '', '')
            endif
          elseif var_name !~ '^[sabwtgvl]:'
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


    if fix_asl
      transformed_line = transformed_line->substitute('\v(a:|l:|s:):', '', 'g')
    endif

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
