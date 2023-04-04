open! Core
open! Yojson

module Node = struct
  type operator = string [@@deriving compare, equal, sexp_of]
  type location = string [@@deriving compare, equal, sexp_of]
  type organisation = string [@@deriving compare, equal, sexp_of]
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

  and attribute_maintainer = {
    attribute_maintainer_id : attribute_id;
    attribute_maintainer_condition : attribute_condition;
  }
  [@@deriving compare, equal, sexp_of]

  (* let attribute_condition_required attribute = Attribute_required attribute

     let attribute_condition_and cond1 cond2 = And (cond1, cond2)

     let attribute_condition_or cond1 cond2 = Or (cond1, cond2) *)

  type (_, _) t =
    | Operator : operator -> (operator, operator) t
    | Location : location -> (location, organisation) t
    | Organisation : organisation -> (organisation, organisation) t
    | Attribute_maintainer :
        attribute_maintainer
        -> (attribute_maintainer, attribute_maintainer) t
    | Attribute : attribute -> (attribute, attribute_maintainer) t
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
    | Operator operator -> operator
    | Location location -> location
    | Organisation organisation -> organisation
    | Attribute { attribute_id; _ } -> attribute_id
    | Attribute_maintainer { attribute_maintainer_id; _ } ->
        attribute_maintainer_id

  let type_string (type a b) (node : (a, b) t) =
    match node with
    | Operator _ -> "operator"
    | Location _ -> "location"
    | Organisation _ -> "organisation"
    | Attribute _ -> "attribute"
    | Attribute_maintainer _ -> "attribute_maintainer"

  let equal (type a c) (node1 : (a, c) t) (type b d) (node2 : (b, d) t) =
    match (node1, node2) with
    | Operator operator1, Operator operator2 ->
        equal_operator operator1 operator2
    | Location location1, Location location2 ->
        equal_location location1 location2
    | Organisation organisation1, Organisation organisation2 ->
        equal_organisation organisation1 organisation2
    | Attribute attribute1, Attribute attribute2 ->
        equal_attribute attribute1 attribute2
    | ( Attribute_maintainer attribute_maintainer1,
        Attribute_maintainer attribute_maintainer2 ) ->
        equal_attribute_maintainer attribute_maintainer1 attribute_maintainer2
    | _, _ -> false

  let attribute_id id = id
  let location name = Location name
  let operator name = Operator name
  let organisation name = Organisation name

  let attribute attribute_id attribute_condition =
    Attribute { attribute_id; attribute_condition }

  let attribute_node_of_attribute attribute = Attribute attribute

  let attribute_maintainer attribute_maintainer_id
      attribute_maintainer_condition =
    Attribute_maintainer
      { attribute_maintainer_id; attribute_maintainer_condition }

  let attribute_maintainer_node_of_attribute_maintainer attribute_maintainer =
    Attribute_maintainer attribute_maintainer
end

type any_node = Any : ('a, 'c) Node.t -> any_node [@@deriving sexp_of]

let any_node_equal node1 node2 =
  match (node1, node2) with Any node1, Any node2 -> Node.equal node1 node2

let any_node_name node = match node with Any node -> Node.name node

let any_node_type_string node =
  match node with Any node -> Node.type_string node

let any_to_string node = any_node_type_string node ^ any_node_name node

(* let any_is_maintainer node ~parent =
   match (node, parent) with
   | Any (Node.Attribute node), Any (Node.Operator parent) ->
       let { Node.attribute_id = { maintainer; _ }; _ } = node in
       String.equal maintainer parent
   | _ -> false *)

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

let any_to_attribute_maintainer = function
  | Any (Attribute_maintainer node) -> node
  | _ -> raise_s [%message "This is not an attribute maintainer node"]

(* let any_to_node : type a. any_node -> (a, c) Node.t = function
   |Any (Operator node) -> Node.Operator node
   |Any (Organisation node) -> Node.Organisation node
   |Any (Location node) -> Node.Location node
   |Any (Attribute node) -> Node.Attribute node
   |Any (Attribute_maintainer node) -> Node.attribute_maintainer node *)

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
                      | Operator _ -> []
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
end

module Permission_DAG = struct
  type dag_node = {
    node : any_node;
    nodes_to : dag_node ref list;
    nodes_from : dag_node ref list;
  }
  [@@deriving sexp_of]
  (* nodes_to which I am pointing, nodes_from which I am being pointed to *)

  type t = { operators : dag_node ref list; root : dag_node ref }
  [@@deriving sexp_of]

  let to_json t =
    let rec helper current_node visited =
      if String.Set.mem !visited (any_to_string current_node.node) then
        { nodes = []; links = [] }
      else
        (* let () =
             print_s
               [%message
                 (current_node.node : any_node)
                   (List.map current_node.nodes_to ~f:(fun node -> !node.node)
                     : any_node list)]
           in *)
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
        :: List.map t.operators ~f:(fun node_ref -> helper !node_ref visited))
    in
    `Assoc [ ("nodes", `List nodes); ("links", `List links) ]

  let to_string t = to_json t |> Yojson.to_string

  let add_operator t (operator : (Node.operator, Node.operator) Node.t) =
    {
      t with
      operators =
        ref { node = Any operator; nodes_to = []; nodes_from = [] }
        :: t.operators;
    }

  let add_dag_node t (type a c) ~(node_to_add : (a, c) Node.t) (type b d)
      ~(parent : (b, d) Node.t) =
    (* print_endline "Adding new node"; *)
    (* let () = print_s [%message (Any node_to_add : any_node)] in *)
    match parent with
    | Operator _ ->
        {
          t with
          operators =
            List.map t.operators ~f:(fun candidate ->
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
              List.exists t.operators ~f:(fun operator_ref ->
                  add_helper operator_ref visited)
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

    List.find_map (!t.root :: !t.operators) ~f:(fun node_ref ->
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
      List.exists (!t.root :: !t.operators) ~f:(fun node_ref ->
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

  let find_attribute_maintainer_by_id t attribute_maintainer_id_to_find =
    find t ~f:(fun node ->
        match !node.node with
        | Any (Node.Attribute_maintainer { attribute_maintainer_id; _ }) ->
            Node.equal_attribute_id attribute_maintainer_id
              attribute_maintainer_id_to_find
        | _ -> false)

  (* let _find_attribute_by_id t attribute_id_to_find =
     let rec find_helper current_node visited_nodes =
       let { node; _ } = current_node in
       if
         List.exists !visited_nodes ~f:(fun visited_node ->
             any_node_equal visited_node node)
       then None
       else
         match node with
         | Any
             ( Attribute { attribute_id; _ }
             | Any (Attribute_maintainer { attribute_maintainer_id; _ }) ) ->
             if Node.equal_attribute_id attribute_id attribute_id_to_find then
               Some (ref current_node)
             else
               let () = visited_nodes := node :: !visited_nodes in
               let results =
                 List.map current_node.nodes_to ~f:(fun node_ref ->
                     find_helper !node_ref visited_nodes)
               in
               List.find results ~f:Option.is_some |> Option.join
         | _ ->
             let () = visited_nodes := node :: !visited_nodes in
             let results =
               List.map current_node.nodes_to ~f:(fun node_ref ->
                   find_helper !node_ref visited_nodes)
             in
             List.find results ~f:Option.is_some |> Option.join
     in
     find_helper !(t.root) (ref []) *)

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
                | Any (Node.Attribute_maintainer attribute_maintainer) ->
                    Some (Node.Attribute_maintainer attribute_maintainer)
                | _ -> None)
        | None ->
            raise_s
              [%message
                "Could not find node in dag"
                  ~node:(Any attribute : any_node)
                  ~dag:(to_string !t : string)])
    | Attribute_maintainer _ as attribute_maintainer -> (
        let dag_node =
          find_attribute_maintainer_by_id t (Node.name attribute_maintainer)
        in
        match dag_node with
        | Some dag_node ->
            List.find_map !dag_node.nodes_from ~f:(fun parent_ref ->
                match !parent_ref.node with
                | Any (Node.Attribute_maintainer attribute_maintainer) ->
                    Some (Node.Attribute_maintainer attribute_maintainer)
                | _ -> None)
        | None ->
            raise_s
              [%message
                "Could not find node in dag"
                  ~node:(Any attribute_maintainer : any_node)
                  ~dag:(to_string !t : string)])
    | Location _ as node -> (
        let rec helper current_node =
          match current_node.node with
          | Any (Organisation organisation) ->
              Some (Node.Organisation organisation)
          | Any (Location _) ->
              (* print_s
                 [%message
                   "In node"
                     (current_node.node : any_node)
                     (List.map current_node.nodes_from ~f:(fun node -> !node.node)
                       : any_node List.t)]; *)
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
    | Organisation _ as node -> (
        let rec helper current_node =
          match current_node.node with
          | Any (Organisation organisation) ->
              Some (Node.Organisation organisation)
          | Any (Location _) ->
              (* print_s
                 [%message
                   "In node"
                     (current_node.node : any_node)
                     (List.map current_node.nodes_from ~f:(fun node -> !node.node)
                       : any_node List.t)]; *)
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
    | Operator _ as node -> Some node

  (* Has permission to the attribute if the condition associated with
      the attribute halts. Then can use that attribute to create
     permission path to other nodes. Even if we control the attribute_maintainer of
      some attribute, we do not assume we have the permission to that attribute.
     Similarly to like in file permissions owner might not have some permission despite
     being able to grant it to themselves. *)
  let has_permission t ~operator (type a c) (node : (a, c) Node.t) =
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
      | Any (Location _) | Any (Organisation _) | Any (Attribute_maintainer _)
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
            let in_operator =
              match current_node.node with
              | Any (Operator _) -> true
              | _ -> false
            in
            List.map current_node.nodes_to ~f:(fun node_ref ->
                if in_operator then helper !node_ref attributes_held
                else
                  match !node_ref.node with
                  | Any (Attribute { attribute_condition; _ }) ->
                      if met_conditions attribute_condition !attributes_held
                      then helper !node_ref attributes_held
                      else false
                  | Any
                      (Attribute_maintainer
                        { attribute_maintainer_condition; _ }) ->
                      if
                        met_conditions attribute_maintainer_condition
                          !attributes_held
                      then helper !node_ref attributes_held
                      else false
                  | _ -> helper !node_ref attributes_held)
            |> List.exists ~f:(fun res -> res)
    in
    match find_node t operator with
    | Some operator_ref -> helper !operator_ref (ref String.Set.empty)
    | None ->
        raise_s
          [%message
            "Could not find operator in dag"
              ~operator:(Any operator : any_node)
              ~dag:(to_string !t : string)]

  let can_add_permission_edge_to t
      (operator : (Node.operator, Node.operator) Node.t) (type a c)
      (node : (a, c) Node.t) =
    match node with
    | Node.Operator _ -> false
    | Organisation _ | Location _ -> (
        match node_maintainer t node with
        | Some node ->
            (* print_s [%sexp (node : (Node.organisation, Node.organisation) Node.t)]; *)
            has_permission t ~operator node
        | None ->
            print_s [%sexp "mistakemistakemistake"];
            false)
    | Attribute _ -> (
        let attribute_maintainer = node_maintainer t node in
        match attribute_maintainer with
        | Some attribute_maintainer ->
            has_permission t ~operator attribute_maintainer
        | None ->
            raise_s
              [%message
                "Could not find attribute maintainer"
                  ~attribute:(Any node : any_node)
                  ~dag:(to_string !t : string)])
    | Attribute_maintainer _ -> (
        let attribute_maintainer = node_maintainer t node in
        match attribute_maintainer with
        | Some attribute_maintainer ->
            has_permission t ~operator attribute_maintainer
        | None ->
            raise_s
              [%message
                "Could not find attribute maintainer"
                  ~attribute:(Any node : any_node)
                  ~dag:(to_string !t : string)])

  let _can_be_under t ~(operator : (Node.operator, Node.operator) Node.t)
      (type a c) ~(node : (a, c) Node.t) =
    match node with
    | Operator _ | Attribute _ | Attribute_maintainer _ -> false
    | Organisation _ -> true
    | Location _ ->
        Node.equal (Node.location "world") node
        || has_permission t ~operator node
end

type t = {
  name : string;
  position_tree : Position_tree.t ref;
  permission_dag : Permission_DAG.t;
}
[@@deriving sexp_of]

let create operator_node name =
  let root_node = Node.location "world" in
  let root = ref { Position_tree.node = Any root_node; children = [] } in

  let () =
    Position_tree.splice_node ~root ~node_to_splice:(ref operator_node)
      ~parent:root_node
  in

  let dag_root =
    { Permission_DAG.node = Any root_node; nodes_to = []; nodes_from = [] }
  in
  let dag_operator =
    { Permission_DAG.node = Any operator_node; nodes_to = []; nodes_from = [] }
  in
  let permission_dag =
    { Permission_DAG.operators = [ ref dag_operator ]; root = ref dag_root }
  in
  Permission_DAG.add_edge (ref permission_dag) ~from:operator_node
    ~to_:root_node;
  { name; position_tree = root; permission_dag }

let add_location t location (type a c) ~(parent : (a, c) Node.t) ~entrances =
  let { name; position_tree; permission_dag } = t in
  match entrances with
  | node :: tl ->
      let () =
        Position_tree.splice_node ~root:position_tree
          ~node_to_splice:(ref location) ~parent:node
      in
      List.iter tl ~f:(fun entrance ->
          Position_tree.add_edge position_tree location entrance);
      let permission_dag =
        Permission_DAG.add_dag_node permission_dag ~node_to_add:location ~parent
      in
      { name; position_tree; permission_dag }
  | _ -> t

let add_operator t ~operator =
  let { name; position_tree; permission_dag } = t in
  let root_node = Node.location "world" in
  let () =
    Position_tree.splice_node ~root:position_tree ~node_to_splice:(ref operator)
      ~parent:root_node
  in
  let permission_dag = Permission_DAG.add_operator permission_dag operator in
  Permission_DAG.add_edge (ref permission_dag) ~from:operator ~to_:root_node;
  { name; position_tree; permission_dag }

let root_node = Node.location "world"

let add_organisation t ~(maintainer : (Node.operator, Node.operator) Node.t)
    ~(organisation : (Node.organisation, Node.organisation) Node.t) (type a c)
    ~(parent : (a, c) Node.t) =
  let { name; position_tree; permission_dag } = t in
  let permission_dag =
    Permission_DAG.add_dag_node permission_dag ~node_to_add:organisation ~parent
  in
  Permission_DAG.add_edge (ref permission_dag) ~from:maintainer
    ~to_:organisation;
  { name; position_tree; permission_dag }

let add_attribute t
    ~(attribute : (Node.attribute, Node.attribute_maintainer) Node.t)
    ~(attribute_maintainer :
       (Node.attribute_maintainer, Node.attribute_maintainer) Node.t) =
  match attribute with
  | Attribute { attribute_condition; _ } ->
      let { permission_dag; _ } = t in
      let permission_dag =
        Permission_DAG.add_dag_node permission_dag ~node_to_add:attribute
          ~parent:attribute_maintainer
      in
      let from =
        Node.attributes_from_condition attribute_condition
        |> List.map ~f:(fun condition_attribute ->
               Node.Attribute condition_attribute)
      in
      Permission_DAG.add_all_edges_exn (ref permission_dag) ~from ~to_:attribute;

      { t with permission_dag }

let add_attribute_maintainer_under_node t
    ~(attribute_maintainer :
       (Node.attribute_maintainer, Node.attribute_maintainer) Node.t) (type a c)
    ~(node : (a, c) Node.t) =
  match attribute_maintainer with
  | Attribute_maintainer { attribute_maintainer_condition; _ } ->
      let { permission_dag; _ } = t in
      let permission_dag =
        Permission_DAG.add_dag_node permission_dag
          ~node_to_add:attribute_maintainer ~parent:node
      in
      Node.attributes_from_condition attribute_maintainer_condition
      |> List.map ~f:(fun condition_attribute ->
             Node.Attribute condition_attribute)
      |> List.iter ~f:(fun condition_node ->
             Permission_DAG.add_edge (ref permission_dag) ~from:condition_node
               ~to_:attribute_maintainer);
      { t with permission_dag }

let add_attribute_maintainer_under_operator t
    ~(attribute_maintainer :
       (Node.attribute_maintainer, Node.attribute_maintainer) Node.t)
    ~(operator : (Node.operator, Node.operator) Node.t) =
  add_attribute_maintainer_under_node t ~attribute_maintainer ~node:operator

let add_attribute_maintainer_under_maintainer t
    ~(attribute_maintainer :
       (Node.attribute_maintainer, Node.attribute_maintainer) Node.t)
    ~(attribute_maintainer_maintainer :
       (Node.attribute_maintainer, Node.attribute_maintainer) Node.t) =
  add_attribute_maintainer_under_node t ~attribute_maintainer
    ~node:attribute_maintainer_maintainer

let add_permission_edge t ~operator (type a c) ~(from : (a, c) Node.t)
    (type b d) ~(to_ : (b, d) Node.t) =
  let { permission_dag; _ } = t in
  let permission_dag_ref = ref permission_dag in
  match
    Permission_DAG.can_add_permission_edge_to permission_dag_ref operator to_
  with
  | true ->
      let () = Permission_DAG.add_edge permission_dag_ref ~from ~to_ in
      { t with permission_dag = !permission_dag_ref }
  | false ->
      raise_s
        [%message
          "No permission to add edge"
            ~permission_dag:(Permission_DAG.to_string permission_dag : string)
            (operator : (Node.operator, Node.operator) Node.t)
            ~from:(Any from : any_node)
            ~to_:(Any to_ : any_node)]

let delete_permission_edge t ~operator ~node =
  let { permission_dag; _ } = t in
  let permission_dag_ref = ref permission_dag in
  match
    Permission_DAG.can_add_permission_edge_to permission_dag_ref operator node
  with
  | true ->
      let () =
        Permission_DAG.delete_edge permission_dag_ref ~from:operator ~to_:node
      in
      { t with permission_dag = !permission_dag_ref }
  | false ->
      raise_s
        [%message
          "No permission to add edge"
            ~permission_dag:(Permission_DAG.to_string permission_dag : string)
            (operator : (Node.operator, Node.operator) Node.t)
            ~node:(Any node : any_node)]

let can_access t ~operator ~node =
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
            | Any (Operator _) -> helper !child_ref visited
            | Any (Location location) ->
                if
                  Permission_DAG.has_permission (ref permission_dag) ~operator
                    (Location location)
                then helper !child_ref visited
                else false
            | _ -> false)
        |> List.exists ~f:(fun result -> result)
  in
  match Position_tree.find_parent position_tree operator with
  | Some parent -> helper !parent (ref String.Set.empty)
  | None ->
      raise_s
        [%message
          "Node not found"
            ~position_tree:(Position_tree.to_string !position_tree : string)]

let move_operator t ~(operator : (Node.operator, Node.operator) Node.t)
    (type a c) ~(to_ : (a, c) Node.t) =
  let { name = _; position_tree; permission_dag } = t in
  match can_access t ~operator ~node:to_ with
  | true ->
      let position_tree =
        ref
          (Position_tree.delete_node ~root:!position_tree
             ~node_to_delete:operator)
      in
      let () =
        Position_tree.splice_node ~root:position_tree
          ~node_to_splice:(ref operator) ~parent:to_
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

let get_attribute_maintainer_by_id t attribute_maintainer_id =
  match
    Permission_DAG.find_attribute_maintainer_by_id (ref t.permission_dag)
      attribute_maintainer_id
  with
  | Some attribute_maintainer ->
      !attribute_maintainer.node |> any_to_attribute_maintainer
  | None ->
      raise_s
        [%message
          "Could not find the desired attribute maintainer"
            attribute_maintainer_id
            (Yojson.to_string (Permission_DAG.to_json t.permission_dag))]

let to_json t =
  `Assoc
    [
      ("position_tree", Position_tree.to_json !(t.position_tree));
      ("permission_dag", Permission_DAG.to_json t.permission_dag);
    ]

(*
    val routes : t -> (Node.location, Node.organisation) Node.t -> (Node.location, Node.organisation) Node.t list list
    val delete_location : t -> (Node.location, Node.organisation) Node.t -> t
     *)
