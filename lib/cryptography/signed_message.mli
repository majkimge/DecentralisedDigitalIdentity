open! Core

module Data : sig
  type t
end

type t

val sign : Data.t -> Cryptography.Keys.Private_key.t -> t
val contents : t -> Data.t
val signee : t -> Keys.Public_key.t
