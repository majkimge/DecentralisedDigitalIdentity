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
   create resource_handler Pembroke
   create resource main_site in resource_handler Pembroke with entrances to root
   create resource officeA in resource main_site with entrances to main_site
   create resource officeB in resource main_site with entrances to main_site
   create resource_handler Fellow_office in resource main_site
   create resource officeC in resource_handler Fellow_office with entrances to officeA, officeB

   join system Pembroke as Anil

   join system Pembroke as Patrick

   join system Pembroke as Michal

   select system Pembroke as admin
   create attribute handler Pembroke_handler
   create attribute Fellow under attribute handler Pembroke_handler
   create attribute handler Fellow_handler under attribute handler Pembroke_handler granted automatically if Fellow
   create attribute Fellow_supervisee under attribute handler Fellow_handler
   grant Anil attribute Fellow
   grant Anil access to resource main_site
   grant Anil access to resource officeA
   grant Patrick access to resource main_site
   grant Patrick access to resource officeA
   grant access to resource_handler Fellow_office with attribute Fellow

   select system Pembroke as Anil
   grant access to resource officeC with attribute Fellow_supervisee
   grant Anil access to resource officeC
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
   create resource_handler College
   create resource main_court in resource_handler College with entrances to world
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