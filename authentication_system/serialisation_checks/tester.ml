open! Core
open Authentication_system

type t = { value : int; refs : t ref list } [@@deriving bin_io, sexp]
type z = Z : z
type 'n s = S : 'n -> 'n s

type ('a, _) b_tree =
  | Leaf : ('a, z) b_tree
  | Node : ('a, 'n) b_tree * 'a * ('a, 'n) b_tree -> ('a, 'n s) b_tree

let top : type a n. (a, n s) b_tree -> a = function Node (_, v, _) -> v

type tree = AnyTree : ('a, 'n) b_tree -> tree;;

let cambridge_admin = System_new.Node.operator "Cambridge_admin" in
let cambridge_handler =
  System_new.Node.attribute_maintainer "Cambridge_handler" Never
in
let student_attribute = System_new.Node.attribute "Student" Never in
let system = System_new.create cambridge_admin "Cambridge" in
let system =
  System_new.add_attribute_maintainer_under_operator system
    ~attribute_maintainer:cambridge_handler ~operator:cambridge_admin
in

let system =
  System_new.add_attribute system ~attribute:student_attribute
    ~attribute_maintainer:cambridge_handler
in
let college = System_new.Node.organisation "College" in
let college_admin = System_new.Node.operator "College_admin" in
let system = System_new.add_operator system ~operator:college_admin in
let system =
  System_new.add_organisation system ~maintainer:college_admin
    ~organisation:college ~parent:System_new.root_node
in
(* let () = print_string (Yojson.to_string (System_new.to_json system)) in *)
let main_site = System_new.Node.location "main_site" in
let system =
  System_new.add_location system main_site ~parent:college
    ~entrances:[ System_new.root_node ]
in
let system =
  System_new.grant_attribute system ~operator:cambridge_admin
    ~from:college_admin ~to_:student_attribute
in
system
;;

[ AnyTree (Node (Leaf, 1, Leaf)); AnyTree Leaf ]

let execute () =
  let a = ref { value = 1; refs = [] } in
  let b = ref { value = 2; refs = [ a ] } in
  let () = a := { value = 3; refs = [ b ] } in
  let c = (Marshal.from_channel (In_channel.create "system_test") : t) in
  print_s [%message (!(List.hd_exn !(List.hd_exn c.refs).refs).value : int)]
;;

execute ()
