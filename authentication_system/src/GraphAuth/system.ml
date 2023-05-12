open! Core
open! Yojson

module Node = struct
  type agent = string [@@deriving compare, equal, sexp_of]
  type resource = string [@@deriving compare, equal, sexp_of]
  type resource_handler = string [@@deriving compare, equal, sexp_of]
  type attribute_id = string [@@deriving compare, equal, sexp_of]

  type attribute_condition =
    | Always
    | Never
    | Attribute_required of attribute
    | And of attribute_condition * attribute_condition
    | Or of attribute_condition * attribute_condition
  [@@deriving compare, equal, sexp_of]

  and attribute = {
    attribute_id : attribute_id;
    attribute_condition : attribute_condition;
  }

  and attribute_handler = {
    attribute_handler_id : attribute_id;
    attribute_handler_condition : attribute_condition;
  }
  [@@deriving compare, equal, sexp_of]

  type (_, _) t =
    | Agent : agent -> (agent, agent) t
    | Resource : resource -> (resource, resource_handler) t
    | Resource_handler :
        resource_handler
        -> (resource_handler, resource_handler) t
    | Attribute_handler :
        attribute_handler
        -> (attribute_handler, attribute_handler) t
    | Attribute : attribute -> (attribute, attribute_handler) t
  [@@deriving sexp_of]

  let attributes_from_condition attribute_condition =
    let rec helper condition result =
      match condition with
      | Always | Never -> []
      | Attribute_required attribute -> attribute :: result
      | And (condition1, condition2) | Or (condition1, condition2) ->
          helper condition1 (helper condition2 result)
    in
    List.dedup_and_sort
      (helper attribute_condition [])
      ~compare:compare_attribute

  let name (type a b) (node : (a, b) t) =
    match node with
    | Agent agent -> agent
    | Resource resource -> resource
    | Resource_handler resource_handler -> resource_handler
    | Attribute { attribute_id; _ } -> attribute_id
    | Attribute_handler { attribute_handler_id; _ } -> attribute_handler_id

  let type_string (type a b) (node : (a, b) t) =
    match node with
    | Agent _ -> "agent"
    | Resource _ -> "resource"
    | Resource_handler _ -> "resource_handler"
    | Attribute _ -> "attribute"
    | Attribute_handler _ -> "attribute_handler"

  let equal (type a c) (node1 : (a, c) t) (type b d) (node2 : (b, d) t) =
    match (node1, node2) with
    | Agent agent1, Agent agent2 -> equal_agent agent1 agent2
    | Resource resource1, Resource resource2 ->
        equal_resource resource1 resource2
    | Resource_handler resource_handler1, Resource_handler resource_handler2 ->
        equal_resource_handler resource_handler1 resource_handler2
    | Attribute attribute1, Attribute attribute2 ->
        equal_attribute attribute1 attribute2
    | Attribute_handler attribute_handler1, Attribute_handler attribute_handler2
      ->
        equal_attribute_handler attribute_handler1 attribute_handler2
    | _, _ -> false

  let attribute_id id = id
  let resource name = Resource name
  let agent name = Agent name
  let resource_handler name = Resource_handler name

  let attribute attribute_id attribute_condition =
    Attribute { attribute_id; attribute_condition }

  let attribute_node_of_attribute attribute = Attribute attribute

  let attribute_handler attribute_handler_id attribute_handler_condition =
    Attribute_handler { attribute_handler_id; attribute_handler_condition }

  let attribute_handler_node_of_attribute_handler attribute_handler =
    Attribute_handler attribute_handler
end

type any_node = Any : ('a, 'c) Node.t -> any_node [@@deriving sexp_of]

let node_to_any node = Any node

let any_node_equal node1 node2 =
  match (node1, node2) with Any node1, Any node2 -> Node.equal node1 node2

let any_node_name node = match node with Any node -> Node.name node

let any_node_type_string node =
  match node with Any node -> Node.type_string node

let any_to_string node = any_node_type_string node ^ any_node_name node

let any_node_id node count =
  match node with
  | Any node ->
      if count = 0 then Node.name node
      else String.concat ~sep:"#" [ Node.name node; Int.to_string count ]

let any_node_is_extension count = match count with 0 -> false | _ -> true

let any_to_json node count =
  let group = any_node_type_string node in
  let id = any_node_id node count in
  `Assoc
    [
      ("id", `String id);
      ("group", `String group);
      ("is_extension", `Bool (any_node_is_extension count));
    ]

let any_to_attribute = function
  | Any (Attribute node) -> node
  | _ -> raise_s [%message "This is not an attribute node"]

let any_to_attribute_handler = function
  | Any (Attribute_handler node) -> node
  | _ -> raise_s [%message "This is not an attribute maintainer node"]

type json_helper = { nodes : Yojson.t list; links : Yojson.t list }

let json_helper_concat json_helpers =
  List.fold json_helpers ~init:{ nodes = []; links = [] }
    ~f:(fun acc json_helper ->
      let { nodes; links } = acc in
      { nodes = json_helper.nodes @ nodes; links = json_helper.links @ links })

module Position_tree = struct
  type t = { node : any_node; children : t ref list } [@@deriving sexp_of]

  let to_json t =
    let rec helper visited to_visit =
      match to_visit with
      | (current_node, parent) :: to_visit ->
          let count =
            match Map.find visited (any_node_name current_node.node) with
            | None -> 0
            | Some n -> n
          in
          let visited =
            Map.update visited (any_node_name current_node.node)
              ~f:(fun value -> match value with None -> 1 | Some n -> n + 1)
          in
          let new_node = any_to_json current_node.node count in
          let new_link =
            let link_type = "simple" in
            `Assoc
              [
                ("source", `String (any_node_name parent));
                ("target", `String (any_node_id current_node.node count));
                ("type", `String link_type);
              ]
          in
          let { nodes; links } =
            if count = 0 then
              helper visited
                (to_visit
                @ List.map current_node.children ~f:(fun child ->
                      (!child, current_node.node)))
            else helper visited to_visit
          in
          let links =
            match any_node_equal current_node.node parent with
            | true -> links
            | false -> if count = 0 then new_link :: links else links
          in

          { nodes = (if count = 0 then new_node :: nodes else nodes); links }
      | [] -> { nodes = []; links = [] }
    in
    let { nodes; links } = helper String.Map.empty [ (t, t.node) ] in
    `Assoc [ ("nodes", `List nodes); ("links", `List links) ]

  let _to_json_tree t =
    let rec helper current_node visited =
      let count =
        match Map.find !visited (any_node_name current_node.node) with
        | None -> 0
        | Some n -> n
      in
      visited :=
        Map.update !visited (any_node_name current_node.node) ~f:(fun value ->
            match value with None -> 1 | Some n -> n + 1);
      let children =
        if count = 0 then
          `List
            (List.map current_node.children ~f:(fun child_ref ->
                 helper !child_ref visited))
        else `List []
      in
      `Assoc
        [
          ("id", `String (any_node_id current_node.node count));
          ("children", children);
          ("group", `String (any_node_type_string current_node.node));
          ("is_extension", `Bool (any_node_is_extension count));
        ]
    in
    helper t (ref String.Map.empty)

  let to_string t = to_json t |> Yojson.to_string

  let splice_node ~root (type a c) ~(node_to_splice : (a, c) Node.t ref)
      (type b d) ~(parent : (b, d) Node.t) =
    let rec splice_helper (current_node : t ref) visited_nodes =
      let { node; children } = !current_node in
      if String.Set.mem !visited_nodes (any_to_string node) then false
      else if any_node_equal node (Any parent) then
        let () =
          current_node :=
            {
              !current_node with
              children =
                ref
                  {
                    node = Any !node_to_splice;
                    children =
                      (match !node_to_splice with
                      | Agent _ -> []
                      | _ -> [ current_node ]);
                  }
                :: children;
            }
        in
        true
      else
        let () =
          visited_nodes := String.Set.add !visited_nodes (any_to_string node)
        in
        List.exists !current_node.children ~f:(fun child_ref ->
            splice_helper child_ref visited_nodes)
    in
    let _ = splice_helper root (ref String.Set.empty) in
    ()

  let find t ~f =
    let rec find_helper (current_node : t ref) visited_nodes =
      let { node; children } = !current_node in
      if Set.mem !visited_nodes (any_to_string node) then None
      else if f current_node then Some current_node
      else
        let () =
          visited_nodes := String.Set.add !visited_nodes (any_to_string node)
        in
        List.find_map children ~f:(fun child_ref ->
            find_helper child_ref visited_nodes)
    in

    find_helper t (ref String.Set.empty)

  let find_node t (type a c) (node_to_find : (a, c) Node.t) =
    find t ~f:(fun node -> any_node_equal !node.node (Any node_to_find))

  let find_parent t (type a c) (node_to_find : (a, c) Node.t) =
    find t ~f:(fun node ->
        List.exists !node.children ~f:(fun child_ref ->
            any_node_equal !child_ref.node (Any node_to_find)))

  let add_edge t (type a c) (from : (a, c) Node.t) (type b d)
      (to_ : (b, d) Node.t) =
    let from_ref = find_node t from in
    let to_ref = find_node t to_ in
    match (from_ref, to_ref) with
    | Some from_ref, Some to_ref ->
        from_ref := { !from_ref with children = to_ref :: !from_ref.children };
        to_ref := { !to_ref with children = from_ref :: !to_ref.children }
    | None, _ ->
        raise_s
          [%message
            "Could not find node in tree"
              ~node:(Any from : any_node)
              ~tree:(to_string !t : string)]
    | _, None ->
        raise_s
          [%message
            "Could not find node in tree"
              ~node:(Any to_ : any_node)
              ~tree:(to_string !t : string)]

  let delete_node ~root (type a c) ~(node_to_delete : (a, c) Node.t) =
    let rec delete_helper (current_node : t) visited_nodes =
      let { node; children } = current_node in
      if Set.mem !visited_nodes (any_to_string node) then current_node
      else
        let new_children =
          List.filter children ~f:(fun child_ref ->
              not (any_node_equal (Any node_to_delete) !child_ref.node))
        in
        let () =
          visited_nodes := String.Set.add !visited_nodes (any_to_string node)
        in
        {
          current_node with
          children =
            List.map new_children ~f:(fun child_ref ->
                ref (delete_helper !child_ref visited_nodes));
        }
    in
    delete_helper root (ref String.Set.empty)

  let trim t set =
    let copy = !t in
    let ref_copy = ref copy in
    let visited = ref String.Set.empty in
    let rec helper current_node =
      match !current_node.node with
      | Any node ->
          if String.Set.mem !visited (Node.name node) then current_node
          else
            let () = visited := String.Set.add !visited (Node.name node) in
            let curr_node =
              ref
                {
                  !current_node with
                  children =
                    List.filter !current_node.children ~f:(fun node ->
                        match !node.node with
                        | Any node -> String.Set.mem set (Node.name node));
                }
            in
            let curr_node =
              ref
                {
                  !curr_node with
                  children =
                    List.map !curr_node.children ~f:(fun node -> helper node);
                }
            in
            curr_node
    in
    helper ref_copy
end

module Permission_DAG = struct
  type dag_node = {
    node : any_node;
    nodes_to : dag_node ref list;
    nodes_from : dag_node ref list;
  }
  [@@deriving sexp_of]
  (* nodes_to which I am pointing, nodes_from which I am being pointed to *)

  type t = { agents : dag_node ref list; root : dag_node ref }
  [@@deriving sexp_of]

  let to_json t =
    let rec helper current_node visited =
      if String.Set.mem !visited (any_to_string current_node.node) then
        { nodes = []; links = [] }
      else
        let () =
          visited := String.Set.add !visited (any_to_string current_node.node)
        in
        let { nodes; links } =
          json_helper_concat
            (List.map current_node.nodes_to ~f:(fun node_ref ->
                 helper !node_ref visited))
        in
        {
          nodes = any_to_json current_node.node 0 :: nodes;
          links =
            List.map current_node.nodes_to ~f:(fun node_ref ->
                let link_type = "simple" in
                `Assoc
                  [
                    ("source", `String (any_node_name current_node.node));
                    ("target", `String (any_node_name !node_ref.node));
                    ("type", `String link_type);
                  ])
            @ links;
        }
    in
    let visited = ref String.Set.empty in
    let { nodes; links } =
      json_helper_concat
        (helper !(t.root) visited
        :: List.map t.agents ~f:(fun node_ref -> helper !node_ref visited))
    in
    `Assoc [ ("nodes", `List nodes); ("links", `List links) ]

  let to_string t = to_json t |> Yojson.to_string

  let add_agent t (agent : (Node.agent, Node.agent) Node.t) =
    {
      t with
      agents =
        ref { node = Any agent; nodes_to = []; nodes_from = [] } :: t.agents;
    }

  let add_dag_node t (type a c) ~(node_to_add : (a, c) Node.t) (type b d)
      ~(parent : (b, d) Node.t) =
    (* print_endline "Adding new node"; *)
    (* let () = print_s [%message (Any node_to_add : any_node)] in *)
    match parent with
    | Agent _ ->
        {
          t with
          agents =
            List.map t.agents ~f:(fun candidate ->
                let { node; _ } = !candidate in
                if any_node_equal node (Any parent) then
                  let () =
                    candidate :=
                      {
                        !candidate with
                        nodes_to =
                          ref
                            {
                              node = Any node_to_add;
                              nodes_to = [];
                              nodes_from = [ candidate ];
                            }
                          :: !candidate.nodes_to;
                      }
                  in
                  candidate
                else candidate);
        }
    | _ ->
        let rec add_helper current_node visited_nodes =
          (* print_s [%sexp (!current_node.node : any_node)]; *)
          let { node; _ } = !current_node in
          if Set.mem !visited_nodes (any_to_string node) then false
          else if any_node_equal node (Any parent) then
            let () =
              current_node :=
                {
                  !current_node with
                  nodes_to =
                    ref
                      {
                        node = Any node_to_add;
                        nodes_to = [];
                        nodes_from = [ current_node ];
                      }
                    :: !current_node.nodes_to;
                }
            in
            true
          else
            let () =
              visited_nodes :=
                String.Set.add !visited_nodes (any_to_string node)
            in

            List.exists !current_node.nodes_to ~f:(fun neighbour ->
                add_helper neighbour visited_nodes)
        in

        let visited = ref String.Set.empty in
        let found = add_helper t.root visited in
        let () =
          if not found then
            let _ =
              List.exists t.agents ~f:(fun agent_ref ->
                  add_helper agent_ref visited)
            in
            ()
        in
        t

  let find t ~f =
    let rec find_helper current_node visited_nodes =
      let { node; _ } = !current_node in
      if Set.mem !visited_nodes (any_to_string node) then None
      else if f current_node then Some current_node
      else
        let () =
          visited_nodes := String.Set.add !visited_nodes (any_to_string node)
        in

        List.find_map !current_node.nodes_to ~f:(fun node_ref ->
            find_helper node_ref visited_nodes)
    in

    let visited_nodes = ref String.Set.empty in

    List.find_map (!t.root :: !t.agents) ~f:(fun node_ref ->
        find_helper node_ref visited_nodes)

  let find_all_nodes t nodes_to_find =
    (* print_endline "Finding new nodes"; *)
    let rec find_helper current_node visited_nodes found_nodes =
      (* print_s [%sexp (!current_node.node : any_node)]; *)
      if String.Set.length nodes_to_find = List.length !found_nodes then ()
      else
        let { node; _ } = !current_node in
        if Set.mem !visited_nodes (any_to_string node) then ()
        else
          let () =
            if String.Set.mem nodes_to_find (any_to_string !current_node.node)
            then found_nodes := current_node :: !found_nodes
          in
          let () =
            visited_nodes := String.Set.add !visited_nodes (any_to_string node)
          in
          let _ =
            List.exists !current_node.nodes_to ~f:(fun node_ref ->
                find_helper node_ref visited_nodes found_nodes;
                String.Set.length nodes_to_find = List.length !found_nodes)
          in
          ()
    in
    let visited_nodes = ref String.Set.empty in
    let found_nodes = ref [] in
    let _ =
      List.exists (!t.root :: !t.agents) ~f:(fun node_ref ->
          find_helper node_ref visited_nodes found_nodes;
          String.Set.length nodes_to_find = List.length !found_nodes)
    in
    if String.Set.length nodes_to_find = List.length !found_nodes then
      !found_nodes
    else
      raise_s
        [%message
          "Couldn't find the nodes"
            (nodes_to_find : String.Set.t)
            (!found_nodes : dag_node ref list)]

  let find_node t (type a c) (node_to_find : (a, c) Node.t) =
    find t ~f:(fun node -> any_node_equal !node.node (Any node_to_find))

  let find_attribute_by_id t attribute_id_to_find =
    find t ~f:(fun node ->
        match !node.node with
        | Any (Node.Attribute { attribute_id; _ }) ->
            Node.equal_attribute_id attribute_id attribute_id_to_find
        | _ -> false)

  let find_attribute_handler_by_id t attribute_handler_id_to_find =
    find t ~f:(fun node ->
        match !node.node with
        | Any (Node.Attribute_handler { attribute_handler_id; _ }) ->
            Node.equal_attribute_id attribute_handler_id
              attribute_handler_id_to_find
        | _ -> false)

  let add_edge t (type a c) ~(from : (a, c) Node.t) (type b d)
      ~(to_ : (b, d) Node.t) =
    let from_ref = find_node t from in
    let to_ref = find_node t to_ in
    match (from_ref, to_ref) with
    | Some from_ref, Some to_ref ->
        from_ref := { !from_ref with nodes_to = to_ref :: !from_ref.nodes_to };
        to_ref := { !to_ref with nodes_from = from_ref :: !to_ref.nodes_from }
    | None, _ ->
        raise_s
          [%message
            "Could not find node in dag"
              ~node:(Any from : any_node)
              ~dag:(to_string !t : string)]
    | _, None ->
        raise_s
          [%message
            "Could not find node in dag"
              ~node:(Any to_ : any_node)
              ~dag:(to_string !t : string)]

  let add_all_edges_exn t (type a c) ~(from : (a, c) Node.t list) (type b d)
      ~(to_ : (b, d) Node.t) =
    let from_names = List.map from ~f:(fun node -> any_to_string (Any node)) in
    let from_refs = find_all_nodes t (String.Set.of_list from_names) in
    let to_ref = find_node t to_ in
    match to_ref with
    | Some to_ref ->
        List.iter from_refs ~f:(fun from_ref ->
            from_ref :=
              { !from_ref with nodes_to = to_ref :: !from_ref.nodes_to };
            to_ref :=
              { !to_ref with nodes_from = from_ref :: !to_ref.nodes_from })
    | None ->
        raise_s
          [%message
            "Could not find node in dag"
              ~node:(Any to_ : any_node)
              ~dag:(to_string !t : string)]

  let delete_edge t (type a c) ~(from : (a, c) Node.t) (type b d)
      ~(to_ : (b, d) Node.t) =
    let from_ref = find_node t from in
    let to_ref = find_node t to_ in
    match (from_ref, to_ref) with
    | Some from_ref, Some to_ref ->
        from_ref :=
          {
            !from_ref with
            nodes_to =
              List.filter !from_ref.nodes_to ~f:(fun node_ref ->
                  not (any_node_equal !node_ref.node !to_ref.node));
          };
        to_ref :=
          {
            !to_ref with
            nodes_from =
              List.filter !to_ref.nodes_from ~f:(fun node_ref ->
                  not (any_node_equal !node_ref.node !from_ref.node));
          }
    | None, _ ->
        raise_s
          [%message
            "Could not find node in dag"
              ~node:(Any from : any_node)
              ~dag:(to_string !t : string)]
    | _, None ->
        raise_s
          [%message
            "Could not find node in dag"
              ~node:(Any to_ : any_node)
              ~dag:(to_string !t : string)]

  let node_maintainer : type a b. t ref -> (a, b) Node.t -> (b, b) Node.t option
      =
   fun t node ->
    match node with
    | Attribute _ as attribute -> (
        let dag_node = find_attribute_by_id t (Node.name attribute) in
        match dag_node with
        | Some dag_node ->
            List.find_map !dag_node.nodes_from ~f:(fun parent_ref ->
                match !parent_ref.node with
                | Any (Node.Attribute_handler attribute_handler) ->
                    Some (Node.Attribute_handler attribute_handler)
                | _ -> None)
        | None ->
            raise_s
              [%message
                "Could not find node in dag"
                  ~node:(Any attribute : any_node)
                  ~dag:(to_string !t : string)])
    | Attribute_handler _ as attribute_handler -> (
        let dag_node =
          find_attribute_handler_by_id t (Node.name attribute_handler)
        in
        match dag_node with
        | Some dag_node ->
            List.find_map !dag_node.nodes_from ~f:(fun parent_ref ->
                match !parent_ref.node with
                | Any (Node.Attribute_handler attribute_handler) ->
                    Some (Node.Attribute_handler attribute_handler)
                | _ -> None)
        | None ->
            raise_s
              [%message
                "Could not find node in dag"
                  ~node:(Any attribute_handler : any_node)
                  ~dag:(to_string !t : string)])
    | Resource _ as node -> (
        let rec helper current_node =
          match
            List.find_map current_node.nodes_from ~f:(fun parent ->
                match !parent.node with
                | Any (Node.Resource_handler res_handler) ->
                    Some (Node.Resource_handler res_handler)
                | _ -> None)
          with
          | Some handler -> Some handler
          | None -> (
              match
                List.find_map current_node.nodes_from ~f:(fun parent ->
                    match !parent.node with
                    | Any (Node.Resource _) -> Some !parent
                    | _ -> None)
              with
              | Some par -> helper par
              | None -> None)
        in
        match find_node t node with
        | Some node_ref -> helper !node_ref
        | None ->
            raise_s
              [%message
                "Could not find node in dag"
                  ~node:(Any node : any_node)
                  ~dag:(to_string !t : string)])
    | Resource_handler _ as node -> (
        let rec helper current_node =
          match current_node.node with
          | Any (Resource_handler resource_handler) ->
              Some (Node.Resource_handler resource_handler)
          | Any (Resource _) ->
              let results =
                List.map current_node.nodes_from ~f:(fun node_ref ->
                    helper !node_ref)
              in
              List.find results ~f:Option.is_some |> Option.join
          | _ -> None
        in
        match find_node t node with
        | Some node_ref ->
            let results =
              List.map !node_ref.nodes_from ~f:(fun node_ref ->
                  helper !node_ref)
            in
            List.find results ~f:Option.is_some |> Option.join
        | None ->
            raise_s
              [%message
                "Could not find node in dag"
                  ~node:(Any node : any_node)
                  ~dag:(to_string !t : string)])
    | Agent _ as node -> Some node

  let reaching t node_p =
    match find_node t node_p with
    | Some node ->
        let set = ref (String.Set.singleton (Node.name node_p)) in
        let rec helper current_node =
          List.iter current_node.nodes_from ~f:(fun parent ->
              let parent_node = !parent in
              match parent_node.node with
              | Any node ->
                  set := String.Set.add !set (Node.name node);
                  helper parent_node)
        in
        helper !node;
        !set
    | None ->
        raise_s
          [%message
            "Could not find handler in dag"
              ~handler:(Any node_p : any_node)
              ~dag:(to_string !t : string)]

  let trim t set =
    let copy = !t in
    let rec helper current_node =
      let new_node =
        {
          !current_node with
          nodes_to =
            List.filter !current_node.nodes_to ~f:(fun node_to ->
                match !node_to.node with
                | Any node_to -> String.Set.mem set (Node.name node_to));
        }
      in
      ref { new_node with nodes_to = List.map new_node.nodes_to ~f:helper }
    in
    { root = helper copy.root; agents = List.map copy.agents ~f:helper }

  let trim_list t nodes =
    let set =
      List.fold nodes ~init:String.Set.empty ~f:(fun set node ->
          match node with Any node -> String.Set.union set (reaching t node))
    in
    trim t set

  let handler_parent_resource t handler =
    let node =
      match find_node t handler with
      | Some node -> !node
      | None ->
          raise_s
            [%message
              "Could not find handler in dag"
                ~handler:(Any handler : any_node)
                ~dag:(to_string !t : string)]
    in
    let rec helper current_node =
      match
        List.find_map current_node.nodes_from ~f:(fun parent_node ->
            match !parent_node.node with
            | Any (Node.Resource res) -> Some (Node.Resource res)
            | _ -> None)
      with
      | Some parent_res -> parent_res
      | None -> (
          match
            List.find_map current_node.nodes_from ~f:(fun parent_node ->
                match !parent_node.node with
                | Any (Node.Resource_handler _) -> Some parent_node
                | _ -> None)
          with
          | Some parent_node -> helper !parent_node
          | None -> Node.Resource "world")
    in
    helper node

  (* Has permission to the attribute if the condition associated with
      the attribute halts. Then can use that attribute to create
     permission path to other nodes. Even if we control the attribute_handler of
      some attribute, we do not assume we have the permission to that attribute.
     Similarly to like in file permissions owner might not have some permission despite
     being able to grant it to themselves. *)
  let has_permission_helper t ~agent (type a c) (node : (a, c) Node.t) =
    let rec helper current_node attributes_held =
      let met_conditions attribute_condition attributes_held =
        let rec met_conditions_helper condition =
          match condition with
          | Node.Always -> true
          | Node.Never -> false
          | Node.Attribute_required attribute ->
              String.Set.mem attributes_held (Node.name (Attribute attribute))
          | And (cond1, cond2) ->
              met_conditions_helper cond1 && met_conditions_helper cond2
          | Or (cond1, cond2) ->
              met_conditions_helper cond1 || met_conditions_helper cond2
        in
        met_conditions_helper attribute_condition
      in
      match current_node.node with
      | Any (Resource _) | Any (Resource_handler _) | Any (Attribute_handler _)
        ->
          any_node_equal current_node.node (Any node)
      | _ ->
          if any_node_equal current_node.node (Any node) then true
          else
            let () =
              attributes_held :=
                match current_node.node with
                | Any (Attribute attribute) ->
                    String.Set.add !attributes_held
                      (Node.name (Attribute attribute))
                | _ -> !attributes_held
            in
            let in_agent =
              match current_node.node with Any (Agent _) -> true | _ -> false
            in
            List.map current_node.nodes_to ~f:(fun node_ref ->
                if in_agent then helper !node_ref attributes_held
                else
                  match !node_ref.node with
                  | Any (Attribute { attribute_condition; _ }) ->
                      if met_conditions attribute_condition !attributes_held
                      then helper !node_ref attributes_held
                      else false
                  | Any (Attribute_handler { attribute_handler_condition; _ })
                    ->
                      if
                        met_conditions attribute_handler_condition
                          !attributes_held
                      then helper !node_ref attributes_held
                      else false
                  | _ -> helper !node_ref attributes_held)
            |> List.exists ~f:(fun res -> res)
    in
    match find_node t agent with
    | Some agent_ref -> helper !agent_ref (ref String.Set.empty)
    | None ->
        raise_s
          [%message
            "Could not find agent in dag"
              ~agent:(Any agent : any_node)
              ~dag:(to_string !t : string)]

  let has_permission t ~agent (type a c) (node : (a, c) Node.t) =
    match node with
    | Node.Resource resource_node ->
        let rec chain_of_resources res_node current_node =
          if Node.equal res_node (Node.Resource "world") then [ res_node ]
          else
            let parent_resource, parent_node =
              List.find_map_exn current_node.nodes_from
                ~f:(fun potential_parent ->
                  match !potential_parent.node with
                  | Any (Node.Resource res) ->
                      Some (Node.Resource res, !potential_parent)
                  | _ -> None)
            in
            res_node :: chain_of_resources parent_resource parent_node
        in
        let found_node =
          match find_node t node with
          | Some nd -> nd
          | None ->
              raise_s
                [%message
                  "Could not find node in dag"
                    ~node:(Any node : any_node)
                    ~dag:(to_string !t : string)]
        in
        let chain =
          chain_of_resources (Node.Resource resource_node) !found_node
        in
        List.map chain ~f:(fun node -> has_permission_helper t ~agent node)
        |> List.for_all ~f:(fun b -> b)
    | _ -> has_permission_helper t ~agent node

  let can_add_permission_edge_to t (agent : (Node.agent, Node.agent) Node.t)
      (type a c) (node : (a, c) Node.t) =
    match node with
    | Node.Agent _ -> false
    | Resource_handler _ | Resource _ -> (
        match node_maintainer t node with
        | Some node1 ->
            (* print_s [%sexp (Node.name node1 : string)];
               print_s [%sexp (Node.name node : string)]; *)
            has_permission t ~agent node1
        | None ->
            print_s [%sexp "mistakemistakemistake"];
            false)
    | Attribute _ -> (
        let attribute_handler = node_maintainer t node in
        match attribute_handler with
        | Some attribute_handler -> has_permission t ~agent attribute_handler
        | None ->
            raise_s
              [%message
                "Could not find attribute maintainer"
                  ~attribute:(Any node : any_node)
                  ~dag:(to_string !t : string)])
    | Attribute_handler _ -> (
        let attribute_handler = node_maintainer t node in
        match attribute_handler with
        | Some attribute_handler -> has_permission t ~agent attribute_handler
        | None ->
            raise_s
              [%message
                "Could not find attribute maintainer"
                  ~attribute:(Any node : any_node)
                  ~dag:(to_string !t : string)])

  let _can_be_under t ~(agent : (Node.agent, Node.agent) Node.t) (type a c)
      ~(node : (a, c) Node.t) =
    match node with
    | Agent _ | Attribute _ | Attribute_handler _ -> false
    | Resource_handler _ -> true
    | Resource _ ->
        Node.equal (Node.resource "world") node || has_permission t ~agent node
end

type t = {
  name : string;
  position_tree : Position_tree.t ref;
  permission_dag : Permission_DAG.t;
}
[@@deriving sexp_of]

let create agent_node name =
  let root_node = Node.resource "world" in
  let root = ref { Position_tree.node = Any root_node; children = [] } in

  let () =
    Position_tree.splice_node ~root ~node_to_splice:(ref agent_node)
      ~parent:root_node
  in

  let dag_root =
    { Permission_DAG.node = Any root_node; nodes_to = []; nodes_from = [] }
  in
  let dag_agent =
    { Permission_DAG.node = Any agent_node; nodes_to = []; nodes_from = [] }
  in
  let permission_dag =
    { Permission_DAG.agents = [ ref dag_agent ]; root = ref dag_root }
  in
  Permission_DAG.add_edge (ref permission_dag) ~from:agent_node ~to_:root_node;
  { name; position_tree = root; permission_dag }

let add_resource t resource (type a)
    ~(parent : (a, Node.resource_handler) Node.t) ~entrances =
  let { name; position_tree; permission_dag } = t in
  match entrances with
  | node :: tl ->
      let () =
        Position_tree.splice_node ~root:position_tree
          ~node_to_splice:(ref resource) ~parent:node
      in
      List.iter tl ~f:(fun entrance ->
          Position_tree.add_edge position_tree resource entrance);
      let permission_dag =
        Permission_DAG.add_dag_node permission_dag ~node_to_add:resource ~parent
      in
      (match parent with
      | Node.Resource_handler _ ->
          Permission_DAG.add_edge (ref permission_dag)
            ~from:
              (Permission_DAG.handler_parent_resource (ref permission_dag)
                 parent)
            ~to_:resource
      | _ -> ());
      { name; position_tree; permission_dag }
  | _ -> t

let add_agent t ~agent =
  let { name; position_tree; permission_dag } = t in
  let root_node = Node.resource "world" in
  let () =
    Position_tree.splice_node ~root:position_tree ~node_to_splice:(ref agent)
      ~parent:root_node
  in
  let permission_dag = Permission_DAG.add_agent permission_dag agent in
  Permission_DAG.add_edge (ref permission_dag) ~from:agent ~to_:root_node;
  { name; position_tree; permission_dag }

let root_node = Node.resource "world"

let add_resource_handler t ~(maintainer : (Node.agent, Node.agent) Node.t)
    ~(resource_handler : (Node.resource_handler, Node.resource_handler) Node.t)
    (type a c) ~(parent : (a, c) Node.t) =
  let { name; position_tree; permission_dag } = t in
  let permission_dag =
    Permission_DAG.add_dag_node permission_dag ~node_to_add:resource_handler
      ~parent
  in
  Permission_DAG.add_edge (ref permission_dag) ~from:maintainer
    ~to_:resource_handler;
  { name; position_tree; permission_dag }

let add_attribute t
    ~(attribute : (Node.attribute, Node.attribute_handler) Node.t)
    ~(attribute_handler :
       (Node.attribute_handler, Node.attribute_handler) Node.t) =
  match attribute with
  | Attribute { attribute_condition; _ } ->
      let { permission_dag; _ } = t in
      let permission_dag =
        Permission_DAG.add_dag_node permission_dag ~node_to_add:attribute
          ~parent:attribute_handler
      in
      let from =
        Node.attributes_from_condition attribute_condition
        |> List.map ~f:(fun condition_attribute ->
               Node.Attribute condition_attribute)
      in
      Permission_DAG.add_all_edges_exn (ref permission_dag) ~from ~to_:attribute;

      { t with permission_dag }

let add_attribute_handler_under_node t
    ~(attribute_handler :
       (Node.attribute_handler, Node.attribute_handler) Node.t) (type a c)
    ~(node : (a, c) Node.t) =
  match attribute_handler with
  | Attribute_handler { attribute_handler_condition; _ } ->
      let { permission_dag; _ } = t in
      let permission_dag =
        Permission_DAG.add_dag_node permission_dag
          ~node_to_add:attribute_handler ~parent:node
      in
      Node.attributes_from_condition attribute_handler_condition
      |> List.map ~f:(fun condition_attribute ->
             Node.Attribute condition_attribute)
      |> List.iter ~f:(fun condition_node ->
             Permission_DAG.add_edge (ref permission_dag) ~from:condition_node
               ~to_:attribute_handler);
      { t with permission_dag }

let add_attribute_handler_under_agent t
    ~(attribute_handler :
       (Node.attribute_handler, Node.attribute_handler) Node.t)
    ~(agent : (Node.agent, Node.agent) Node.t) =
  add_attribute_handler_under_node t ~attribute_handler ~node:agent

let add_attribute_handler_under_maintainer t
    ~(attribute_handler :
       (Node.attribute_handler, Node.attribute_handler) Node.t)
    ~(attribute_handler_maintainer :
       (Node.attribute_handler, Node.attribute_handler) Node.t) =
  add_attribute_handler_under_node t ~attribute_handler
    ~node:attribute_handler_maintainer

let add_permission_edge t ~agent (type a c) ~(from : (a, c) Node.t) (type b d)
    ~(to_ : (b, d) Node.t) =
  let { permission_dag; _ } = t in
  let permission_dag_ref = ref permission_dag in
  match
    Permission_DAG.can_add_permission_edge_to permission_dag_ref agent to_
  with
  | true ->
      let () = Permission_DAG.add_edge permission_dag_ref ~from ~to_ in
      { t with permission_dag = !permission_dag_ref }
  | false ->
      raise_s
        [%message
          "No permission to add edge"
            ~permission_dag:(Permission_DAG.to_string permission_dag : string)
            (agent : (Node.agent, Node.agent) Node.t)
            ~from:(Any from : any_node)
            ~to_:(Any to_ : any_node)]

let grant_attribute t ~agent ~(from : (Node.agent, Node.agent) Node.t) (type b)
    ~(to_ : (b, Node.attribute_handler) Node.t) =
  add_permission_edge t ~agent ~from ~to_

let grant_access t ~agent ~(from : (Node.agent, Node.agent) Node.t) (type b)
    ~(to_ : (b, Node.resource_handler) Node.t) =
  add_permission_edge t ~agent ~from ~to_

let automatic_permission t ~agent
    ~(from : (Node.attribute, Node.attribute_handler) Node.t) (type b)
    ~(to_ : (b, Node.resource_handler) Node.t) =
  add_permission_edge t ~agent ~from ~to_

let delete_permission_edge t ~agent ~from ~to_ =
  let { permission_dag; _ } = t in
  let permission_dag_ref = ref permission_dag in
  match
    Permission_DAG.can_add_permission_edge_to permission_dag_ref agent to_
  with
  | true ->
      let () = Permission_DAG.delete_edge permission_dag_ref ~from ~to_ in
      { t with permission_dag = !permission_dag_ref }
  | false ->
      raise_s
        [%message
          "No permission to add edge"
            ~permission_dag:(Permission_DAG.to_string permission_dag : string)
            (agent : (Node.agent, Node.agent) Node.t)
            ~to_:(Any to_ : any_node)]

let revoke_attribute t ~agent ~(from : (Node.agent, Node.agent) Node.t) (type b)
    ~(to_ : (b, Node.attribute_handler) Node.t) =
  delete_permission_edge t ~agent ~from ~to_

let revoke_access t ~agent ~(from : (Node.agent, Node.agent) Node.t) (type b)
    ~(to_ : (b, Node.resource_handler) Node.t) =
  delete_permission_edge t ~agent ~from ~to_

let revoke_automatic_permission t ~agent
    ~(from : (Node.attribute, Node.attribute_handler) Node.t) (type b)
    ~(to_ : (b, Node.resource_handler) Node.t) =
  delete_permission_edge t ~agent ~from ~to_

let can_access t ~agent ~node =
  let { name = _; position_tree; permission_dag } = t in
  let rec helper (current_node : Position_tree.t) visited =
    if String.Set.mem !visited (any_to_string current_node.node) then false
    else
      let () =
        visited := String.Set.add !visited (any_to_string current_node.node)
      in
      if any_node_equal current_node.node (Any node) then true
      else
        List.map current_node.children ~f:(fun child_ref ->
            match !child_ref.node with
            | Any (Agent _) -> helper !child_ref visited
            | Any (Resource resource) ->
                if
                  Permission_DAG.has_permission (ref permission_dag) ~agent
                    (Resource resource)
                then helper !child_ref visited
                else false
            | _ -> false)
        |> List.exists ~f:(fun result -> result)
  in
  match Position_tree.find_parent position_tree agent with
  | Some parent -> helper !parent (ref String.Set.empty)
  | None ->
      raise_s
        [%message
          "Node not found"
            ~position_tree:(Position_tree.to_string !position_tree : string)]

let move_agent t ~(agent : (Node.agent, Node.agent) Node.t) (type a c)
    ~(to_ : (a, c) Node.t) =
  let { name = _; position_tree; permission_dag } = t in
  match can_access t ~agent ~node:to_ with
  | true ->
      let position_tree =
        ref
          (Position_tree.delete_node ~root:!position_tree ~node_to_delete:agent)
      in
      let () =
        Position_tree.splice_node ~root:position_tree
          ~node_to_splice:(ref agent) ~parent:to_
      in
      { t with position_tree }
  | false ->
      raise_s
        [%message
          "No permission to move"
            ~position_tree:(Position_tree.to_string !position_tree : string)
            ~permission_dag:(Permission_DAG.to_string permission_dag : string)]

let get_attribute_by_id t attribute_id =
  match
    Permission_DAG.find_attribute_by_id (ref t.permission_dag) attribute_id
  with
  | Some attribute -> !attribute.node |> any_to_attribute
  | None ->
      raise_s
        [%message
          "Could not find the desired attribute" attribute_id
            (Yojson.to_string (Permission_DAG.to_json t.permission_dag))]

let get_attribute_handler_by_id t attribute_handler_id =
  match
    Permission_DAG.find_attribute_handler_by_id (ref t.permission_dag)
      attribute_handler_id
  with
  | Some attribute_handler ->
      !attribute_handler.node |> any_to_attribute_handler
  | None ->
      raise_s
        [%message
          "Could not find the desired attribute maintainer" attribute_handler_id
            (Yojson.to_string (Permission_DAG.to_json t.permission_dag))]

let to_json t =
  `Assoc
    [
      ("position_tree", Position_tree.to_json !(t.position_tree));
      ("permission_dag", Permission_DAG.to_json t.permission_dag);
    ]

let trim t nodes =
  let set =
    List.fold nodes ~init:String.Set.empty ~f:(fun set node ->
        match node with
        | Any node ->
            String.Set.union set
              (Permission_DAG.reaching (ref t.permission_dag) node))
  in

  {
    t with
    permission_dag = Permission_DAG.trim_list (ref t.permission_dag) nodes;
    position_tree = Position_tree.trim t.position_tree set;
  }
