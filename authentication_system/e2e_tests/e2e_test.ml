open! Core
open Dsl

let execute_commands commands =
  let lexbuf = Lexing.from_string commands in
  try
    while true do
      let system = Parser.main Lexer.token lexbuf in
      print_endline
        (Yojson.to_string (Authentication_system.System_new.to_json system))
    done
  with exn ->
    let curr = lexbuf.Lexing.lex_curr_p in
    let line = curr.Lexing.pos_lnum in
    let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
    let tok = Lexing.lexeme lexbuf in
    print_s [%message (exn : exn) (line : int) (cnum : int) tok]

let%expect_test "Pembroke_dsl_test" =
  let commands =
    "create system Pembroke as admin\n\
     create resource handler Pembroke\n\
     create resource main_site in resource handler Pembroke with entrances to \
     world\n\
     create resource officeA in resource main_site with entrances to main_site\n\
     create resource officeB in resource main_site with entrances to main_site\n\
     create resource handler Fellow_office in resource main_site\n\
     create resource officeC in resource handler Fellow_office with entrances \
     to officeA, officeB\n\n\
     join system Pembroke as Anil\n\n\
     join system Pembroke as Patrick\n\n\
     join system Pembroke as Michal\n\n\
     select system Pembroke as admin\n\
     create attribute handler Pembroke_handler\n\
     create attribute Fellow under attribute handler Pembroke_handler\n\
     create attribute handler Fellow_handler under attribute handler \
     Pembroke_handler granted automatically if Fellow\n\
     create attribute Fellow_supervisee under attribute handler Fellow_handler\n\
     grant Anil attribute Fellow\n\
     grant Anil access to resource main_site\n\
     grant Anil access to resource officeA\n\
     grant Patrick access to resource main_site\n\
     grant Patrick access to resource officeA\n\
     grant access to resource handler Fellow_office with attribute Fellow\n\n\
     select system Pembroke as Anil\n\
     grant access to resource officeC with attribute Fellow_supervisee\n\
     grant Anil access to resource officeC\n\
     grant Patrick attribute Fellow_supervisee\n\n\
     move Patrick to officeC"
  in
  execute_commands commands;
  [%expect
    {|
    {"position_tree":{"nodes":[{"id":"world","group":"resource","is_extension":false},{"id":"Michal","group":"agent","is_extension":false},{"id":"Anil","group":"agent","is_extension":false},{"id":"main_site","group":"resource","is_extension":false},{"id":"admin","group":"agent","is_extension":false},{"id":"officeB","group":"resource","is_extension":false},{"id":"officeA","group":"resource","is_extension":false},{"id":"officeC","group":"resource","is_extension":false},{"id":"Patrick","group":"agent","is_extension":false}],"links":[{"source":"world","target":"Michal","type":"simple"},{"source":"world","target":"Anil","type":"simple"},{"source":"world","target":"main_site","type":"simple"},{"source":"world","target":"admin","type":"simple"},{"source":"main_site","target":"officeB","type":"simple"},{"source":"main_site","target":"officeA","type":"simple"},{"source":"officeB","target":"officeC","type":"simple"},{"source":"officeC","target":"Patrick","type":"simple"}]},"permission_dag":{"nodes":[{"id":"admin","group":"agent","is_extension":false},{"id":"Pembroke_handler","group":"attribute_handler","is_extension":false},{"id":"Anil","group":"agent","is_extension":false},{"id":"Fellow","group":"attribute","is_extension":false},{"id":"Fellow_handler","group":"attribute_handler","is_extension":false},{"id":"Patrick","group":"agent","is_extension":false},{"id":"Fellow_supervisee","group":"attribute","is_extension":false},{"id":"Michal","group":"agent","is_extension":false},{"id":"world","group":"resource","is_extension":false},{"id":"Pembroke","group":"resource_handler","is_extension":false},{"id":"main_site","group":"resource","is_extension":false},{"id":"officeA","group":"resource","is_extension":false},{"id":"officeB","group":"resource","is_extension":false},{"id":"Fellow_office","group":"resource_handler","is_extension":false},{"id":"officeC","group":"resource","is_extension":false}],"links":[{"source":"admin","target":"Pembroke_handler","type":"simple"},{"source":"admin","target":"Fellow_office","type":"simple"},{"source":"admin","target":"Pembroke","type":"simple"},{"source":"admin","target":"world","type":"simple"},{"source":"Pembroke_handler","target":"Fellow_handler","type":"simple"},{"source":"Pembroke_handler","target":"Fellow","type":"simple"},{"source":"Anil","target":"officeC","type":"simple"},{"source":"Anil","target":"officeA","type":"simple"},{"source":"Anil","target":"main_site","type":"simple"},{"source":"Anil","target":"Fellow","type":"simple"},{"source":"Anil","target":"world","type":"simple"},{"source":"Fellow","target":"Fellow_office","type":"simple"},{"source":"Fellow","target":"Fellow_handler","type":"simple"},{"source":"Fellow_handler","target":"Fellow_supervisee","type":"simple"},{"source":"Patrick","target":"Fellow_supervisee","type":"simple"},{"source":"Patrick","target":"officeA","type":"simple"},{"source":"Patrick","target":"main_site","type":"simple"},{"source":"Patrick","target":"world","type":"simple"},{"source":"Fellow_supervisee","target":"officeC","type":"simple"},{"source":"Michal","target":"world","type":"simple"},{"source":"world","target":"main_site","type":"simple"},{"source":"world","target":"Pembroke","type":"simple"},{"source":"Pembroke","target":"main_site","type":"simple"},{"source":"main_site","target":"officeC","type":"simple"},{"source":"main_site","target":"Fellow_office","type":"simple"},{"source":"main_site","target":"officeB","type":"simple"},{"source":"main_site","target":"officeA","type":"simple"},{"source":"Fellow_office","target":"officeC","type":"simple"}]}}
    ((exn Parsing.Parse_error) (line 1) (cnum 1328) "") |}]

let%expect_test "Event_dsl_test" =
  let commands =
    "create system Cambridge as Cambridge_admin\n\
     create attribute handler Cambridge_handler\n\
     create attribute Student under attribute handler Cambridge_handler\n\
     create attribute Professor under attribute handler Cambridge_handler\n\
     create attribute Postdoc under attribute handler Cambridge_handler\n\n\
     join system Cambridge as College_admin\n\
     create attribute handler College_handler\n\
     create attribute College_member under attribute handler College_handler\n\
     create attribute Internal_ticket under attribute handler College_handler \
     granted automatically if College_member\n\
     create attribute External_ticket under attribute handler College_handler \
     granted automatically if Student or Professor or Postdoc or \
     Internal_ticket\n\
     create resource handler College\n\
     create resource main_court in resource handler College with entrances to \
     world\n\
     create resource college_meeting_room in resource main_court with \
     entrances to main_court\n\
     grant access to resource main_court with attribute External_ticket \n\
     grant access to resource college_meeting_room with attribute \
     Internal_ticket"
  in
  execute_commands commands;
  [%expect
    {|
    {"position_tree":{"nodes":[{"id":"world","group":"resource","is_extension":false},{"id":"main_court","group":"resource","is_extension":false},{"id":"College_admin","group":"agent","is_extension":false},{"id":"Cambridge_admin","group":"agent","is_extension":false},{"id":"college_meeting_room","group":"resource","is_extension":false}],"links":[{"source":"world","target":"main_court","type":"simple"},{"source":"world","target":"College_admin","type":"simple"},{"source":"world","target":"Cambridge_admin","type":"simple"},{"source":"main_court","target":"college_meeting_room","type":"simple"}]},"permission_dag":{"nodes":[{"id":"Cambridge_admin","group":"agent","is_extension":false},{"id":"Cambridge_handler","group":"attribute_handler","is_extension":false},{"id":"Student","group":"attribute","is_extension":false},{"id":"Professor","group":"attribute","is_extension":false},{"id":"Postdoc","group":"attribute","is_extension":false},{"id":"College_admin","group":"agent","is_extension":false},{"id":"world","group":"resource","is_extension":false},{"id":"College_handler","group":"attribute_handler","is_extension":false},{"id":"College_member","group":"attribute","is_extension":false},{"id":"Internal_ticket","group":"attribute","is_extension":false},{"id":"External_ticket","group":"attribute","is_extension":false},{"id":"College","group":"resource_handler","is_extension":false},{"id":"main_court","group":"resource","is_extension":false},{"id":"college_meeting_room","group":"resource","is_extension":false}],"links":[{"source":"Cambridge_admin","target":"Cambridge_handler","type":"simple"},{"source":"Cambridge_admin","target":"world","type":"simple"},{"source":"Cambridge_handler","target":"Postdoc","type":"simple"},{"source":"Cambridge_handler","target":"Professor","type":"simple"},{"source":"Cambridge_handler","target":"Student","type":"simple"},{"source":"Student","target":"External_ticket","type":"simple"},{"source":"Professor","target":"External_ticket","type":"simple"},{"source":"Postdoc","target":"External_ticket","type":"simple"},{"source":"College_admin","target":"College","type":"simple"},{"source":"College_admin","target":"College_handler","type":"simple"},{"source":"College_admin","target":"world","type":"simple"},{"source":"world","target":"main_court","type":"simple"},{"source":"world","target":"College","type":"simple"},{"source":"College_handler","target":"External_ticket","type":"simple"},{"source":"College_handler","target":"Internal_ticket","type":"simple"},{"source":"College_handler","target":"College_member","type":"simple"},{"source":"College_member","target":"Internal_ticket","type":"simple"},{"source":"Internal_ticket","target":"college_meeting_room","type":"simple"},{"source":"Internal_ticket","target":"External_ticket","type":"simple"},{"source":"External_ticket","target":"main_court","type":"simple"},{"source":"College","target":"main_court","type":"simple"},{"source":"main_court","target":"college_meeting_room","type":"simple"}]}}
    ((exn Parsing.Parse_error) (line 1) (cnum 1048) "") |}]
