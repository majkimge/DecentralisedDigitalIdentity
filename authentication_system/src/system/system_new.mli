open! Core

module Node : sig
  type agent [@@deriving sexp_of]
  type resource [@@deriving sexp_of]
  type resource_handler [@@deriving sexp_of]
  type attribute_id [@@deriving sexp_of]
  type attribute [@@deriving sexp_of]

  type attribute_condition =
    | Always
    | Never
    | Attribute_required of attribute
    | And of attribute_condition * attribute_condition
    | Or of attribute_condition * attribute_condition
  [@@deriving sexp_of]

  type attribute_handler
  type (_, _) t [@@deriving sexp_of]

  val attribute_id : string -> attribute_id
  val resource : string -> (resource, resource_handler) t
  val agent : string -> (agent, agent) t
  val resource_handler : string -> (resource_handler, resource_handler) t

  val attribute :
    string -> attribute_condition -> (attribute, attribute_handler) t

  val attribute_node_of_attribute :
    attribute -> (attribute, attribute_handler) t

  val attribute_handler :
    string ->
    attribute_condition ->
    (attribute_handler, attribute_handler) t

  val attribute_handler_node_of_attribute_handler :
    attribute_handler -> (attribute_handler, attribute_handler) t
end

type t [@@deriving sexp_of]

val create : (Node.agent, Node.agent) Node.t -> string -> t
val root_node : (Node.resource, Node.resource_handler) Node.t

val add_resource :
  t ->
  (Node.resource, Node.resource_handler) Node.t ->
  parent:('a, 'b) Node.t ->
  entrances:(Node.resource, Node.resource_handler) Node.t list ->
  t

val add_resource_handler :
  t ->
  maintainer:(Node.agent, Node.agent) Node.t ->
  resource_handler:(Node.resource_handler, Node.resource_handler) Node.t ->
  parent:('a, 'b) Node.t ->
  t

val add_agent : t -> agent:(Node.agent, Node.agent) Node.t -> t

val add_attribute :
  t ->
  attribute:(Node.attribute, Node.attribute_handler) Node.t ->
  attribute_handler:
    (Node.attribute_handler, Node.attribute_handler) Node.t ->
  t

val add_attribute_handler_under_agent :
  t ->
  attribute_handler:
    (Node.attribute_handler, Node.attribute_handler) Node.t ->
  agent:(Node.agent, Node.agent) Node.t ->
  t

val add_attribute_handler_under_maintainer :
  t ->
  attribute_handler:
    (Node.attribute_handler, Node.attribute_handler) Node.t ->
  attribute_handler_maintainer:
    (Node.attribute_handler, Node.attribute_handler) Node.t ->
  t

val grant_attribute :
  t ->
  agent:(Node.agent, Node.agent) Node.t ->
  from:(Node.agent, Node.agent) Node.t ->
  to_:('c, Node.attribute_handler) Node.t ->
  t

val grant_access :
  t ->
  agent:(Node.agent, Node.agent) Node.t ->
  from:(Node.agent, Node.agent) Node.t ->
  to_:('c, Node.resource_handler) Node.t ->
  t

val automatic_permission :
  t ->
  agent:(Node.agent, Node.agent) Node.t ->
  from:(Node.attribute, Node.attribute_handler) Node.t ->
  to_:('c, Node.resource_handler) Node.t ->
  t

val revoke_attribute :
  t ->
  agent:(Node.agent, Node.agent) Node.t ->
  from:(Node.agent, Node.agent) Node.t ->
  to_:('c, Node.attribute_handler) Node.t ->
  t

val revoke_access :
  t ->
  agent:(Node.agent, Node.agent) Node.t ->
  from:(Node.agent, Node.agent) Node.t ->
  to_:('c, Node.resource_handler) Node.t ->
  t

val revoke_automatic_permission :
  t ->
  agent:(Node.agent, Node.agent) Node.t ->
  from:(Node.attribute, Node.attribute_handler) Node.t ->
  to_:('c, Node.resource_handler) Node.t ->
  t

val move_agent :
  t ->
  agent:(Node.agent, Node.agent) Node.t ->
  to_:('a, 'b) Node.t ->
  t
(*
    val routes : t -> (Node.resource, Node.resource_handler) Node.t -> (Node.resource, Node.resource_handler) Node.t list list
    val delete_resource : t -> (Node.resource, Node.resource_handler) Node.t -> t
*)

val get_attribute_by_id : t -> Node.attribute_id -> Node.attribute

val get_attribute_handler_by_id :
  t -> Node.attribute_id -> Node.attribute_handler

val to_json : t -> Yojson.t
