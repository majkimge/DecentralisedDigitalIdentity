open Dsl_front
open! Core

let _ =
  let lexbuf =
    Lexing.from_channel
      (In_channel.create
         "/home/majkimge/Cambridge/DecentralisedDigitalIdentity/frontend/parser/bin/commands")
  in
  let res_ref = ref false in
  try
    while true do
      res_ref := Parser.main Lexer.token lexbuf
    done
  with exn ->
    let curr = lexbuf.Lexing.lex_curr_p in
    let line = curr.Lexing.pos_lnum in
    let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
    let tok = Lexing.lexeme lexbuf in
    print_s
      [%message (exn : exn) (line : int) (cnum : int) tok (!res_ref : bool)]
