
Create Pembroke
Add main site location
Add Anil, Patrick and Michał
Add Fellow, Student, and supervisee attributes.

```ocaml

let pembroke = create (Id.organisation "Pembroke")
let pembroke = add_location pembroke (Id.property "Main site") ~inside:(Id.organisation "Pembroke") ~entrances:[Entrance.Outside]

let pembroke = add_person pembroke ~person:(Id.person "Anil") ~inside:(Id.organisation "Pembroke") 
let pembroke = add_person pembroke ~person:(Id.person "Patrick") ~inside:(Id.organisation "Pembroke") 
let pembroke = add_person pembroke ~person:(Id.person "Michał") ~inside:(Id.organisation "Pembroke") 

```

Add Building A location under main site
Add Building B location under main site
Add Room A inside building A
Add Room B inside building A

```ocaml

let pembroke = add_location pembroke (Id.property "Building A") ~inside:(Id.property "Main site") ~entrances:[Entrance.Outside]
let pembroke = add_location pembroke (Id.property "Building B") ~inside:(Id.property "Main site") ~entrances:[Entrance.Outside]
let pembroke = add_location pembroke (Id.property "Room A") ~inside:(Id.property "Building A") ~entrances:[Entrance.Outside]
let pembroke = add_location pembroke (Id.property "Room B") ~inside:(Id.property "Building A") ~entrances:[Entrance.Outside]

```

Add Office between Rooms A and B inside building A
Give Anil control over the office
Give access to the office to every student supervisee of Anil
Give Patrick and Michał student and supervisee attributes.

```ocaml

let pembroke = add_location pembroke (Id.property "Office") ~inside:(Id.property "Main site") ~entrances:[(Id.property "Room A"); (Id.property "Room B")]
let pembroke = add_ownership_permission pembroke (Id.person "Anil") (Id.property "Office")
let pembroke = add_access_permission pembroke (Id.person "Patrick") (Id.property "Office")
let pembroke = add_access_permission pembroke (Id.person "Michał") (Id.property "Office")

```