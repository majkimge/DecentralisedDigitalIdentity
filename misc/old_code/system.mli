open Core

module Id : sig
  type person
  type property
  type organisation

  type _ t =
    | Person : person -> person t
    | Property : property -> property t
    | Organisation : organisation -> organisation t

  val property : string -> property t
  val person : string -> person t
  val organisation : string -> organisation t
end

module Position_tree : sig
  type t

  val splice_node : root:t -> node:t -> parent:'a Id.t -> t
end

module Location_graph : sig
  type t
end

module Permission_DAG : sig
  type t
end

type t = Position_tree.t * Location_graph.t * Permission_DAG.t

val create : Id.organisation Id.t -> t

val add_location :
  t -> Id.property Id.t -> inside:'a Id.t -> entrances:Id.property Id.t -> t

val add_organisation : t -> Id.organisation Id.t -> inside:'a Id.t -> t
val add_person : t -> person:Id.person Id.t -> inside:'a Id.t -> t
val splice_node : t -> node:Position_tree.t -> parent:'a Id.t -> t
val routes : t -> Id.property Id.t -> Id.property Id.t list list
val delete_location : t -> Id.property Id.t -> t
val add_access_permission : t -> Id.person Id.t -> Id.property Id.t -> t
val add_ownership_permission : t -> Id.person Id.t -> Id.property Id.t -> t
val delete_permission : t -> Id.person Id.t -> 'a Id.t -> t
val is_transition_valid : current_state:t -> new_state:t -> bool
