open Dsl
open! Core

let _ =
  let lexbuf =
    Lexing.from_channel
      (In_channel.create "../authentication_system/bin/parser/commands")
  in
  let start = Core_unix.gettimeofday () in
  try
    while true do
      let system = Parser.main Lexer.token lexbuf in
      (* print_string
         (Yojson.to_string (Authentication_system.System_new.to_json system)); *)
      Yojson.to_file "system_rep"
        (Authentication_system.System_new.to_json system);
      Out_channel.flush stdout
    done
  with exn ->
    let stop = Core_unix.gettimeofday () in
    let outc = Out_channel.create ~append:true "time_measures" in
    protect
      ~f:(fun () -> fprintf outc "%f\n" (stop -. start))
      ~finally:(fun () -> Out_channel.close outc);
    print_s [%message (stop -. start : float)];
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

   join system Pembroke as Anil

   join system Pembroke as Patrick

   join system Pembroke as Michal

   select system Pembroke as admin
   create attribute handler Pembroke_handler
   create attribute Fellow under attribute handler Pembroke_handler
   create attribute handler Fellow_handler under attribute handler Pembroke_handler granted automatically if Fellow
   create attribute Fellow_supervisee under attribute handler Fellow_handler
   grant Anil attribute Fellow
   grant Anil access to location main_site
   grant Anil access to location officeA
   grant Patrick access to location main_site
   grant Patrick access to location officeA
   grant access to organisation Fellow_office with attribute Fellow

   select system Pembroke as Anil
   grant access to location officeC with attribute Fellow_supervisee
   grant Anil access to location officeC
   grant Patrick attribute Fellow_supervisee

   move Patrick to officeC
*)

(* Ticket system
   create system Cambridge as Cambridge_admin
   create attribute handler Cambridge_handler
   create attribute Student under attribute handler Cambridge_handler
   create attribute Professor under attribute handler Cambridge_handler
   create attribute Postdoc under attribute handler Cambridge_handler

   join system Cambridge as College_admin
   create attribute handler College_handler
   create attribute College_member under attribute handler College_handler
   create attribute Internal_ticket under attribute handler College_handler granted automatically if College_member
   create attribute External_ticket under attribute handler College_handler granted automatically if Student or Professor or Postdoc
   create organisation College
   create location main_court in organisation College with entrances to world
*)

(* Pseudocode for lock:
   onLockRead(lock, card){
     let challengeValue = generateChallenge() in
     let challengeResponse = challenge(challengeValue, card) in
     if(authenticate(card.name, challengeValue, challengeResponse)) then
       let name = card.name in
       let commands = "select system {lock.system} as {name}
                       move {name} to {lock.to}" in
       let signedCommands = await requesSignedCommands(commands, card) in
       if (verifySignature(signedCommands, commands, name)) then
         let success, result = Authentication_system.execute (commands)
         if (success) then
           Lock.open lock
   }
*)