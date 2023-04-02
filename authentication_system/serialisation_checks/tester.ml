open! Core

type t = { value : int; refs : t ref list } [@@deriving bin_io, sexp]

let execute () =
  let a = ref { value = 1; refs = [] } in
  let b = ref { value = 2; refs = [ a ] } in
  let () = a := { value = 3; refs = [ b ] } in
  let c = (Marshal.from_channel (In_channel.create "system_test") : t) in
  print_s [%message (!(List.hd_exn !(List.hd_exn c.refs).refs).value : int)]
;;

execute ()
