open! Core
open Authentication_system

let%expect_test "Pembroke_test" =
  let admin = System_new.Node.operator "admin" in
  let system = System_new.create admin "Pem" in
  let pembroke = System_new.Node.organisation "Pembroke" in
  let main_site = System_new.Node.location "main_site" in
  let locationA = System_new.Node.location "locationA" in
  let locationB = System_new.Node.location "locationB" in
  let locationC = System_new.Node.location "locationC" in
  let anil = System_new.Node.operator "Anil" in

  let system =
    System_new.add_organisation system ~maintainer:admin ~organisation:pembroke
      ~parent:System_new.root_node
  in

  let system =
    System_new.add_location system main_site ~parent:pembroke
      ~entrances:[ System_new.root_node ]
  in

  let system =
    System_new.add_location system locationA ~parent:main_site
      ~entrances:[ main_site ]
  in

  let system =
    System_new.add_location system locationB ~parent:main_site
      ~entrances:[ locationA ]
  in

  let system =
    System_new.add_location system locationC ~parent:main_site
      ~entrances:[ main_site; locationB ]
  in

  let system = System_new.add_operator system ~operator:anil in

  let fellow_attribute_maintainer =
    System_new.Node.attribute_maintainer "Fellow_maintainer"
      System_new.Node.Never
  in

  let fellow_attribute =
    System_new.Node.attribute "Fellow" System_new.Node.Never
  in

  let system =
    System_new.add_attribute_maintainer_under_operator system
      ~attribute_maintainer:fellow_attribute_maintainer ~operator:admin
  in

  let system =
    System_new.add_attribute system ~attribute:fellow_attribute
      ~attribute_maintainer:fellow_attribute_maintainer
  in

  let system =
    System_new.add_permission_edge system ~operator:admin ~from:fellow_attribute
      ~to_:locationB
  in

  let system =
    System_new.add_permission_edge system ~operator:admin ~from:anil
      ~to_:locationA
  in

  let system =
    System_new.add_permission_edge system ~operator:admin ~from:anil
      ~to_:main_site
  in

  let system =
    System_new.add_permission_edge system ~operator:admin ~from:anil
      ~to_:fellow_attribute
  in

  let system = System_new.move_operator system ~operator:anil ~to_:locationB in

  print_string (Yojson.to_string (System_new.to_json system));
  [%expect
    {|
    {"position_tree":{"nodes":[{"id":"world","group":"location","is_extension":false},{"id":"main_site","group":"location","is_extension":false},{"id":"admin","group":"operator","is_extension":false},{"id":"locationC","group":"location","is_extension":false},{"id":"locationA","group":"location","is_extension":false},{"id":"locationB","group":"location","is_extension":false},{"id":"Anil","group":"operator","is_extension":false}],"links":[{"source":"world","target":"main_site","type":"simple"},{"source":"world","target":"admin","type":"simple"},{"source":"main_site","target":"locationC","type":"simple"},{"source":"main_site","target":"locationA","type":"simple"},{"source":"locationC","target":"locationB","type":"simple"},{"source":"locationB","target":"Anil","type":"simple"}]},"permission_dag":{"nodes":[{"id":"admin","group":"operator","is_extension":false},{"id":"Fellow_maintainer","group":"attribute_maintainer","is_extension":false},{"id":"Anil","group":"operator","is_extension":false},{"id":"world","group":"location","is_extension":false},{"id":"Pembroke","group":"organisation","is_extension":false},{"id":"main_site","group":"location","is_extension":false},{"id":"locationA","group":"location","is_extension":false},{"id":"locationC","group":"location","is_extension":false},{"id":"Fellow","group":"attribute","is_extension":false},{"id":"locationB","group":"location","is_extension":false}],"links":[{"source":"admin","target":"Fellow_maintainer","type":"simple"},{"source":"admin","target":"Pembroke","type":"simple"},{"source":"admin","target":"world","type":"simple"},{"source":"Fellow_maintainer","target":"Fellow","type":"simple"},{"source":"Anil","target":"Fellow","type":"simple"},{"source":"Anil","target":"main_site","type":"simple"},{"source":"Anil","target":"locationA","type":"simple"},{"source":"Anil","target":"world","type":"simple"},{"source":"world","target":"Pembroke","type":"simple"},{"source":"Pembroke","target":"main_site","type":"simple"},{"source":"main_site","target":"locationC","type":"simple"},{"source":"main_site","target":"locationB","type":"simple"},{"source":"main_site","target":"locationA","type":"simple"},{"source":"Fellow","target":"locationB","type":"simple"}]}} |}]

let%expect_test "Ticketing_test" =
  let cambridge_admin = System_new.Node.operator "Cambridge_admin" in
  let cambridge_handler =
    System_new.Node.attribute_maintainer "Cambridge_handler" Never
  in
  let student_attribute = System_new.Node.attribute "Student" Never in
  let postdoc_attribute = System_new.Node.attribute "Postdoc" Never in
  let professor_attribute = System_new.Node.attribute "Professor" Never in
  let system = System_new.create cambridge_admin "Cambridge" in
  let system =
    System_new.add_attribute_maintainer_under_operator system
      ~attribute_maintainer:cambridge_handler ~operator:cambridge_admin
  in

  let system =
    System_new.add_attribute system ~attribute:student_attribute
      ~attribute_maintainer:cambridge_handler
  in
  let system =
    System_new.add_attribute system ~attribute:postdoc_attribute
      ~attribute_maintainer:cambridge_handler
  in
  let system =
    System_new.add_attribute system ~attribute:professor_attribute
      ~attribute_maintainer:cambridge_handler
  in
  let college_admin = System_new.Node.operator "College_admin" in
  let system = System_new.add_operator system ~operator:college_admin in
  let college_handler =
    System_new.Node.attribute_maintainer "College_handler" Never
  in
  let system =
    System_new.add_attribute_maintainer_under_operator system
      ~attribute_maintainer:college_handler ~operator:college_admin
  in
  let college_member = System_new.Node.attribute "College_member" Never in
  let system =
    System_new.add_attribute system ~attribute:college_member
      ~attribute_maintainer:college_handler
  in
  let college_member_attr =
    System_new.get_attribute_by_id system
      (System_new.Node.attribute_id "College_member")
  in
  let postdoc_attr =
    System_new.get_attribute_by_id system
      (System_new.Node.attribute_id "Postdoc")
  in
  let professor_attr =
    System_new.get_attribute_by_id system
      (System_new.Node.attribute_id "Professor")
  in
  let student_attr =
    System_new.get_attribute_by_id system
      (System_new.Node.attribute_id "Student")
  in
  let internal_event_ticket =
    System_new.Node.attribute "Internal_event_ticket"
      (Attribute_required college_member_attr)
  in
  let system =
    System_new.add_attribute system ~attribute:internal_event_ticket
      ~attribute_maintainer:college_handler
  in
  let internal_attr =
    System_new.get_attribute_by_id system
      (System_new.Node.attribute_id "Internal_event_ticket")
  in
  let external_event_ticket =
    System_new.Node.attribute "External_event_ticket"
      (System_new.Node.Or
         ( System_new.Node.Or
             ( System_new.Node.Attribute_required postdoc_attr,
               System_new.Node.Attribute_required professor_attr ),
           System_new.Node.Or
             ( System_new.Node.Attribute_required student_attr,
               System_new.Node.Attribute_required internal_attr ) ))
  in
  let system =
    System_new.add_attribute system ~attribute:external_event_ticket
      ~attribute_maintainer:college_handler
  in
  let college = System_new.Node.organisation "College" in
  let system =
    System_new.add_organisation system ~maintainer:college_admin
      ~organisation:college ~parent:System_new.root_node
  in
  (* let () = print_string (Yojson.to_string (System_new.to_json system)) in *)
  let main_site = System_new.Node.location "main_site" in
  let system =
    System_new.add_location system main_site ~parent:college
      ~entrances:[ System_new.root_node ]
  in
  let meeting_room = System_new.Node.location "meeting_room" in
  let system =
    System_new.add_location system meeting_room ~parent:main_site
      ~entrances:[ System_new.root_node; main_site ]
  in
  let system =
    System_new.add_permission_edge system ~operator:college_admin
      ~from:internal_event_ticket ~to_:meeting_room
  in
  let system =
    System_new.add_permission_edge system ~operator:college_admin
      ~from:external_event_ticket ~to_:main_site
  in
  print_string (Yojson.to_string (System_new.to_json system));
  [%expect
    {|
{"position_tree":{"nodes":[{"id":"world","group":"location","is_extension":false},{"id":"meeting_room","group":"location","is_extension":false},{"id":"main_site","group":"location","is_extension":false},{"id":"College_admin","group":"operator","is_extension":false},{"id":"Cambridge_admin","group":"operator","is_extension":false}],"links":[{"source":"world","target":"meeting_room","type":"simple"},{"source":"world","target":"main_site","type":"simple"},{"source":"world","target":"College_admin","type":"simple"},{"source":"world","target":"Cambridge_admin","type":"simple"}]},"permission_dag":{"nodes":[{"id":"Cambridge_admin","group":"operator","is_extension":false},{"id":"Cambridge_handler","group":"attribute_maintainer","is_extension":false},{"id":"Student","group":"attribute","is_extension":false},{"id":"Postdoc","group":"attribute","is_extension":false},{"id":"Professor","group":"attribute","is_extension":false},{"id":"College_admin","group":"operator","is_extension":false},{"id":"world","group":"location","is_extension":false},{"id":"College_handler","group":"attribute_maintainer","is_extension":false},{"id":"College_member","group":"attribute","is_extension":false},{"id":"Internal_event_ticket","group":"attribute","is_extension":false},{"id":"External_event_ticket","group":"attribute","is_extension":false},{"id":"College","group":"organisation","is_extension":false},{"id":"main_site","group":"location","is_extension":false},{"id":"meeting_room","group":"location","is_extension":false}],"links":[{"source":"Cambridge_admin","target":"Cambridge_handler","type":"simple"},{"source":"Cambridge_admin","target":"world","type":"simple"},{"source":"Cambridge_handler","target":"Professor","type":"simple"},{"source":"Cambridge_handler","target":"Postdoc","type":"simple"},{"source":"Cambridge_handler","target":"Student","type":"simple"},{"source":"Student","target":"External_event_ticket","type":"simple"},{"source":"Postdoc","target":"External_event_ticket","type":"simple"},{"source":"Professor","target":"External_event_ticket","type":"simple"},{"source":"College_admin","target":"College","type":"simple"},{"source":"College_admin","target":"College_handler","type":"simple"},{"source":"College_admin","target":"world","type":"simple"},{"source":"world","target":"College","type":"simple"},{"source":"College_handler","target":"External_event_ticket","type":"simple"},{"source":"College_handler","target":"Internal_event_ticket","type":"simple"},{"source":"College_handler","target":"College_member","type":"simple"},{"source":"College_member","target":"Internal_event_ticket","type":"simple"},{"source":"Internal_event_ticket","target":"meeting_room","type":"simple"},{"source":"Internal_event_ticket","target":"External_event_ticket","type":"simple"},{"source":"External_event_ticket","target":"main_site","type":"simple"},{"source":"College","target":"main_site","type":"simple"},{"source":"main_site","target":"meeting_room","type":"simple"}]}}
    |}]