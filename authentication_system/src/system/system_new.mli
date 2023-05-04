open! Core

module Node : sig
  type operator [@@deriving sexp_of]
  type location [@@deriving sexp_of]
  type organisation [@@deriving sexp_of]
  type attribute_id [@@deriving sexp_of]
  type attribute [@@deriving sexp_of]

  type attribute_condition =
    | Always
    | Never
    | Attribute_required of attribute
    | And of attribute_condition * attribute_condition
    | Or of attribute_condition * attribute_condition
  [@@deriving sexp_of]

  type attribute_maintainer
  type (_, _) t [@@deriving sexp_of]

  val attribute_id : string -> attribute_id
  val location : string -> (location, organisation) t
  val operator : string -> (operator, operator) t
  val organisation : string -> (organisation, organisation) t

  val attribute :
    string -> attribute_condition -> (attribute, attribute_maintainer) t

  val attribute_node_of_attribute :
    attribute -> (attribute, attribute_maintainer) t

  val attribute_maintainer :
    string ->
    attribute_condition ->
    (attribute_maintainer, attribute_maintainer) t

  val attribute_maintainer_node_of_attribute_maintainer :
    attribute_maintainer -> (attribute_maintainer, attribute_maintainer) t
end

type t [@@deriving sexp_of]

val create : (Node.operator, Node.operator) Node.t -> string -> t
val root_node : (Node.location, Node.organisation) Node.t

val add_location :
  t ->
  (Node.location, Node.organisation) Node.t ->
  parent:('a, 'b) Node.t ->
  entrances:(Node.location, Node.organisation) Node.t list ->
  t

val add_organisation :
  t ->
  maintainer:(Node.operator, Node.operator) Node.t ->
  organisation:(Node.organisation, Node.organisation) Node.t ->
  parent:('a, 'b) Node.t ->
  t

val add_operator : t -> operator:(Node.operator, Node.operator) Node.t -> t

val add_attribute :
  t ->
  attribute:(Node.attribute, Node.attribute_maintainer) Node.t ->
  attribute_maintainer:
    (Node.attribute_maintainer, Node.attribute_maintainer) Node.t ->
  t

val add_attribute_maintainer_under_operator :
  t ->
  attribute_maintainer:
    (Node.attribute_maintainer, Node.attribute_maintainer) Node.t ->
  operator:(Node.operator, Node.operator) Node.t ->
  t

val add_attribute_maintainer_under_maintainer :
  t ->
  attribute_maintainer:
    (Node.attribute_maintainer, Node.attribute_maintainer) Node.t ->
  attribute_maintainer_maintainer:
    (Node.attribute_maintainer, Node.attribute_maintainer) Node.t ->
  t

val grant_attribute :
  t ->
  operator:(Node.operator, Node.operator) Node.t ->
  from:(Node.operator, Node.operator) Node.t ->
  to_:('c, Node.attribute_maintainer) Node.t ->
  t

val grant_access :
  t ->
  operator:(Node.operator, Node.operator) Node.t ->
  from:(Node.operator, Node.operator) Node.t ->
  to_:('c, Node.organisation) Node.t ->
  t

val automatic_permission :
  t ->
  operator:(Node.operator, Node.operator) Node.t ->
  from:(Node.attribute, Node.attribute_maintainer) Node.t ->
  to_:('c, Node.organisation) Node.t ->
  t

val revoke_attribute :
  t ->
  operator:(Node.operator, Node.operator) Node.t ->
  from:(Node.operator, Node.operator) Node.t ->
  to_:('c, Node.attribute_maintainer) Node.t ->
  t

val revoke_access :
  t ->
  operator:(Node.operator, Node.operator) Node.t ->
  from:(Node.operator, Node.operator) Node.t ->
  to_:('c, Node.organisation) Node.t ->
  t

val revoke_automatic_permission :
  t ->
  operator:(Node.operator, Node.operator) Node.t ->
  from:(Node.attribute, Node.attribute_maintainer) Node.t ->
  to_:('c, Node.organisation) Node.t ->
  t

val move_operator :
  t ->
  operator:(Node.operator, Node.operator) Node.t ->
  to_:('a, 'b) Node.t ->
  t
(*
    val routes : t -> (Node.location, Node.organisation) Node.t -> (Node.location, Node.organisation) Node.t list list
    val delete_location : t -> (Node.location, Node.organisation) Node.t -> t
*)

val get_attribute_by_id : t -> Node.attribute_id -> Node.attribute

val get_attribute_maintainer_by_id :
  t -> Node.attribute_id -> Node.attribute_maintainer

val to_json : t -> Yojson.t
