open! Core
open Authentication_system

let print_system system =
  print_endline
    (Yojson.to_string (Authentication_system.System_new.to_json system))

let test_operator = System_new.Node.operator "test_operator"
let test_operator2 = System_new.Node.operator "test_operator2"
let test_system () = System_new.create test_operator "Test_system"
let test_location1 = System_new.Node.location "test_location1"
let test_location2 = System_new.Node.location "test_location2"
let test_location3 = System_new.Node.location "test_location3"
let test_organisation = System_new.Node.organisation "test_organisation"

let%expect_test "create test" =
  let system = test_system () in
  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"location","is_extension":false},{"id":"test_operator","group":"operator","is_extension":false}],"links":[{"source":"world","target":"test_operator","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_operator","group":"operator","is_extension":false},{"id":"world","group":"location","is_extension":false}],"links":[{"source":"test_operator","target":"world","type":"simple"}]}} |}]

let%expect_test "add location" =
  let system = test_system () in
  let system =
    System_new.add_location system test_location1 ~parent:System_new.root_node
      ~entrances:[ System_new.root_node ]
  in
  let system =
    System_new.add_location system test_location2 ~parent:test_location1
      ~entrances:[ test_location1 ]
  in
  let system =
    System_new.add_location system test_location3 ~parent:test_location2
      ~entrances:[ test_location1; test_location2 ]
  in
  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"location","is_extension":false},{"id":"test_location1","group":"location","is_extension":false},{"id":"test_operator","group":"operator","is_extension":false},{"id":"test_location3","group":"location","is_extension":false},{"id":"test_location2","group":"location","is_extension":false}],"links":[{"source":"world","target":"test_location1","type":"simple"},{"source":"world","target":"test_operator","type":"simple"},{"source":"test_location1","target":"test_location3","type":"simple"},{"source":"test_location1","target":"test_location2","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_operator","group":"operator","is_extension":false},{"id":"world","group":"location","is_extension":false},{"id":"test_location1","group":"location","is_extension":false},{"id":"test_location2","group":"location","is_extension":false},{"id":"test_location3","group":"location","is_extension":false}],"links":[{"source":"test_operator","target":"world","type":"simple"},{"source":"world","target":"test_location1","type":"simple"},{"source":"test_location1","target":"test_location2","type":"simple"},{"source":"test_location2","target":"test_location3","type":"simple"}]}} |}]

let%expect_test "add organisation" =
  let system = test_system () in
  let system =
    System_new.add_organisation system ~organisation:test_organisation
      ~parent:System_new.root_node ~maintainer:test_operator
  in
  let system =
    System_new.add_location system test_location2 ~parent:test_organisation
      ~entrances:[ System_new.root_node ]
  in
  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"location","is_extension":false},{"id":"test_location2","group":"location","is_extension":false},{"id":"test_operator","group":"operator","is_extension":false}],"links":[{"source":"world","target":"test_location2","type":"simple"},{"source":"world","target":"test_operator","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_operator","group":"operator","is_extension":false},{"id":"world","group":"location","is_extension":false},{"id":"test_organisation","group":"organisation","is_extension":false},{"id":"test_location2","group":"location","is_extension":false}],"links":[{"source":"test_operator","target":"test_organisation","type":"simple"},{"source":"test_operator","target":"world","type":"simple"},{"source":"world","target":"test_organisation","type":"simple"},{"source":"test_organisation","target":"test_location2","type":"simple"}]}} |}]

let%expect_test "add operator" =
  let system = test_system () in
  let system = System_new.add_operator system ~operator:test_operator2 in
  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"location","is_extension":false},{"id":"test_operator2","group":"operator","is_extension":false},{"id":"test_operator","group":"operator","is_extension":false}],"links":[{"source":"world","target":"test_operator2","type":"simple"},{"source":"world","target":"test_operator","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_operator","group":"operator","is_extension":false},{"id":"test_operator2","group":"operator","is_extension":false},{"id":"world","group":"location","is_extension":false}],"links":[{"source":"test_operator","target":"world","type":"simple"},{"source":"test_operator2","target":"world","type":"simple"}]}} |}]

let%expect_test "add attribute" =
  let system = test_system () in
  let attribute1 = System_new.Node.attribute "attribute1" Never in
  let attribute_maintainer =
    System_new.Node.attribute_maintainer "attribute_maintainer" Never
  in
  let system =
    System_new.add_attribute_maintainer_under_operator system
      ~operator:test_operator ~attribute_maintainer
  in
  let system =
    System_new.add_attribute system ~attribute:attribute1 ~attribute_maintainer
  in
  let attr_ref =
    System_new.get_attribute_by_id system
      (System_new.Node.attribute_id "attribute1")
  in
  let attribute2 =
    System_new.Node.attribute "attribute2" (Attribute_required attr_ref)
  in
  let system =
    System_new.add_attribute system ~attribute:attribute2 ~attribute_maintainer
  in
  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"location","is_extension":false},{"id":"test_operator","group":"operator","is_extension":false}],"links":[{"source":"world","target":"test_operator","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_operator","group":"operator","is_extension":false},{"id":"world","group":"location","is_extension":false},{"id":"attribute_maintainer","group":"attribute_maintainer","is_extension":false},{"id":"attribute1","group":"attribute","is_extension":false},{"id":"attribute2","group":"attribute","is_extension":false}],"links":[{"source":"test_operator","target":"attribute_maintainer","type":"simple"},{"source":"test_operator","target":"world","type":"simple"},{"source":"attribute_maintainer","target":"attribute2","type":"simple"},{"source":"attribute_maintainer","target":"attribute1","type":"simple"},{"source":"attribute1","target":"attribute2","type":"simple"}]}} |}]

let%expect_test "add permission" =
  let system = test_system () in
  let attribute1 = System_new.Node.attribute "attribute1" Never in
  let attribute_maintainer =
    System_new.Node.attribute_maintainer "attribute_maintainer" Never
  in

  let system =
    System_new.add_attribute_maintainer_under_operator system
      ~operator:test_operator ~attribute_maintainer
  in
  let system =
    System_new.add_attribute system ~attribute:attribute1 ~attribute_maintainer
  in

  let system =
    System_new.add_permission_edge system ~operator:test_operator
      ~from:test_operator ~to_:attribute1
  in

  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"location","is_extension":false},{"id":"test_operator","group":"operator","is_extension":false}],"links":[{"source":"world","target":"test_operator","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_operator","group":"operator","is_extension":false},{"id":"world","group":"location","is_extension":false},{"id":"attribute_maintainer","group":"attribute_maintainer","is_extension":false},{"id":"attribute1","group":"attribute","is_extension":false}],"links":[{"source":"test_operator","target":"attribute1","type":"simple"},{"source":"test_operator","target":"attribute_maintainer","type":"simple"},{"source":"test_operator","target":"world","type":"simple"},{"source":"attribute_maintainer","target":"attribute1","type":"simple"}]}} |}]

let%expect_test "delete permission" =
  let system = test_system () in
  let attribute1 = System_new.Node.attribute "attribute1" Never in
  let attribute_maintainer =
    System_new.Node.attribute_maintainer "attribute_maintainer" Never
  in
  let system =
    System_new.add_attribute_maintainer_under_operator system
      ~operator:test_operator ~attribute_maintainer
  in
  let system =
    System_new.add_attribute system ~attribute:attribute1 ~attribute_maintainer
  in

  let system =
    System_new.add_permission_edge system ~operator:test_operator
      ~from:test_operator ~to_:attribute1
  in

  let system =
    System_new.delete_permission_edge system ~operator:test_operator
      ~node:attribute1
  in

  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"location","is_extension":false},{"id":"test_operator","group":"operator","is_extension":false}],"links":[{"source":"world","target":"test_operator","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_operator","group":"operator","is_extension":false},{"id":"world","group":"location","is_extension":false},{"id":"attribute_maintainer","group":"attribute_maintainer","is_extension":false},{"id":"attribute1","group":"attribute","is_extension":false}],"links":[{"source":"test_operator","target":"attribute_maintainer","type":"simple"},{"source":"test_operator","target":"world","type":"simple"},{"source":"attribute_maintainer","target":"attribute1","type":"simple"}]}} |}]

let%expect_test "move_operator_success" =
  let system = test_system () in
  let system =
    System_new.add_organisation system ~organisation:test_organisation
      ~parent:System_new.root_node ~maintainer:test_operator
  in
  let system =
    System_new.add_location system test_location1 ~parent:test_organisation
      ~entrances:[ System_new.root_node ]
  in
  let attribute1 = System_new.Node.attribute "attribute1" Never in
  let attribute_maintainer =
    System_new.Node.attribute_maintainer "attribute_maintainer" Never
  in
  let system =
    System_new.add_attribute_maintainer_under_operator system
      ~operator:test_operator ~attribute_maintainer
  in
  let system =
    System_new.add_attribute system ~attribute:attribute1 ~attribute_maintainer
  in

  let system =
    System_new.add_permission_edge system ~operator:test_operator
      ~from:test_operator ~to_:attribute1
  in
  let system =
    System_new.add_permission_edge system ~operator:test_operator
      ~from:attribute1 ~to_:test_location1
  in
  let system =
    System_new.move_operator system ~operator:test_operator ~to_:test_location1
  in

  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"location","is_extension":false},{"id":"test_location1","group":"location","is_extension":false},{"id":"test_operator","group":"operator","is_extension":false}],"links":[{"source":"world","target":"test_location1","type":"simple"},{"source":"test_location1","target":"test_operator","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_operator","group":"operator","is_extension":false},{"id":"world","group":"location","is_extension":false},{"id":"test_organisation","group":"organisation","is_extension":false},{"id":"attribute_maintainer","group":"attribute_maintainer","is_extension":false},{"id":"attribute1","group":"attribute","is_extension":false},{"id":"test_location1","group":"location","is_extension":false}],"links":[{"source":"test_operator","target":"attribute1","type":"simple"},{"source":"test_operator","target":"attribute_maintainer","type":"simple"},{"source":"test_operator","target":"test_organisation","type":"simple"},{"source":"test_operator","target":"world","type":"simple"},{"source":"world","target":"test_organisation","type":"simple"},{"source":"test_organisation","target":"test_location1","type":"simple"},{"source":"attribute_maintainer","target":"attribute1","type":"simple"},{"source":"attribute1","target":"test_location1","type":"simple"}]}} |}]

let%expect_test "move_operator_fail" =
  let system = test_system () in
  let system =
    System_new.add_organisation system ~organisation:test_organisation
      ~parent:System_new.root_node ~maintainer:test_operator
  in
  let system =
    System_new.add_location system test_location1 ~parent:test_organisation
      ~entrances:[ System_new.root_node ]
  in
  let attribute1 = System_new.Node.attribute "attribute1" Never in
  let attribute_maintainer =
    System_new.Node.attribute_maintainer "attribute_maintainer" Never
  in
  let system =
    System_new.add_attribute_maintainer_under_operator system
      ~operator:test_operator ~attribute_maintainer
  in
  let system =
    System_new.add_attribute system ~attribute:attribute1 ~attribute_maintainer
  in
  let system =
    System_new.add_permission_edge system ~operator:test_operator
      ~from:attribute1 ~to_:test_location1
  in
  try
    let _system =
      System_new.move_operator system ~operator:test_operator
        ~to_:test_location1
    in
    ()
  with _ -> print_endline "No permission";
  [%expect {| No permission |}]
