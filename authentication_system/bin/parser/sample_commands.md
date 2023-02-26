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
