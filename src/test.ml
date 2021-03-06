let bool = <Bool>


(*************************************************
*                                                *
*           IMPLICITLY ANNOTATED VERSIONS        *
*                                                *
**************************************************)   


let lnot = fun a ->
  if a is True then false else true

let lor = fun a -> fun b ->
  if a is False then if b is False then false else true else true

let land = fun a -> fun b ->
  if a is True then if b is False then false else true else false

let test_1 = fun x -> fun y ->
  if land (lor x (lnot x)) (lor (lnot y) y) then true else false

let is_int = fun x -> if x is Int then true else false

let is_bool = fun x -> if x is Bool then true else false




(*************************************************
*                                                *
*           EXPLICITLY ANNOTATED VERSIONS        *
*                                                *
**************************************************)   


debug let lnot = fun (a : Any) ->
  if a is True then false else true

let lor = fun (a : Any) -> fun (b : Any) ->
  if a is False then if b is False then false else true else true

let land = fun (a : Any) -> fun (b : Any) ->
  if a is True then if b is False then false else true else false

let test_1 = fun (x:Any) -> fun (y:Any) ->
  if land (lor x (lnot x)) (lor (lnot y) y) then true else false

let is_int = fun (x:Any) -> if x is Int then true else false
let is_bool = fun (x:Any) -> if x is Bool then true else false

(************************)
(* Various simple tests *)
(************************)

let test_2 = fun (x:Any) ->
  lor (is_int x) (is_bool x)

let test_3 = fun (b:Bool) -> lor b bool

let bool_id = fun ((True -> True) & (False -> False)) x -> x

let succ = fun (x:Int) -> x

let test_4 = fun x -> if x is Bool then x else x

let test_5 = fun x -> if x is Bool then bool_id x else succ x

let custom_id = fun ((0--1 -> 0--1) & (1--2 -> 1--2)) x -> x

let test_6 = fun x ->
  let y = custom_id x in
  if y is 1 then true else false


(************************************)
(* Examples from the previous paper *)
(* the one submitted at SciComPro   *)
(************************************)

let (+) = <Int -> Int -> Int>

let two_steps =
  let f = fun (( Any\Int -> (Any, Any)\(Int,Int) ) & ( Int -> (Int,Int) )) x -> magic
  in
  fun x ->
    if snd (f x) is Int
    then
      if fst (f x) is Int then x
      else 0
    else 0


let plus = <Int->Int->Int>
let bti = <Bool->Int>
let incr = <Int->Int>

let appl1_fail =
  fun ( ((Int -> Int) | (Bool -> Bool)) -> (Int | Bool) -> (Int | Bool)) x1 ->
    fun ( (Int | Bool) -> (Int | Bool) ) x2 ->
      if (x1 x2) is Int then plus x2 (x1 x2) else land x2 (x1 x2)

let appl1_ok =
  fun ( ((Int -> Int) & (Bool -> Bool)) -> (Int | Bool) -> (Int | Bool)) x1 ->
    fun ( (Int | Bool) -> (Int | Bool) ) x2 ->
      if (x1 x2) is Int then plus x2 (x1 x2) else land x2 (x1 x2)

let appl1_im =
  fun ( ((Int -> Int) & (Bool -> Bool)) -> (Int | Bool) -> (Int | Bool)) x1 ->
    fun x2 ->
      if (x1 x2) is Int then plus x2 (x1 x2) else land x2 (x1 x2)

let appl2 =
  let bti =
    fun (Bool -> Int) b -> magic
  in
  fun ( ( (Int|Char -> Int) | (Bool|Char -> Bool) ) -> Char -> Int) x1 ->
    fun (Char -> Int) x2 ->
      if (x1 x2) is Int then incr (x1 (x1 x2)) else bti (x1 (x1 x2))

let appl2_im =
  let bti =
    fun (Bool -> Int) b -> magic
  in
  fun ( ( (Int|Char -> Int) | (Bool|Char -> Bool) ) -> Char -> Int) x1 ->
    fun  x2 ->
      if (x1 x2) is Int then incr (x1 (x1 x2)) else bti (x1 (x1 x2))

(* Examples on records *)

let records_fail =
  let destruct = fun ({id=Int} -> Int) x -> x.id in
  let record = { id=0, name='a' } in
  destruct record

let records_ok =
  let destruct = fun ({id=Int ..} -> Int) x -> x.id in
  let record = {id=0, name='a'} in
  destruct record

(* Must fail because we do not know whether x has a field a *)
let records_fail2 =
  fun ({..} -> Any) x ->
    if {x with a=0} is {a=Int ..} then x.a else 0

(*
  This should work because x\a is of type  {b=Int ..} since
  it is of type {b=Int a=?Empty, ..} which is a subtype of
  {b=Int ..}
*)
let records_ok1 =
  fun ({b = Int ..} -> Int) x ->
    if x\a is {b=Int ..} then x.b else x.c

(*
   This should fail since  x\a is of type  {b=Int a=?Empty ..}
   which is a subtype of {b=Int ..} = {b=Int a=?Any ..}
*)
let records_fail1 =
  fun ({b = Int ..} -> Int) x ->
    if x\a is {b=Int ..} then x.c else 0


(*  This should also fail for the same reasons as above *)
let records_fail1bis =
  fun ({b = Int ..} -> Int) x ->
    if x\a is {b=Int, a=?Empty ..} then x.c else 0

let records_ok2 =
  let x = { flag=true } in
  {x with id=10}

let records_ok3 =
  let x = { flag=true, id=10 } in
  x\flag

let records_ok4 =
  fun x ->
    if {x with a=0} is {a=Int ..} then true else false

let w = {b = 3, c=4}\l

(* Memento: we should improve the printing of types. When the
   type is closed we should not print the fields of type =?Empty
 *)

let x = <{..}>
let y = {x with a = 0}
let u = if {x with a=0} is {..} then 0 else 1
let v = if {x with a=0} is {b=?Any ..} then 0 else 1
let s = if {x with a=0} is {a=?Bool ..} then 0 else 1
let t = if {x with a=0} is {a=Int ..} then 0 else 1
let z = if {x with a=0} is {b=?Empty ..} then 0 else x.b

let records_ok5 =
  fun x ->
    if {x with a=0} is {a=Int, b=Bool ..} then true else false

let paper_example1 =
  fun x ->
    if {x with a=0} is {a=Int, b=Bool ..} | {a=Bool, b=Int ..} then true else false

let paper_example2 =
  fun x ->
    if x is {a=Int, b=Bool ..} | {a=Bool, b=Int ..} then true else false

let paper_example3 =
  fun x ->
    if x is {a=Int, b=Bool ..} | {a=Bool, b=Int ..} then x.b else false

let paper_example4 =
  fun x ->
    if {x with a=0} is {a=Int, b=Bool ..} | {a=Bool, b=Int ..} then x.b else false

let paper_example =
  fun ({..} -> Bool) x ->
    if {x with a=0} is {a=Int, b=Bool ..} | {a=Bool, b=Int ..} then x.b else false


let paper_example_implicit =
  fun  x ->
    if {x with a=0} is {a=Int, b=Bool ..} | {a=Bool, b=Int ..} then x.b else false

type Document = { nodeType=9 ..}
and NodeList = Nil | (Node, NodeList)
and Element = { nodeType=1, childNodes = NodeList ..}
and Text = { nodeType=3, isElementContentWhiteSpace=Bool ..}
and Node = Document | Element | Text

let is_empty_node_expl = fun (x : Node) ->
  if x.nodeType is 9 then false
  else if x.nodeType is 3 then x.isElementContentWhiteSpace
  else if x.childNodes is Nil then true else false

let is_empty_node_impl = fun x ->
  if x.nodeType is 9 then false
  else if x.nodeType is 3 then x.isElementContentWhiteSpace
  else if x.childNodes is Nil then true else false

(* Examples with recursive functions *)

(*
type IntList = Nil | (Int,IntList)
 and AnyList = Nil | (Any, AnyList)
 and IntTree = (Any \IntList) | Nil | (IntList,IntTree)

let concat = fun (x : AnyList) ->
              fun (y : AnyList) ->
                  if x is Nil then y else (fst x , (concat (snd x) y))

let flatten = fun x ->
  if x is Nil then true
  else if x is (Any,Any) then concat (flatten(fst x)) (flatten(snd x))
  else (x,nil)
*)

(* Test with strings *)

let typeof x =
  if x is String then "String"
  else if x is Char then "Char"
  else if x is Int then "Number"
  else if x is Bool then "Boolean"
  else if x is Unit|Nil then "Nil"
  else "Object"

let test_typeof y =
  if typeof y is "Boolean" then lnot y else false

(* Test with lists and regex *)

let hd (x:(Any, List)) = fst x
let is_empty (x:List) =
  if x is [] then true else false

let test_hd y =
  if y is List
  then if lnot (is_empty y) then hd y
  else nil else 0

let various = [0; "ML"; nil]
let various_fun (x:[Int ; String ; List]) = fst (snd x)
let various_test = various_fun various

let regex (x: [ Int -> Bool ; Bool* ; Int? ; String+ ]) = 0

(* Test prefix/infix operators *)

let (+) = <(Int -> Int -> Int)>
let (-) = <Int -> Int -> Int>
let ( * ) = <Int -> Int -> Int>
let (/) = <Int -> Int -> Int>
let (=) = <Int -> Int -> Bool>
let (!) = <Bool -> Bool> (* Operators starting with ? or ! are prefix *)

let infix_test (x:Int) (y:Bool) = land (! (((1*x) - 3) = 6)) y

(* Nouveaux examples *)

let concat = < String -> String -> String>
let to_string = <Any -> String>

let add x y =
    if x is Int then
        if y is Int then x + y
        else concat (to_string x) y
    else if y is String then concat (to_string x) y
    else concat (to_string x) (to_string y)

atom a
atom b
atom c
atom d
atom e

type S2 = A | B
type S1 = E | (C,(S2,S2)) |  (D,(S1,S1))

let g = <((E -> A) & ((S1\E) -> B)) >


let f v =
  if v is (C,(Any,Any)) then (c , ( fst(snd v) , fst(snd v) )) else
  if v is (D,(Any,Any)) then (c , ( g(fst(snd v)) , g(fst(snd v)) )) else
  if v is E then v else nil

(*

let f (g : ((<e>[] -> <a>[]) & ((S1\<e>[]) -> <b>[]))) (v : S1) : (S1 \ (<c>[<a>[] <b>[]])) =
  match v with
  | <c>[ (x & <a>[] ) _ ] -> <c> [ x x ]
  | <c>[ x _ ] -> <c>[ x x ]
  | <d>[ (x & <e>[]) _ ] -> <c> [ (g x) (g x) ]
  | <d>[ x _ ] ->  <c> [ (g x) (g x) ]
  | <e>[] -> <e>[]
  ;;
 *)



(*************************************************
*          Tobin-Hochstadt & Felleisen           *
*     exampleX = EXPLICITLY ANNOTATED VERSIONS   *
*     implictX = IMPLICITLY ANNOTATED VERSIONS   *
*                                                *
**************************************************)

(*
 Interesting points:
  - example2: does not need the annotation, while TH&F yes
  - example6: not typable with the annotation Int|String
    (as expected), but if we remove annotations becomes typable. 
    That is our system finds the right constraints to make the
    expression typable
  - in examples 10 11 12 we do not have to assume that p is
    a product the system deduces it alone
  - same for the example 14. We do not have to assume that
    the parameter input is Int|String and extra is a pair. The system
    finds it alone and it works for user defined "and"
    (currified or not)
*)

(* prelude *)

atom no

let and_ = fun x -> fun y -> 
     if x is True then if y is True then y else false else false

let and2_ = fun x ->
     if fst x is True then if snd x is True then fst x else false else false

let not_ = fun x -> if x is True then true else false

let or_ =  fun x -> fun y -> not_ (and_ (not_ x) (not_ y))

let is_string = fun x ->
     if x is String then true else false

let is_int = fun x ->
     if x is Int then true else false

let strlen = <(String) -> Int>

let add = <Int -> Int -> Int>

let add1 = <Int -> Int>

let f = <(Int | String) -> Int>

let g = <(Int, Int) -> Int>


(* Examples Tobin-Hochstadt & Felleisen *)

let example1 = fun (x:Any) ->
  if x is Int then add1 x else 0

let implict1 = fun x ->
  if x is Int then add1 x else 0


let example2 = fun (x:String|Int) ->
  if x is Int then add1 x else strlen x

let implict2 = fun x ->
  if x is Int then add1 x else strlen x


let example3 = fun (x: Any) ->
  if x is (Any \ False) then (x,x) else false

let implict3 = fun x ->
  if x is (Any \ False) then (x,x) else false


let example4 = fun (x : Any) ->
  if or_ (is_int x) (is_string x) is True then x else 'A'

let implict4 = fun x ->
  if or_ (is_int x) (is_string x) is True then x else 'A'


let example5 = fun (x : Any) -> fun (y : Any) ->
  if and_ (is_int x) (is_string y) is True then
   add x (strlen y) else 0

let implict5 = fun x -> fun y ->
  if and_ (is_int x) (is_string y) is True then
   add x (strlen y) else 0


let example6 = fun (x : Int|String) -> fun (y : Any) ->
  if and_ (is_int x) (is_string y) is True then
   add  x (strlen y) else strlen x

let implict6 = fun x -> fun y ->
  if and_ (is_int x) (is_string y) is True then
   add  x (strlen y) else strlen x


let example7 = fun (x : Any) -> fun (y : Any) ->
  if  (if (is_int x) is True then (is_string y) else false) is True then
   add x (strlen y) else 0

let implict7 = fun x -> fun y ->
  if  (if (is_int x) is True then (is_string y) else false) is True then
   add x (strlen y) else 0


let example8 = fun (x : Any) -> 
  if or_ (is_int x) (is_string x) is True then true else false

let implict8 = fun x -> 
  if or_ (is_int x) (is_string x) is True then true else false


let example9 = fun (x : Any) ->
  if
   (if is_int x is True then is_int x else is_string x)
   is True then  f x else 0

let implict9 = fun x  ->
  if
   (if is_int x is True then is_int x else is_string x)
   is True then  f x else 0


let example10 = fun (p : (Any,Any)) ->
  if is_int (fst p) is True then add1 (fst p) else 7

let implict10 = fun p ->
  if is_int (fst p) is True then add1 (fst p) else 7


let example11 = fun (p : (Any, Any)) ->
  if and_ (is_int (fst p)) (is_int (snd p)) is True then g p else no

let implict11 = fun p ->
  if and_ (is_int (fst p)) (is_int (snd p)) is True then g p else no


let example12 = fun (p : (Any, Any)) -> 
  if is_int (fst p) is True then true else false

let implict12 = fun p -> 
  if is_int (fst p) is True then true else false


let example13 =
 fun (x : Any) ->
   fun (y : Any) ->
    if and_ (is_int x) (is_string y) is True then 1
    else if is_int x is True then 2
    else 3

let implict13 =
 fun x ->
   fun y ->
    if and_ (is_int x) (is_string y) is True then 1
    else if is_int x is True then 2
    else 3


(* uncurried "and" *)
let example14 = fun (input : Int|String) ->
fun (extra : (Any, Any)) ->
 if and2_(is_int input , is_int(fst extra)) is True then
     add input (fst extra)
 else if is_int(fst extra) is True then
     add (strlen input) (fst extra)
 else 0

let implct14a = fun (input : Int|String) ->
fun extra ->
 if and2_(is_int input , is_int(fst extra)) is True then
     add input (fst extra)
 else if is_int(fst extra) is True then
     add (strlen input) (fst extra)
 else 0

let implct14b = fun input ->
fun extra ->
 if and2_(is_int input , is_int(fst extra)) is True then
     add input (fst extra)
 else if is_int(fst extra) is True then
     add (strlen input) (fst extra)
 else 0

(* curried "and" *)
let curried14 = fun (input : Int|String) ->
fun (extra : (Any, Any)) ->
 if and_ (is_int input) (is_int(fst extra)) is True then
     add input (fst extra)
 else if is_int (fst extra) is True then
     add (strlen input) (fst extra)
 else 0

let currid14a = fun (input : Int|String) ->
fun extra ->
 if and_ (is_int input) (is_int(fst extra)) is True then
     add input (fst extra)
 else if is_int (fst extra) is True then
     add (strlen input) (fst extra)
 else 0

let currid14b = fun input ->
fun extra ->
 if and_ (is_int input) (is_int(fst extra)) is True then
     add input (fst extra)
 else if is_int (fst extra) is True then
     add (strlen input) (fst extra)
 else 0






(***************************
 *                         *
 * CODE NEW PAPER \/-Elim  *
 *                         *
 ***************************)

(* Code 1 from the submission *)

let is_int = fun x ->
  if x is Int then true else false

let is_bool = fun x ->
  if x is Bool then true else false

(* Code 2 from the submission *)

let not_ = fun x ->
  if x is True then false else true

let and_ = fun x -> fun y ->
  if x is True then if y is True
  then true else false
  else false

let or_ = fun x -> fun y ->
  not_ ( and_ ( not_ x ) ( not_ y ))
(* Code 3 from  the submission *)

let strlen = <(String -> Int)>
let (+) = <(Int -> Int -> Int)>


let and_ = fun x -> fun y ->
  if x is True then if y is True
  then true else false
  else false

let is_int = fun x ->
  if x is Int then true else false  

let example14 =
  fun input -> fun extra ->
  if and_ ( is_int input ) ( is_int ( fst extra )) is True
  then input + ( fst extra )
  else if is_int ( fst extra ) is True
  then ( strlen input ) + ( fst extra )
  else 0
(* Code 4 from the submission *)

let strlen = <(String -> Int)>
let (+) = <(Int -> Int -> Int)>

let and_ = fun x -> fun y ->
  if x is True then if y is True
  then true else false
  else false

let is_int = fun x ->
  if x is Int then true else false  

let is_string = fun x ->
  if x is String then true else false  
  
let example6_wrong =
  fun (x : Int | String ) -> fun ( y : Any ) ->
  if and_ (is_int x) (is_string y) is True 
  then x + (strlen y) else strlen x

let example6_ok =
  fun x -> fun y ->
  if and_ (is_int x) (is_string y) is True 
  then x + (strlen y) else strlen x
(* Code 5 from the submission *)

let (<) = <( Int -> Int -> Bool )>
let (=) = <( Any -> Any -> Bool )>

let detailed_ex =
  fun (a : ( Int -> ( Int | Bool ))
  |( Int , ( Int | Bool ))) ->
  fun (n : Int ) ->
  if a is ( Int , Int ) then ( fst a )=( snd a )
  else if a is ( Any , Any ) then snd a
  else if (a n) is Int then ( a n ) < 42
  else a n


(*************************************
 *                                   *
 * Variations for NEW PAPER \/-Elim  *
 *                                   *
 *************************************)


let a = <(Int -> (Int|Bool)) | ( Int, (Int|Bool))>
let n = <Int>

let example_new_paper =
  if a is (Int,Int) then ((fst a)=(snd a))
  else if a is (Any,Any) then (snd a)
  else if (a n) is Int then ((a n) = 42)
  else (a n)

(* We add explicit lambda abstractions *)
let example_new1 =
fun (a : (Int -> (Int|Bool)) | ( Int, (Int|Bool))) ->
fun n ->
  if a is (Int,Int) then ((fst a)=(snd a))
  else if a is (Any,Any) then (snd a)
  else if (a n) is Int then ((a n) =  42)
  else (a n)

(* Tr??s int??ressant ... il trouve ce type surcharg??

  ((Int -> Bool | Int) -> Int -> Bool)
& ((Int,Bool | Int) -> Any -> Bool) 

  c-a-d ca marche avec Any seulement si c'est un produit
*)


(* We force n to be an integer in the second branching *)

(* let's make + work with Booleans *)
let (+) = <(Int -> Int -> Int)&(Bool -> Bool -> Bool)>

let example_new2 =
fun (a : (Int -> (Int|Bool)) | ( Int, (Int|Bool))) ->
fun n ->
  if a is (Int,Int) then ((fst a)=(snd a))
  else if a is (Any,Any) then ((snd a)+(n = 42))
  else if (a n) is Int then ((a n) =  42)
  else (a n)

(* And now I swap the arguments of the equality *)

let example_new2swap =
fun (a : (Int -> (Int|Bool)) | ( Int, (Int|Bool))) ->
fun n ->
  if a is (Int,Int) then ((fst a)=(snd a))
  else if a is (Any,Any) then ((snd a)+(42 = n))
  else if (a n) is Int then ((a n) =  42)
  else (a n)

(* The same but with a curried and_ *)

let example_new3 =
fun (a : (Int -> (Int|Bool)) | ( Int, (Int|Bool))) ->
fun n ->
  if a is (Int,Int) then ((fst a)=(snd a))
  else if a is (Any,Any) then (and_ (snd a) (n = 42))
  else if (a n) is Int then ((a n) =  42)
  else (a n)



(**************************
 *                        *
 *  Fix-point combinator  *
 *                        *
 **************************)

type Input = [Int]  (* Any   *)
and Output = [Bool] (* Empty *)

type X = X -> Input -> Output

let fixpoint = fun (((Input -> Output) -> Input -> Output ) -> (Input -> Output)) f ->
      let delta = fun ( X -> (Input -> Output) ) x ->
         f ( fun (Input -> Output) v -> ( x x v ))
       in delta delta

(* with less annotations *)
let fixpoint2 = fun (f:((Input -> Output) -> Input -> Output )) ->
      let delta = fun ( x: X )  ->
         f ( fun  v -> ( x x v ))
       in delta delta

let id = fun ((Input -> Output) -> (Input -> Output)) x -> x

let diverge = fixpoint id

let fac1 =  fun ((Int -> Int) -> (Int -> Int)) f ->
  fun (Int -> Int) x -> if x is (0--1) then 1 else x * (f(x-1))

let fac2 =  fun (f : Int -> Int) ->
  fun (x : Int) -> if x is 0 then 1 else x * (f(x-1))

let fac3 =  fun (f : Int -> Int) ->
  fun x -> if x is 0 then 1 else x * (f(x-1))

(*let factorial = fixpoint fac3*)




(**************************
 *                        *
 *     Misc examples      *
 *                        *
 **************************)

let typeable_in_racket =
  let id = fun x -> x in
  (id 42) + 3

let how_to_type_that =
  let snd_ = fun x -> (fun y -> y) in
  (snd_ 0 42) + 1 
(* becomes
bind snd = lambda x. lambda y. y in
bind aux1 = snd 0 in
bind aux2 = aux1 42 in
bind aux3 = aux2 + 1
*)


let how_to_type_that_harder =
  let snd_ = fun x -> (fun y -> y) in
  (snd_ true ( snd_ 42 3) ) + (snd_ "ok"  3)

(* function types for parameters cannot be inferred *)

let negate_fail = fun f -> (fun x -> lnot (f x))
let negate2_fail = fun (f:Empty->Any) -> (fun x -> lnot (f x))

(* Explicit type annotations cannot be shrinked *)

let succ_ok = fun x -> x + 1
let succ_fail = fun (x : Any) -> x + 1



(* test to check whether we need a rule [AbsUnion] *)

let test_abs_union =
  let id = fun x -> x in
  if bool then succ (id 0) else lnot (id false)

(*let benchmark =
  let id = fun x -> x in
  ((id 0) + 42, (id 1) + 42, (id 2) + 42, (id 3) + 42, (id 4) + 42)*)

let f = <(Int -> Int) & (Bool -> Bool)>

let test_that_should_need_abs_union_but_actually_seems_not =
  let id = fun x -> x in
  let x = id 0 in
  f x

(* Kind of bug? *)



let f = <(Any\Int -> (Any\Int, Any\Int) ) & ( Int -> (Int,Int) )>
let f = <(Any\Int -> (Any, Any)\(Int,Int) ) & ( Int -> (Int,Int) )>

(*
let dummy = <Any\Int>

let f = fun x ->
     if x is Int then (x,x)
     else (dummy,x)
*)

let two_steps_ok1 =
  fun x ->
    if snd (f x) is Int
    then (fst (f x))
    else x

let two_steps_not1 =
  fun x ->
    if snd (f x) is Int
    then (fst (f x)) + 1
    else x

let two_steps_not2 =
  fun x ->
    if snd (f x) is Int
    then (fst (f x)) + x
    else x


(*************************************

        TypeScript 4.4b examples  

 *************************************)

let toUpperCase = <String -> String>

let new_typescript_foo = fun arg ->
  let argIsString = 
    if arg is String then 
      true 
    else 
      false 
    in
  if argIsString is True then 
    toUpperCase arg
  else
    42

let ( ** ) = <Int -> Int -> Int>   
                              
(* 
   explicitly typed version of the area function 
   the deduced type is Shape -> Int 
*)
                              
type Shape =
      { kind = "circle", radius = Int }
    | { kind = "square", sideLength = Int }

let area = fun (shape: Shape) ->
    let isCircle = if shape.kind is "circle" then true else false in
    if isCircle is True then
      (* We know we have a circle here! *)
        (shape.radius) ** 7 
    else 
      (* We know we're left with a square here! *)
        (shape.sideLength) ** 2


(* 
   implicitly typed version of area. The type deduced
   by our system is equivalent to    
     { kind="circle"  radius=Int .. } 
   | { kind=(??"circle") sideLength=Int  .. }  -> Int    
*)
    
let area_implicit = fun shape ->
    let isCircle = if shape.kind is "circle" then true else false in
    if isCircle is True then
      (* We know we have a circle here! *)
        (shape.radius) ** 7 
    else 
      (* We know we're left with a square here! *)
        (shape.sideLength) ** 2

    
(* 
  explicitly-typed version of the function f 
  The type deduced for the function is:
  (Bool -> Bool) &
  (String -> String ) &
  (Int -> Int)
*)                   

let typescript_beta_f =  fun (x : String | Int | Bool) ->
  let isString = if typeof x is "String" then true else false in
  let isNumber = if typeof x is "Number" then true else false in
  let isStringOrNumber =  or_ isString isNumber in                                         
  if isStringOrNumber is True then x else x


(* implicitly-typed version for f. The deduced type
   is equivalent to
    (Bool -> Bool) &
    (String -> String ) &
    (Int -> Int) &
    (??(Bool???String|Int) ->  ??(Bool???String|Int)) 
*)

  
let typescript_beta_f_implicit =  fun x ->
  let isString = if typeof x is "String" then true else false in
  let isNumber = if typeof x is "Number" then true else false in
  let isStringOrNumber =  or_ isString isNumber in                                         
  if isStringOrNumber is True
    then x
    else x


(* versions without typeof *)
  
let idStringOrInt = <String | Int -> String | Int>
let idBool = <Bool -> Bool>

let new_typescript_f = fun (x : String | Int | Bool) ->
  let isString = if x is String then true else false in
  let isInt = if x is Int then true else false in
  let isStringOrInt = lor isString isInt in
  if isStringOrInt is True then
    idStringOrInt x
  else
    idBool x


let typescript_beta_f =  fun (x : String | Int | Bool) ->
  let isString = if typeof x is "String" then true else false in
  let isNumber = if typeof x is "Number" then true else false in
  let isStringOrNumber =  lor isString isNumber in                                         
  if isStringOrNumber is True then x else x

let typescript_beta_f_implicit =  fun x ->
  let isString = if typeof x is "String" then true else false in
  let isNumber = if typeof x is "Number" then true else false in
  let isStringOrNumber =  lor isString isNumber in                                         
  if isStringOrNumber is True then x else x
                                            
(*  
type RBtree = Btree | Rtree;;
type Btree = [] | <black elem=Int>[ RBtree RBtree ];;
type Rtree = <red elem=Int>[ Btree Btree ];;
type Wrongtree = Wrongleft | Wrongright;;
type Wrongleft = <red elem=Int>[ Rtree Btree ];;
type Wrongright = <red elem=Int>[ Btree Rtree ];;
type Unbalanced = <black elem=Int>([ Wrongtree RBtree ] | [ RBtree Wrongtree ])
let balance ( Unbalanced -> Rtree ; Rtree -> Rtree ; Btree\[] -> Btree\[] ;
              [] -> [] ; Wrongleft -> Wrongleft ; Wrongright -> Wrongright)
  | <black (z)>[ <red (y)>[ <red (x)>[ a b ] c ] d ]
  | <black (z)>[ <red (x)>[ a <red (y)>[ b c ] ] d ]
  | <black (x)>[ a <red (z)>[ <red (y)>[ b c ] d ] ]
  | <black (x)>[ a <red (y)>[ b <red (z)>[ c d ] ] ] ->
        <red (y)>[ <black (x)>[ a b ] <black (z)>[ c d ] ]
  | x -> x

let insert (x : Int) (t : Btree) : Btree =
let ins_aux ( [] -> Rtree ; Btree\[] -> RBtree\[]; Rtree -> Rtree|Wrongtree)
  | [] -> <red elem=x>[ [] [] ]
  | (<(color) elem=y>[ a b ]) & z ->
         if x << y then balance <(color) elem=y>[ (ins_aux a) b ]
	 else if x >> y then balance <(color) elem=y>[ a (ins_aux b) ]
	 else z
  in match ins_aux t with
     | <_ (y)>[ a b ] -> <black (y)>[ a b ]
 *)

atom blk
atom red
atom emp
  
  
type RBtree = Btree | Rtree
 and Btree = Emp | (Blk,[ Int; RBtree; RBtree ])
 and Rtree = (Red,[ Int; Btree; Btree ])
 and Wrongtree = Wrongleft | Wrongright
 and Wrongleft = (Red,[ Int ; Rtree; Btree ])
 and Wrongright = (Red,[ Int; Btree; Rtree ])
 and Unbalanced = (Blk,([ Int; Wrongtree; RBtree ] | [ Int; RBtree; Wrongtree ]))

let balance = fun (
                (Unbalanced -> Rtree)
              & (Rtree -> Rtree)
              & (Btree\Emp -> Btree\Emp) 
              & (Emp -> Emp )
              & (Wrongleft -> Wrongleft)
              & (Wrongright -> Wrongright)
  )  x -> magic

