open! Core

module Private_key = struct
  type t = Mirage_crypto_pk.Rsa.priv
end

module Public_key = struct
  type t = Mirage_crypto_pk.Rsa.pub
end

let generate_key ?generator =
  Mirage_crypto_pk.Rsa.generate ?g:generator ?e:None ~bits:512

let public_key private_key = Mirage_crypto_pk.Rsa.pub_of_priv private_key
