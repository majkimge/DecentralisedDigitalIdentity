open! Core
open Authentication_system

let print_system system =
  print_endline
    (Yojson.to_string (Authentication_system.System_new.to_json system))

let test_agent = System_new.Node.agent "test_agent"
let test_agent2 = System_new.Node.agent "test_agent2"
let test_system () = System_new.create test_agent "Test_system"
let test_resource1 = System_new.Node.resource "test_resource1"
let test_resource2 = System_new.Node.resource "test_resource2"
let test_resource3 = System_new.Node.resource "test_resource3"
let test_resource_handler = System_new.Node.resource_handler "test_resource_handler"

let%expect_test "create test" =
  let system = test_system () in
  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"resource","is_extension":false},{"id":"test_agent","group":"agent","is_extension":false}],"links":[{"source":"world","target":"test_agent","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_agent","group":"agent","is_extension":false},{"id":"world","group":"resource","is_extension":false}],"links":[{"source":"test_agent","target":"world","type":"simple"}]}} |}]

let%expect_test "add resource" =
  let system = test_system () in
  let system =
    System_new.add_resource system test_resource1 ~parent:System_new.root_node
      ~entrances:[ System_new.root_node ]
  in
  let system =
    System_new.add_resource system test_resource2 ~parent:test_resource1
      ~entrances:[ test_resource1 ]
  in
  let system =
    System_new.add_resource system test_resource3 ~parent:test_resource2
      ~entrances:[ test_resource1; test_resource2 ]
  in
  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"resource","is_extension":false},{"id":"test_resource1","group":"resource","is_extension":false},{"id":"test_agent","group":"agent","is_extension":false},{"id":"test_resource3","group":"resource","is_extension":false},{"id":"test_resource2","group":"resource","is_extension":false}],"links":[{"source":"world","target":"test_resource1","type":"simple"},{"source":"world","target":"test_agent","type":"simple"},{"source":"test_resource1","target":"test_resource3","type":"simple"},{"source":"test_resource1","target":"test_resource2","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_agent","group":"agent","is_extension":false},{"id":"world","group":"resource","is_extension":false},{"id":"test_resource1","group":"resource","is_extension":false},{"id":"test_resource2","group":"resource","is_extension":false},{"id":"test_resource3","group":"resource","is_extension":false}],"links":[{"source":"test_agent","target":"world","type":"simple"},{"source":"world","target":"test_resource1","type":"simple"},{"source":"test_resource1","target":"test_resource2","type":"simple"},{"source":"test_resource2","target":"test_resource3","type":"simple"}]}} |}]

let%expect_test "add resource_handler" =
  let system = test_system () in
  let system =
    System_new.add_resource_handler system ~resource_handler:test_resource_handler
      ~parent:System_new.root_node ~maintainer:test_agent
  in
  let system =
    System_new.add_resource system test_resource2 ~parent:test_resource_handler
      ~entrances:[ System_new.root_node ]
  in
  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"resource","is_extension":false},{"id":"test_resource2","group":"resource","is_extension":false},{"id":"test_agent","group":"agent","is_extension":false}],"links":[{"source":"world","target":"test_resource2","type":"simple"},{"source":"world","target":"test_agent","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_agent","group":"agent","is_extension":false},{"id":"world","group":"resource","is_extension":false},{"id":"test_resource_handler","group":"resource_handler","is_extension":false},{"id":"test_resource2","group":"resource","is_extension":false}],"links":[{"source":"test_agent","target":"test_resource_handler","type":"simple"},{"source":"test_agent","target":"world","type":"simple"},{"source":"world","target":"test_resource2","type":"simple"},{"source":"world","target":"test_resource_handler","type":"simple"},{"source":"test_resource_handler","target":"test_resource2","type":"simple"}]}} |}]

let%expect_test "add agent" =
  let system = test_system () in
  let system = System_new.add_agent system ~agent:test_agent2 in
  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"resource","is_extension":false},{"id":"test_agent2","group":"agent","is_extension":false},{"id":"test_agent","group":"agent","is_extension":false}],"links":[{"source":"world","target":"test_agent2","type":"simple"},{"source":"world","target":"test_agent","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_agent","group":"agent","is_extension":false},{"id":"test_agent2","group":"agent","is_extension":false},{"id":"world","group":"resource","is_extension":false}],"links":[{"source":"test_agent","target":"world","type":"simple"},{"source":"test_agent2","target":"world","type":"simple"}]}} |}]

let%expect_test "add attribute" =
  let system = test_system () in
  let attribute1 = System_new.Node.attribute "attribute1" Never in
  let attribute_handler =
    System_new.Node.attribute_handler "attribute_handler" Never
  in
  let system =
    System_new.add_attribute_handler_under_agent system
      ~agent:test_agent ~attribute_handler
  in
  let system =
    System_new.add_attribute system ~attribute:attribute1 ~attribute_handler
  in
  let attr_ref =
    System_new.get_attribute_by_id system
      (System_new.Node.attribute_id "attribute1")
  in
  let attribute2 =
    System_new.Node.attribute "attribute2" (Attribute_required attr_ref)
  in
  let system =
    System_new.add_attribute system ~attribute:attribute2 ~attribute_handler
  in
  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"resource","is_extension":false},{"id":"test_agent","group":"agent","is_extension":false}],"links":[{"source":"world","target":"test_agent","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_agent","group":"agent","is_extension":false},{"id":"world","group":"resource","is_extension":false},{"id":"attribute_handler","group":"attribute_handler","is_extension":false},{"id":"attribute1","group":"attribute","is_extension":false},{"id":"attribute2","group":"attribute","is_extension":false}],"links":[{"source":"test_agent","target":"attribute_handler","type":"simple"},{"source":"test_agent","target":"world","type":"simple"},{"source":"attribute_handler","target":"attribute2","type":"simple"},{"source":"attribute_handler","target":"attribute1","type":"simple"},{"source":"attribute1","target":"attribute2","type":"simple"}]}} |}]

let%expect_test "add permission" =
  let system = test_system () in
  let attribute1 = System_new.Node.attribute "attribute1" Never in
  let attribute_handler =
    System_new.Node.attribute_handler "attribute_handler" Never
  in

  let system =
    System_new.add_attribute_handler_under_agent system
      ~agent:test_agent ~attribute_handler
  in
  let system =
    System_new.add_attribute system ~attribute:attribute1 ~attribute_handler
  in

  let system =
    System_new.grant_attribute system ~agent:test_agent
      ~from:test_agent ~to_:attribute1
  in

  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"resource","is_extension":false},{"id":"test_agent","group":"agent","is_extension":false}],"links":[{"source":"world","target":"test_agent","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_agent","group":"agent","is_extension":false},{"id":"world","group":"resource","is_extension":false},{"id":"attribute_handler","group":"attribute_handler","is_extension":false},{"id":"attribute1","group":"attribute","is_extension":false}],"links":[{"source":"test_agent","target":"attribute1","type":"simple"},{"source":"test_agent","target":"attribute_handler","type":"simple"},{"source":"test_agent","target":"world","type":"simple"},{"source":"attribute_handler","target":"attribute1","type":"simple"}]}} |}]

let%expect_test "delete permission" =
  let system = test_system () in
  let attribute1 = System_new.Node.attribute "attribute1" Never in
  let attribute_handler =
    System_new.Node.attribute_handler "attribute_handler" Never
  in
  let system =
    System_new.add_attribute_handler_under_agent system
      ~agent:test_agent ~attribute_handler
  in
  let system =
    System_new.add_attribute system ~attribute:attribute1 ~attribute_handler
  in

  let system =
    System_new.grant_attribute system ~agent:test_agent
      ~from:test_agent ~to_:attribute1
  in

  let system =
    System_new.revoke_attribute system ~agent:test_agent
      ~from:test_agent ~to_:attribute1
  in

  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"resource","is_extension":false},{"id":"test_agent","group":"agent","is_extension":false}],"links":[{"source":"world","target":"test_agent","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_agent","group":"agent","is_extension":false},{"id":"world","group":"resource","is_extension":false},{"id":"attribute_handler","group":"attribute_handler","is_extension":false},{"id":"attribute1","group":"attribute","is_extension":false}],"links":[{"source":"test_agent","target":"attribute_handler","type":"simple"},{"source":"test_agent","target":"world","type":"simple"},{"source":"attribute_handler","target":"attribute1","type":"simple"}]}} |}]

let%expect_test "move_agent_success" =
  let system = test_system () in
  let system =
    System_new.add_resource_handler system ~resource_handler:test_resource_handler
      ~parent:System_new.root_node ~maintainer:test_agent
  in
  let system =
    System_new.add_resource system test_resource1 ~parent:test_resource_handler
      ~entrances:[ System_new.root_node ]
  in
  let attribute1 = System_new.Node.attribute "attribute1" Never in
  let attribute_handler =
    System_new.Node.attribute_handler "attribute_handler" Never
  in
  let system =
    System_new.add_attribute_handler_under_agent system
      ~agent:test_agent ~attribute_handler
  in
  let system =
    System_new.add_attribute system ~attribute:attribute1 ~attribute_handler
  in

  let system =
    System_new.grant_attribute system ~agent:test_agent
      ~from:test_agent ~to_:attribute1
  in
  let system =
    System_new.automatic_permission system ~agent:test_agent
      ~from:attribute1 ~to_:test_resource1
  in
  let system =
    System_new.move_agent system ~agent:test_agent ~to_:test_resource1
  in

  print_system system;
  [%expect
    {| {"position_tree":{"nodes":[{"id":"world","group":"resource","is_extension":false},{"id":"test_resource1","group":"resource","is_extension":false},{"id":"test_agent","group":"agent","is_extension":false}],"links":[{"source":"world","target":"test_resource1","type":"simple"},{"source":"test_resource1","target":"test_agent","type":"simple"}]},"permission_dag":{"nodes":[{"id":"test_agent","group":"agent","is_extension":false},{"id":"world","group":"resource","is_extension":false},{"id":"test_resource_handler","group":"resource_handler","is_extension":false},{"id":"attribute_handler","group":"attribute_handler","is_extension":false},{"id":"attribute1","group":"attribute","is_extension":false},{"id":"test_resource1","group":"resource","is_extension":false}],"links":[{"source":"test_agent","target":"attribute1","type":"simple"},{"source":"test_agent","target":"attribute_handler","type":"simple"},{"source":"test_agent","target":"test_resource_handler","type":"simple"},{"source":"test_agent","target":"world","type":"simple"},{"source":"world","target":"test_resource1","type":"simple"},{"source":"world","target":"test_resource_handler","type":"simple"},{"source":"test_resource_handler","target":"test_resource1","type":"simple"},{"source":"attribute_handler","target":"attribute1","type":"simple"},{"source":"attribute1","target":"test_resource1","type":"simple"}]}} |}]

let%expect_test "move_agent_fail" =
  let system = test_system () in
  let system =
    System_new.add_resource_handler system ~resource_handler:test_resource_handler
      ~parent:System_new.root_node ~maintainer:test_agent
  in
  let system =
    System_new.add_resource system test_resource1 ~parent:test_resource_handler
      ~entrances:[ System_new.root_node ]
  in
  let attribute1 = System_new.Node.attribute "attribute1" Never in
  let attribute_handler =
    System_new.Node.attribute_handler "attribute_handler" Never
  in
  let system =
    System_new.add_attribute_handler_under_agent system
      ~agent:test_agent ~attribute_handler
  in
  let system =
    System_new.add_attribute system ~attribute:attribute1 ~attribute_handler
  in
  let system =
    System_new.automatic_permission system ~agent:test_agent
      ~from:attribute1 ~to_:test_resource1
  in
  try
    let _system =
      System_new.move_agent system ~agent:test_agent
        ~to_:test_resource1
    in
    ()
  with _ ->
    print_endline "No permission";
    [%expect {| No permission |}]
