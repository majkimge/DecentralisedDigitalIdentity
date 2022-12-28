open! Core

module Node : sig
  type operator [@@deriving sexp_of]
  type location [@@deriving sexp_of]
  type organisation [@@deriving sexp_of]
  type attribute_id [@@deriving sexp_of]
  type attribute [@@deriving sexp_of]

  module Attribute_condition : sig
    type t = Attribute_id of attribute_id | And of t * t | Or of t * t
    [@@deriving sexp_of]
  end

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
  val attribute : attribute_id -> Attribute_condition.t -> attribute t
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

(* val add_organisation : t -> Node.organisation Node.t -> inside:'a Node.t -> t *)
val add_operator : t -> operator:Node.operator Node.t -> t
(* val splice_node : t -> node:Position_tree.t -> parent:'a Node.t -> t
   val routes : t -> Node.location Node.t -> Node.location Node.t list list
   val delete_location : t -> Node.location Node.t -> t
   val add_permission_edge : t -> from:'a Node.t -> to_:'a Node.t -> t

   val add_attribute :
     t -> Node.attribute Node.t -> maintainer:Node.operator Node.t -> t

   val delete_permission : t -> from:'a Node.t -> to_:'a Node.t -> t
   val is_transition_valid : current_state:t -> new_state:t -> bool *)

val to_json : t -> Yojson.t
