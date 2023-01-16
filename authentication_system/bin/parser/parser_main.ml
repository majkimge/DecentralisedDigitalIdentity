open Dsl
open! Core

let _ =
  let lexbuf = Lexing.from_channel In_channel.stdin in
  try
    while true do
      let system = Parser.main Lexer.token lexbuf in
      print_string
        (Yojson.to_string (Authentication_system.System_new.to_json system));
      Yojson.to_file "system_rep"
        (Authentication_system.System_new.to_json system);
      Out_channel.flush stdout
    done
  with exn ->
    let curr = lexbuf.Lexing.lex_curr_p in
    let line = curr.Lexing.pos_lnum in
    let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
    let tok = Lexing.lexeme lexbuf in
    raise_s [%message (exn : exn) (line : int) (cnum : int) tok]
