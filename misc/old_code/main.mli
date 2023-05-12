module Proof : sig
  type t
  type ts

  val add_proof : ts -> t -> ts
  val singleton : t -> ts
  val empty : ts
end

module Id : sig
  type 'a t
  type typs = Property| Person
  val property : string -> Property t
  val person : string -> Person t 
end

module Permission : sig
  type t = In of Identifier.t | Out of Identifier.t
end

module KYP : sig
  type t = { permission : Permission.t; required_proofs : Proof.ts }
end

type t
type entity

val root : t
val create : Identifier.t -> t

val splice_subtree :
  current_state:t -> subtree:t -> new_parent:Identifier.t -> t

val (@+>) : t -> t -> t

val is_transition_valid :
  current_state:t -> proofs:Proof.ts -> new_state:t -> bool

val possible_transitions : current_state:t -> proofs:Proof.ts -> t list
