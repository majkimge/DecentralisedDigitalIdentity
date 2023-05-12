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

let cambridge_admin = System.Node.agent "Cambridge_admin" in
let cambridge_handler =
  System.Node.attribute_handler "Cambridge_handler" Never
in
let student_attribute = System.Node.attribute "Student" Never in
let system = System.create cambridge_admin "Cambridge" in
let system =
  System.add_attribute_handler_under_agent system
    ~attribute_handler:cambridge_handler ~agent:cambridge_admin
in

let system =
  System.add_attribute system ~attribute:student_attribute
    ~attribute_handler:cambridge_handler
in
let college = System.Node.resource_handler "College" in
let college_admin = System.Node.agent "College_admin" in
let system = System.add_agent system ~agent:college_admin in
let system =
  System.add_resource_handler system ~maintainer:college_admin
    ~resource_handler:college ~parent:System.root_node
in
(* let () = print_string (Yojson.to_string (System.to_json system)) in *)
let main_site = System.Node.resource "main_site" in
let system =
  System.add_resource system main_site ~parent:college
    ~entrances:[ System.root_node ]
in
let system =
  System.grant_attribute system ~agent:cambridge_admin
    ~from:cambridge_admin ~to_:student_attribute
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
