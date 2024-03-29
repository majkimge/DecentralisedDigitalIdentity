open Dsl
open! Core

let _ =
  let lexbuf = Lexing.from_string (Array.get (Sys.get_argv ()) 1) in
  print_string (Array.get (Sys.get_argv ()) 1);
  try
    while true do
      let system = Parser.main Lexer.token lexbuf in
      print_string
        (Yojson.to_string (Authentication_system.System.to_json system));
      Yojson.to_file "system_rep"
        (Authentication_system.System.to_json system);
      Out_channel.flush stdout
    done
  with exn ->
    let curr = lexbuf.Lexing.lex_curr_p in
    let line = curr.Lexing.pos_lnum in
    let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
    let tok = Lexing.lexeme lexbuf in
    print_s [%message (exn : exn) (line : int) (cnum : int) tok]