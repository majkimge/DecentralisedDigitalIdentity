open Dsl
open! Core

let _ =
  let lexbuf =
    Lexing.from_channel
      (In_channel.create "../authentication_system/bin/parser/commands")
  in
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
    print_s [%message (exn : exn) (line : int) (cnum : int) tok]

(* Test Prompts:
   create system Pembroke as admin
   create organisation Pembroke
   create location main_site in organisation Pembroke with entrances to root
   create location officeA in location main_site with entrances to main_site
   create location officeB in location main_site with entrances to main_site
   create organisation Fellow_office in location main_site
   create location officeC in organisation Fellow_office with entrances to officeA, officeB
   create operator Anil
   create operator Patrick
   create operator Michal
   create attribute handler Pembroke_handler
   create attribute Fellow under attribute handler Pembroke_handler
   create attribute handler Fellow_handler under attribute handler Pembroke_handler granted automatically if Fellow
   create attribute Fellow_supervisee under attribute handler Fellow_handler
   grant Anil attribute Fellow
   grant Anil access to location main_site
   grant Anil access to location officeA
   grant Patrick access to location main_site
   grant Patrick access to location officeA
   grant Anil attribute Fellow
   grant access to organisation Fellow_office with attribute Fellow
   select system Pembroke as Anil
   grant access to location officeC with attribute Fellow_supervisee
   grant Anil access to location officeC
   grant Patrick attribute Fellow_supervisee
      move Patrick to officeC
*)