open! Core

(* If there is no accounts recorded in the system for this user (probably by storing
   it in some ciphered file) create a completely new account by generating new
   key pair. Otherwise generate the new account from the key-pair associated with the
   latest account, so all accounts can be recovered from one mnemonic. *)
val create_account : unit -> unit

val 