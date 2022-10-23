open! Core

module Public_key : sig
  type t
end

module Private_key : sig
  type t
end

module Key_pair : sig
  type t = { public_key : Public_key.t; private_key : Private_key.t }
end

val generate_key_pair : unit -> Key_pair.t
