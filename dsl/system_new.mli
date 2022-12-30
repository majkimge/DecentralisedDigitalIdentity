open! Core

module Node : sig
  type operator [@@deriving sexp_of]
  type location [@@deriving sexp_of]
  type organisation [@@deriving sexp_of]
  type attribute_id [@@deriving sexp_of]

  type attribute [@@deriving sexp_of]

  and attribute_condition =
    | Attribute_required of attribute
    | And of attribute_condition * attribute_condition
    | Or of attribute_condition * attribute_condition
  [@@deriving sexp_of]

  val attribute_id : operator -> string -> attribute_id

  type _ t =
    | Operator : operator -> operator t
    | Location : location -> location t
    | Organisation : organisation -> organisation t
    | Attribute : attribute -> attribute t
  [@@deriving sexp_of]

  val location : string -> location t
  val operator : string -> operator t
  val organisation : string -> organisation t
  val attribute : attribute_id -> attribute_condition -> attribute t
end

module Position_tree : sig
  type t [@@deriving sexp_of]

  (* val splice_node : root:t -> node:t -> parent:'a Node.t -> t *)
end

module Permission_DAG : sig
  type t [@@deriving sexp_of]
end

type t = {
  position_tree : Position_tree.t ref;
  permission_dag : Permission_DAG.t;
}
[@@deriving sexp_of]

val create : Node.operator Node.t -> t
val root_node : Node.location Node.t

val add_location :
  t ->
  Node.location Node.t ->
  parent:'a Node.t ->
  entrances:Node.location Node.t list ->
  t

val add_organisation :
  t ->
  maintainer:Node.operator Node.t ->
  organisation:Node.organisation Node.t ->
  parent:'a Node.t ->
  t

val add_operator : t -> operator:Node.operator Node.t -> t
val add_attribute : t -> attribute:Node.attribute Node.t -> t

val add_permission_edge :
  t ->
  operator:Node.operator Node.t ->
  from:Node.operator Node.t ->
  to_:'a Node.t ->
  unit

val delete_permission_edge :
  t -> operator:Node.operator Node.t -> node:'a Node.t -> unit

val move_operator : t -> operator:Node.operator Node.t -> to_:'a Node.t -> t
(* val splice_node : t -> node:Position_tree.t -> parent:'a Node.t -> t
   val routes : t -> Node.location Node.t -> Node.location Node.t list list
   val delete_location : t -> Node.location Node.t -> t
   val add_permission_edge : t -> from:'a Node.t -> to_:'a Node.t -> t



   val delete_permission : t -> from:'a Node.t -> to_:'a Node.t -> t
   val is_transition_valid : current_state:t -> new_state:t -> bool *)

val to_json : t -> Yojson.t
