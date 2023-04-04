open! Core

module Node : sig
  type operator [@@deriving sexp_of]
  type location [@@deriving sexp_of]
  type organisation [@@deriving sexp_of]
  type attribute_id [@@deriving sexp_of]

  type attribute [@@deriving sexp_of]

  and attribute_condition =
    | Always
    | Never
    | Attribute_required of attribute
    | And of attribute_condition * attribute_condition
    | Or of attribute_condition * attribute_condition
  [@@deriving sexp_of]

  and attribute_maintainer = {
    attribute_maintainer_id : attribute_id;
    attribute_maintainer_condition : attribute_condition;
  }
  [@@deriving compare, equal, sexp_of]

  type (_, _) t =
    | Operator : operator -> (operator, operator) t
    | Location : location -> (location, organisation) t
    | Organisation : organisation -> (organisation, organisation) t
    | Attribute_maintainer :
        attribute_maintainer
        -> (attribute_maintainer, attribute_maintainer) t
    | Attribute : attribute -> (attribute, attribute_maintainer) t
  [@@deriving sexp_of]

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

module Position_tree : sig
  type t [@@deriving sexp_of]
end

module Permission_DAG : sig
  type t [@@deriving sexp_of]
end

type t = {
  name : string;
  position_tree : Position_tree.t ref;
  permission_dag : Permission_DAG.t;
}
[@@deriving sexp_of]

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

val add_permission_edge :
  t ->
  operator:(Node.operator, Node.operator) Node.t ->
  from:('a, 'b) Node.t ->
  to_:('c, 'd) Node.t ->
  t

val delete_permission_edge :
  t ->
  operator:(Node.operator, Node.operator) Node.t ->
  node:('a, 'b) Node.t ->
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
