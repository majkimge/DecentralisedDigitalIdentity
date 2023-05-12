open! Core
open Authentication_system

let%expect_test "Pembroke_test" =
  let admin = System.Node.agent "admin" in
  let system = System.create admin "Pem" in
  let pembroke = System.Node.resource_handler "Pembroke" in
  let main_site = System.Node.resource "main_site" in
  let resourceA = System.Node.resource "resourceA" in
  let resourceB = System.Node.resource "resourceB" in
  let resourceC = System.Node.resource "resourceC" in
  let anil = System.Node.agent "Anil" in

  let system =
    System.add_resource_handler system ~maintainer:admin
      ~resource_handler:pembroke ~parent:System.root_node
  in

  let system =
    System.add_resource system main_site ~parent:pembroke
      ~entrances:[ System.root_node ]
  in

  let system =
    System.add_resource system resourceA ~parent:main_site
      ~entrances:[ main_site ]
  in

  let system =
    System.add_resource system resourceB ~parent:main_site
      ~entrances:[ resourceA ]
  in

  let system =
    System.add_resource system resourceC ~parent:main_site
      ~entrances:[ main_site; resourceB ]
  in

  let system = System.add_agent system ~agent:anil in

  let fellow_attribute_handler =
    System.Node.attribute_handler "Fellow_maintainer" System.Node.Never
  in

  let fellow_attribute =
    System.Node.attribute "Fellow" System.Node.Never
  in

  let system =
    System.add_attribute_handler_under_agent system
      ~attribute_handler:fellow_attribute_handler ~agent:admin
  in

  let system =
    System.add_attribute system ~attribute:fellow_attribute
      ~attribute_handler:fellow_attribute_handler
  in

  let system =
    System.automatic_permission system ~agent:admin ~from:fellow_attribute
      ~to_:resourceB
  in

  let system =
    System.grant_access system ~agent:admin ~from:anil ~to_:resourceA
  in

  let system =
    System.grant_access system ~agent:admin ~from:anil ~to_:main_site
  in

  let system =
    System.grant_attribute system ~agent:admin ~from:anil
      ~to_:fellow_attribute
  in

  let system = System.move_agent system ~agent:anil ~to_:resourceB in

  print_string (Yojson.to_string (System.to_json system));
  [%expect
    {|
    {"position_tree":{"nodes":[{"id":"world","group":"resource","is_extension":false},{"id":"main_site","group":"resource","is_extension":false},{"id":"admin","group":"agent","is_extension":false},{"id":"resourceC","group":"resource","is_extension":false},{"id":"resourceA","group":"resource","is_extension":false},{"id":"resourceB","group":"resource","is_extension":false},{"id":"Anil","group":"agent","is_extension":false}],"links":[{"source":"world","target":"main_site","type":"simple"},{"source":"world","target":"admin","type":"simple"},{"source":"main_site","target":"resourceC","type":"simple"},{"source":"main_site","target":"resourceA","type":"simple"},{"source":"resourceC","target":"resourceB","type":"simple"},{"source":"resourceB","target":"Anil","type":"simple"}]},"permission_dag":{"nodes":[{"id":"admin","group":"agent","is_extension":false},{"id":"Fellow_maintainer","group":"attribute_handler","is_extension":false},{"id":"Anil","group":"agent","is_extension":false},{"id":"world","group":"resource","is_extension":false},{"id":"Pembroke","group":"resource_handler","is_extension":false},{"id":"main_site","group":"resource","is_extension":false},{"id":"resourceA","group":"resource","is_extension":false},{"id":"resourceC","group":"resource","is_extension":false},{"id":"Fellow","group":"attribute","is_extension":false},{"id":"resourceB","group":"resource","is_extension":false}],"links":[{"source":"admin","target":"Fellow_maintainer","type":"simple"},{"source":"admin","target":"Pembroke","type":"simple"},{"source":"admin","target":"world","type":"simple"},{"source":"Fellow_maintainer","target":"Fellow","type":"simple"},{"source":"Anil","target":"Fellow","type":"simple"},{"source":"Anil","target":"main_site","type":"simple"},{"source":"Anil","target":"resourceA","type":"simple"},{"source":"Anil","target":"world","type":"simple"},{"source":"world","target":"main_site","type":"simple"},{"source":"world","target":"Pembroke","type":"simple"},{"source":"Pembroke","target":"main_site","type":"simple"},{"source":"main_site","target":"resourceC","type":"simple"},{"source":"main_site","target":"resourceB","type":"simple"},{"source":"main_site","target":"resourceA","type":"simple"},{"source":"Fellow","target":"resourceB","type":"simple"}]}} |}]

let%expect_test "Ticketing_test" =
  let cambridge_admin = System.Node.agent "Cambridge_admin" in
  let cambridge_handler =
    System.Node.attribute_handler "Cambridge_handler" Never
  in
  let student_attribute = System.Node.attribute "Student" Never in
  let postdoc_attribute = System.Node.attribute "Postdoc" Never in
  let professor_attribute = System.Node.attribute "Professor" Never in
  let system = System.create cambridge_admin "Cambridge" in
  let system =
    System.add_attribute_handler_under_agent system
      ~attribute_handler:cambridge_handler ~agent:cambridge_admin
  in

  let system =
    System.add_attribute system ~attribute:student_attribute
      ~attribute_handler:cambridge_handler
  in
  let system =
    System.add_attribute system ~attribute:postdoc_attribute
      ~attribute_handler:cambridge_handler
  in
  let system =
    System.add_attribute system ~attribute:professor_attribute
      ~attribute_handler:cambridge_handler
  in
  let college_admin = System.Node.agent "College_admin" in
  let system = System.add_agent system ~agent:college_admin in
  let college_handler =
    System.Node.attribute_handler "College_handler" Never
  in
  let system =
    System.add_attribute_handler_under_agent system
      ~attribute_handler:college_handler ~agent:college_admin
  in
  let college_member = System.Node.attribute "College_member" Never in
  let system =
    System.add_attribute system ~attribute:college_member
      ~attribute_handler:college_handler
  in
  let college_member_attr =
    System.get_attribute_by_id system
      (System.Node.attribute_id "College_member")
  in
  let postdoc_attr =
    System.get_attribute_by_id system
      (System.Node.attribute_id "Postdoc")
  in
  let professor_attr =
    System.get_attribute_by_id system
      (System.Node.attribute_id "Professor")
  in
  let student_attr =
    System.get_attribute_by_id system
      (System.Node.attribute_id "Student")
  in
  let internal_event_ticket =
    System.Node.attribute "Internal_event_ticket"
      (Attribute_required college_member_attr)
  in
  let system =
    System.add_attribute system ~attribute:internal_event_ticket
      ~attribute_handler:college_handler
  in
  let internal_attr =
    System.get_attribute_by_id system
      (System.Node.attribute_id "Internal_event_ticket")
  in
  let external_event_ticket =
    System.Node.attribute "External_event_ticket"
      (System.Node.Or
         ( System.Node.Or
             ( System.Node.Attribute_required postdoc_attr,
               System.Node.Attribute_required professor_attr ),
           System.Node.Or
             ( System.Node.Attribute_required student_attr,
               System.Node.Attribute_required internal_attr ) ))
  in
  let system =
    System.add_attribute system ~attribute:external_event_ticket
      ~attribute_handler:college_handler
  in
  let college = System.Node.resource_handler "College" in
  let system =
    System.add_resource_handler system ~maintainer:college_admin
      ~resource_handler:college ~parent:System.root_node
  in
  (* let () = print_string (Yojson.to_string (System.to_json system)) in *)
  let main_site = System.Node.resource "main_site" in
  let system =
    System.add_resource system main_site ~parent:college
      ~entrances:[ System.root_node ]
  in
  let meeting_room = System.Node.resource "meeting_room" in
  let system =
    System.add_resource system meeting_room ~parent:main_site
      ~entrances:[ System.root_node; main_site ]
  in
  let system =
    System.automatic_permission system ~agent:college_admin
      ~from:internal_event_ticket ~to_:meeting_room
  in
  let system =
    System.automatic_permission system ~agent:college_admin
      ~from:external_event_ticket ~to_:main_site
  in
  print_string (Yojson.to_string (System.to_json system));
  [%expect
    {|
{"position_tree":{"nodes":[{"id":"world","group":"resource","is_extension":false},{"id":"meeting_room","group":"resource","is_extension":false},{"id":"main_site","group":"resource","is_extension":false},{"id":"College_admin","group":"agent","is_extension":false},{"id":"Cambridge_admin","group":"agent","is_extension":false}],"links":[{"source":"world","target":"meeting_room","type":"simple"},{"source":"world","target":"main_site","type":"simple"},{"source":"world","target":"College_admin","type":"simple"},{"source":"world","target":"Cambridge_admin","type":"simple"}]},"permission_dag":{"nodes":[{"id":"Cambridge_admin","group":"agent","is_extension":false},{"id":"Cambridge_handler","group":"attribute_handler","is_extension":false},{"id":"Student","group":"attribute","is_extension":false},{"id":"Postdoc","group":"attribute","is_extension":false},{"id":"Professor","group":"attribute","is_extension":false},{"id":"College_admin","group":"agent","is_extension":false},{"id":"world","group":"resource","is_extension":false},{"id":"College_handler","group":"attribute_handler","is_extension":false},{"id":"College_member","group":"attribute","is_extension":false},{"id":"Internal_event_ticket","group":"attribute","is_extension":false},{"id":"External_event_ticket","group":"attribute","is_extension":false},{"id":"College","group":"resource_handler","is_extension":false},{"id":"main_site","group":"resource","is_extension":false},{"id":"meeting_room","group":"resource","is_extension":false}],"links":[{"source":"Cambridge_admin","target":"Cambridge_handler","type":"simple"},{"source":"Cambridge_admin","target":"world","type":"simple"},{"source":"Cambridge_handler","target":"Professor","type":"simple"},{"source":"Cambridge_handler","target":"Postdoc","type":"simple"},{"source":"Cambridge_handler","target":"Student","type":"simple"},{"source":"Student","target":"External_event_ticket","type":"simple"},{"source":"Postdoc","target":"External_event_ticket","type":"simple"},{"source":"Professor","target":"External_event_ticket","type":"simple"},{"source":"College_admin","target":"College","type":"simple"},{"source":"College_admin","target":"College_handler","type":"simple"},{"source":"College_admin","target":"world","type":"simple"},{"source":"world","target":"main_site","type":"simple"},{"source":"world","target":"College","type":"simple"},{"source":"College_handler","target":"External_event_ticket","type":"simple"},{"source":"College_handler","target":"Internal_event_ticket","type":"simple"},{"source":"College_handler","target":"College_member","type":"simple"},{"source":"College_member","target":"Internal_event_ticket","type":"simple"},{"source":"Internal_event_ticket","target":"meeting_room","type":"simple"},{"source":"Internal_event_ticket","target":"External_event_ticket","type":"simple"},{"source":"External_event_ticket","target":"main_site","type":"simple"},{"source":"College","target":"main_site","type":"simple"},{"source":"main_site","target":"meeting_room","type":"simple"}]}}
    |}]