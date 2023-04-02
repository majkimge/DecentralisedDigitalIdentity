open! Core
open! Authentication_system

let admin = System_new.Node.operator "admin"
let system = System_new.create admin "Pem"
let pembroke = System_new.Node.organisation "Pembroke"
let main_site = System_new.Node.location "main_site"
let locationA = System_new.Node.location "locationA"
let locationB = System_new.Node.location "locationB"
let locationC = System_new.Node.location "locationC"
let office_B_holder = System_new.Node.organisation "office_B_holder"
let anil = System_new.Node.operator "Anil"

let system =
  System_new.add_organisation system ~maintainer:admin ~organisation:pembroke
    ~parent:System_new.root_node

let system =
  System_new.add_location system main_site ~parent:pembroke
    ~entrances:[ System_new.root_node ]

let system =
  System_new.add_location system locationA ~parent:main_site
    ~entrances:[ main_site ]

let system =
  System_new.add_location system locationB ~parent:main_site
    ~entrances:[ locationA ]

let system =
  System_new.add_location system locationC ~parent:main_site
    ~entrances:[ main_site; locationB ]

let system = System_new.add_operator system ~operator:anil

let fellow_attribute_maintainer =
  System_new.Node.attribute_maintainer "Fellow_maintainer" System_new.Node.Never

let fellow_attribute = System_new.Node.attribute "Fellow" System_new.Node.Never

let system =
  System_new.add_attribute_maintainer_under_operator system
    ~attribute_maintainer:fellow_attribute_maintainer ~operator:admin

let system =
  System_new.add_attribute system ~attribute:fellow_attribute
    ~attribute_maintainer:fellow_attribute_maintainer

let system =
  System_new.add_permission_edge system ~operator:admin ~from:fellow_attribute
    ~to_:locationB

let system =
  System_new.add_permission_edge system ~operator:admin ~from:anil
    ~to_:locationA

let system =
  System_new.add_permission_edge system ~operator:admin ~from:anil
    ~to_:main_site

let system =
  System_new.add_permission_edge system ~operator:admin ~from:anil
    ~to_:fellow_attribute

let system = System_new.move_operator system ~operator:anil ~to_:locationB;;

print_string (Yojson.to_string (System_new.to_json system));
Yojson.to_file "system_rep" (System_new.to_json system)
