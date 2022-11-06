open! Core

module Private_key : sig
  type t
end

module Public_key : sig
  type t
end

val generate_key : ?generator:Mirage_crypto_rng.g -> unit -> Private_key.t
val public_key : Private_key.t -> Public_key.t
