vim9script

# Define a dictionary with the #{ } syntax
g:mydict = {}

# Add key-value pairs to the dictionary
g:mydict.name = "Vim Script Example"
g:mydict.version = 1.0

g:mydict['name'] = "Vim Script Example"

# Test on random variables defined/updated in a in a messy layout
g:foo = 'potato'

var s:bar = 'banana'
s:bar = 'strawberry'

   g:one_global_var = 1
var s:one_list = [-1, 2, 3, 4, 5, 6, 4,   5, 6,  3, 2, 3, 4, 5, 6, 4, 3, 3, 4, 58, 7]
g:one_list_slice = s:one_list[7 : 12]
var s:one_const = 2
s:one_list[0] = s:one_const
g:one_list_slice = s:one_list[s:one_const:    9]

g:one_script_var = 'name'
b:one_buffer_var = -99

echom v:args

# Test leading-trailing white-space around comparison operators
echom s:bar == 'blueberry'
echom s:bar ==# 'blueberry'
echom s:bar ==? 'blueberry'
echom s:bar != 'blueberry'
echom s:one_list[3] >? s:one_list[4]
echom s:one_list[3] <= s:one_list[4]
echom foo =~? 'carot'
echom foo =~ 'carot'
echom foo !~# 'carot'

 # Test on line continuation
g:another_dict = {'foo':   'FOO', 'bar': s:bar,
             'baz': 'BAZ'}


if exists('b:one_function')
    echom 'foo'
endif

# Test functions
# Test on variables shadowing
g:shadow = 2
var s:shadow = 3
b:shadow = 4

def TestShadow1()
    var shadow = 3
    echom shadow
enddef

def TestShadow2()
    s:shadow = 3
    echom s:shadow
enddef

def TestShadow3(shadow)
    s:shadow = a:shadow
    var shadow = a:shadow
    echom a:shadow
enddef

TestShadow3(shadow)
TestShadow3(s:shadow)
TestShadow3(b:shadow)

# Test script/function scopes
def BooleanChange()
    var s:foo = false
    if s:foo
        var s:foo_new = true
    else
        s:foo_new = false
    endif
    echo s:foo_new
enddef

def ReassignSomeVars1()
    g:one_global_var = 66
    var one_script_var = 'monkey'
    var l:one_local_var = 'dog'
    l:one_local_var = 'kitten'
    echo 'Vars reassigned'
enddef

def ReassignSomeVars2(newdict)
    if s:foo
      b:another_buffer_var = 33
    endif
    var l:one_local_var = 'elephant'
    l:one_local_var = 'tiger'
    s:bar = 'donkey'
    s:bar = 'cow'
    let a:newdict[g:one_global_var] = "one global"
    echo 'Vars reassigned (2)'
enddef

# Define a function that takes a dictionary as an argument and prints its content
def PrintDictContent(dict)
    echo "Dictionary Content: "
    for [key, value] in items(a:dict)
        echo key .. ": " .. value
    endfor
enddef

# Define a function that updates a dictionary value
def UpdateDict(dict, key, value)
    let a:dict[a:key] = a:value
enddef

# Define a function that returns a dictionary
def CreateDict()
    var newdict = { key1: "value1", key2: "value2", }
    return newdict
enddef

# Call the functions
PrintDictContent(mydict)
UpdateDict(mydict, 'version', 2.0)
PrintDictContent(mydict)

g:newdict = CreateDict()
PrintDictContent(newdict)

ReassignSomeVars1()
ReassignSomeVars2(newdict)


# Test on function() removal
w:one_function = PrintDictContent
