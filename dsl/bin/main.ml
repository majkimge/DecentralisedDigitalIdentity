open! Core
open! Dsl

let admin = System_new.Node.operator "admin"
let system = System_new.create admin
let locationA = System_new.Node.location "locationA"
let locationB = System_new.Node.location "locationB"
let locationC = System_new.Node.location "locationC"

let system =
  System_new.add_location system locationA ~parent:System_new.root_node
    ~entrances:[ System_new.root_node ]

(* let system =
     System_new.add_location system locationB ~parent:System_new.root_node
       ~entrances:[ locationA ]

   let system =
     System_new.add_location system locationC ~parent:System_new.root_node
       ~entrances:[ locationB ] *)
;;

print_s [%sexp (system : System_new.t)]
