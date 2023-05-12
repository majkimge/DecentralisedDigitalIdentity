# Ticket system

create system Events as Cambridge_admin
create organisation Cambridge_University
create location Senate_House in organisation Cambridge_University with entrances to world
create attribute handler Cambridge_attributes
create attribute Cambridge_alumni under attribute handler Cambridge_attributes

join system Events as ARU_admin
create attribute handler ARU_attributes
create attribute ARU_student under attribute handler ARU_attributes

select system Events as Cambridge_admin
create attribute Event_ticket under attribute handler Cambridge_attributes granted automatically if Cambridge_alumni or ARU_student
grant access to location Senate_House with attribute Event_ticket

join system Events as Michal

select system Events as Cambridge_admin
grant Michal attribute Cambridge_alumni
move Michal to Senate_House

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
create attribute External_ticket under attribute handler College_handler granted automatically if Student or Professor or Postdoc or Internal_ticket
create organisation College
create location main_court in organisation College with entrances to world
create location college_meeting_room in location main_court with entrances to main_court
grant access to location main_court with attribute External_ticket 
grant access to location college_meeting_room with attribute Internal_ticket
*)

(* Pseudocode for lock:
   onLockRead(lock, card){
     let challengeValue = generateChallenge() in
     let challengeResponse = challenge(challengeValue, card) in
     if(authenticate(card.name, challengeValue, challengeResponse)) then
       let name = card.name in
       let commands = "select system {lock.system} as {name}
                       move {name} to {lock.to}" in
       let signedCommands = await requestSignedCommands(commands, card) in
       if (verifySignature(signedCommands, commands, name)) then
         let success, result = Authentication_system.execute (commands)
         if (success) then
           Lock.open lock
   }
*)
