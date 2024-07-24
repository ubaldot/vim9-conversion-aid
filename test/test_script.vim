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

        " Test on booleans
let s:one_boolean= v:true
let s:one_boolean= v:false

if s:one_boolean==v:true
    echo "foo"
endif

if exists('b:one_function')
    echom 'foo'
endif


" Test functions
" Test on variables shadowing
let shadow = 2
let s:shadow = 3
let b:shadow = 4

func! TestShadow1()
    let shadow = 3
    echom shadow
endfu

func! TestShadow2()
    let s:shadow=3
    echom s:shadow
endf

func TestShadow3(shadow)
    let s:shadow = a:shadow
    let shadow =a:shadow
    echom a:shadow
endfunc

call TestShadow3(shadow)
call TestShadow3(s:shadow)
call TestShadow3(b:shadow)

" Test script/function scopes
function PrintSomeText()
    let s:foo = false
    if false
        echom a.foo
    else
        echom A.BAR
    let b:one_buffer_var=-66
    endif
endfunc

" Define a function that takes a dictionary as an argument and prints its content
func PrintDictContent(dict) abort
    echo "Dictionary Content:"
    for [key  ,value] in items(a:dict)
        echo key . ": " . value
    endfor
    let g:one_global_var=66
endfunction

" Define a function that updates a dictionary value
function! UpdateDict(dict, key, value) abort
    let a:dict[a:key]= a:value
    let b:another_buffer_var=33
    let one_script_var ='monkey'
endfunction

" Define a function that returns a dictionary
func! CreateDict() abort
    let newdict = #{ key1: "value1", key2: "value2", }
    let newdict[g:one_global_var]= "one global"
    let s:bar = 22
    return newdict
endfunction

" Call the functions
call PrintDictContent(mydict)
call UpdateDict(mydict   , 'version', 2.0)
call PrintDictContent(mydict)

let newdict = CreateDict()
call PrintDictContent(newdict)

" Test on function() removal
let w:one_function = function('PrintDictContent')
