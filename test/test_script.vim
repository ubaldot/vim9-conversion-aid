" Define a dictionary with the #{ } syntax
let mydict= #{}

" Add key-value pairs to the dictionary
let mydict.name = "Vim Script Example"
let mydict.version = 1.0

let mydict['name']= "Vim Script Example"

" Test on random variables defined/updated in a in a messy layout
let   foo= 'potato'

let   s:bar ='banana'
let s:bar='strawberry'

   let g:one_global_var =1
let s:one_list=[-1,2,3,4,5,6  ,4   ,   5   , 6,  3,2,3,4,5,6,4,3,3,4,58,7]
let g:one_list_slice=s:one_list[7:12]
let s:one_const = 2
let s:one_list[0] = s:one_const
let   g:one_list_slice=s:one_list[s:one_const  :    9]

let   one_script_var='name'
let b:one_buffer_var=-99

echom v:args

" Test leading-trailing white-space around comparison operators
echom s:bar=='blueberry'
echom s:bar==# 'blueberry'
echom s:bar ==?'blueberry'
echom s:bar!='blueberry'
echom s:one_list[3] >? s:one_list[4]
echom s:one_list[3]<=s:one_list[4]
echom foo=~?'carot'
echom foo=~ 'carot'
echom foo !~#'carot'

 " Test on line continuation
let another_dict={'foo'             :   'FOO' , 'bar':s:bar,
            \ 'baz' :'BAZ'}


if exists('b:one_function')
    echom 'foo'
endif

" Test functions
" Test on variables shadowing
let shadow = 2
let s:shadow = 3
let b:shadow = 4

func! TestShadow1() range
    let shadow = 3
    echom shadow
endfu

funct! TestShadow2()
    let s:shadow=3
    echom s:shadow
endf

fu TestShadow3(shadow) abort
    let s:shadow = a:shadow
    let shadow =a:shadow
    echom a:shadow
endf

call TestShadow3(shadow)
call TestShadow3(s:shadow)
call TestShadow3(b:shadow)

" Test script/function scopes
function BooleanChange()
    let s:foo = v:false
    if s:foo
        let s:foo_new =v:true
    else
        let s:foo_new =v:false
    endif
    echo s:foo_new
endfunc

fu! ReassignSomeVars1()
    let g:one_global_var=66
    let one_script_var ='monkey'
    let l:one_local_var='dog'
    let l:one_local_var='kitten'
    echo 'Vars reassigned'
endfu

func! ReassignSomeVars2(newdict)
    if s:foo
      let b:another_buffer_var=33
    endif
    let l:one_local_var='elephant'
    let l:one_local_var ='tiger'
    let s:bar ='donkey'
    let s:bar= 'cow'
    let a:newdict[g:one_global_var]= "one global"
    echo 'Vars reassigned (2)'
endfu

" Define a function that takes a dictionary as an argument and prints its content
func PrintDictContent(dict) abort
    echo "Dictionary Content:"
    for [key  ,value] in items(a:dict)
        echo key . ": " . value
    endfor
endfunction

" Define a function that updates a dictionary value
function! UpdateDict(dict, key, value) abort
    let a:dict[a:key]= a:value
endfunction

" Define a function that returns a dictionary
func! CreateDict() abort
    let newdict = #{ key1: "value1", key2: "value2", }
    return newdict
endfunction

" Call the functions
call PrintDictContent(mydict)
call UpdateDict(mydict   , 'version', 2.0)
call PrintDictContent(mydict)

let newdict = CreateDict()
call PrintDictContent(newdict)

cal ReassignSomeVars1()
cal ReassignSomeVars2(newdict)


" Test on function() removal
let w:one_function = function('PrintDictContent')
