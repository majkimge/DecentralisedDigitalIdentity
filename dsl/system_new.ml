open! Core
open! Yojson

module Node = struct
  type operator = string [@@deriving compare, equal, sexp_of]
  type location = string [@@deriving compare, equal, sexp_of]
  type organisation = string [@@deriving compare, equal, sexp_of]

  type attribute_id = { maintainer : operator; name : string }
  [@@deriving compare, equal, sexp_of]

  let attribute_id maintainer name = { maintainer; name }

  type attribute_condition =
    | Attribute_required of attribute
    | And of attribute_condition * attribute_condition
    | Or of attribute_condition * attribute_condition
  [@@deriving compare, equal, sexp_of]

  and attribute = {
    attribute_id : attribute_id;
    attribute_condition : attribute_condition;
  }
  [@@deriving compare, equal, sexp_of]

  (* let attribute_condition_required attribute = Attribute_required attribute

     let attribute_condition_and cond1 cond2 = And (cond1, cond2)

     let attribute_condition_or cond1 cond2 = Or (cond1, cond2) *)

  let attributes_from_condition attribute_condition =
    let rec helper condition result =
      match condition with
      | Attribute_required attribute -> attribute :: result
      | And (condition1, condition2) | Or (condition1, condition2) ->
          helper condition1 (helper condition2 result)
    in
    List.dedup_and_sort
      (helper attribute_condition [])
      ~compare:compare_attribute

  type _ t =
    | Operator : operator -> operator t
    | Location : location -> location t
    | Organisation : organisation -> organisation t
    | Attribute : attribute -> attribute t
  [@@deriving sexp_of]

  let name (type a) (node : a t) =
    match node with
    | Operator operator -> operator
    | Location location -> location
    | Organisation organisation -> organisation
    | Attribute { attribute_id = { maintainer; name }; _ } ->
        String.concat ~sep:"#" [ maintainer; name ]

  let type_string (type a) (node : a t) =
    match node with
    | Operator _ -> "operator"
    | Location _ -> "location"
    | Organisation _ -> "organisation"
    | Attribute _ -> "attribute"

  let equal (type a) (node1 : a t) (type b) (node2 : b t) =
    match (node1, node2) with
    | Operator operator1, Operator operator2 ->
        equal_operator operator1 operator2
    | Location location1, Location location2 ->
        equal_location location1 location2
    | Organisation organisation1, Organisation organisation2 ->
        equal_organisation organisation1 organisation2
    | Attribute attribute1, Attribute attribute2 ->
        equal_attribute attribute1 attribute2
    | _, _ -> false

  let location name = Location name
  let operator name = Operator name
  let organisation name = Organisation name

  let attribute attribute_id attribute_condition =
    Attribute { attribute_id; attribute_condition }
end

type any_node = Any : 'a Node.t -> any_node [@@deriving sexp_of]

let any_node_equal node1 node2 =
  match (node1, node2) with Any node1, Any node2 -> Node.equal node1 node2

let any_node_name node = match node with Any node -> Node.name node

let any_node_type_string node =
  match node with Any node -> Node.type_string node

let any_is_maintainer node ~parent =
  match (node, parent) with
  | Any (Node.Attribute node), Any (Node.Operator parent) ->
      let { Node.attribute_id = { maintainer; _ }; _ } = node in
      String.equal maintainer parent
  | _ -> false

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

(* let any_to_node (type a) node : a Node.t =
   match node with
   |Any (Operator node) -> Node.Operator node
   |Any (Organisation node) -> Node.Organisation node
   |Any (Location node) -> Node.Location node
   |Any (Attribute node) -> Node.Attribute node *)

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
            let link_type =
              if any_is_maintainer current_node.node ~parent then "maintainer"
              else "simple"
            in
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
            | false -> new_link :: links
          in

          { nodes = new_node :: nodes; links }
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

  let splice_node ~root (type a) ~(node_to_splice : a Node.t ref) (type b)
      ~(parent : b Node.t) =
    let rec splice_helper (current_node : t ref) visited_nodes =
      let { node; children } = !current_node in
      if
        List.exists !visited_nodes ~f:(fun visited_node ->
            any_node_equal visited_node node)
      then ()
      else if any_node_equal node (Any parent) then
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
      else
        let () = visited_nodes := node :: !visited_nodes in

        List.iter !current_node.children ~f:(fun child_ref ->
            splice_helper child_ref visited_nodes)
    in

    splice_helper root (ref [])

  let find t ~f =
    let rec find_helper (current_node : t ref) visited_nodes =
      let { node; children } = !current_node in
      if
        List.exists !visited_nodes ~f:(fun visited_node ->
            any_node_equal visited_node node)
      then None
      else if f current_node then Some current_node
      else
        let () = visited_nodes := node :: !visited_nodes in
        let results =
          List.map children ~f:(fun child_ref ->
              find_helper child_ref visited_nodes)
        in
        List.find results ~f:Option.is_some |> Option.join
    in
    find_helper t (ref [])

  let find_node t (type a) (node_to_find : a Node.t) =
    find t ~f:(fun node -> any_node_equal !node.node (Any node_to_find))

  let find_parent t (type a) (node_to_find : a Node.t) =
    find t ~f:(fun node ->
        List.exists !node.children ~f:(fun child_ref ->
            any_node_equal !child_ref.node (Any node_to_find)))

  let add_edge t (type a) (from : a Node.t) (type b) (to_ : b Node.t) =
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

  let delete_node ~root (type a) ~(node_to_delete : a Node.t) =
    let rec delete_helper (current_node : t) visited_nodes =
      let { node; children } = current_node in
      if
        List.exists !visited_nodes ~f:(fun visited_node ->
            any_node_equal visited_node node)
      then current_node
      else
        let new_children =
          List.filter children ~f:(fun child_ref ->
              not (any_node_equal (Any node_to_delete) !child_ref.node))
        in
        let () = visited_nodes := node :: !visited_nodes in
        {
          current_node with
          children =
            List.map new_children ~f:(fun child_ref ->
                ref (delete_helper !child_ref visited_nodes));
        }
    in
    delete_helper root (ref [])
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
      if
        List.exists !visited ~f:(fun node ->
            any_node_equal current_node.node node)
      then { nodes = []; links = [] }
      else
        let () = visited := current_node.node :: !visited in
        let { nodes; links } =
          json_helper_concat
            (List.map current_node.nodes_to ~f:(fun node_ref ->
                 helper !node_ref visited))
        in
        {
          nodes = any_to_json current_node.node 0 :: nodes;
          links =
            List.map current_node.nodes_to ~f:(fun node_ref ->
                let link_type =
                  if any_is_maintainer !node_ref.node ~parent:current_node.node
                  then "maintainer"
                  else "simple"
                in
                `Assoc
                  [
                    ("source", `String (any_node_name current_node.node));
                    ("target", `String (any_node_name !node_ref.node));
                    ("type", `String link_type);
                  ])
            @ links;
        }
    in
    let visited = ref [] in
    let { nodes; links } =
      json_helper_concat
        (helper !(t.root) visited
        :: List.map t.operators ~f:(fun node_ref -> helper !node_ref visited))
    in
    `Assoc [ ("nodes", `List nodes); ("links", `List links) ]

  let to_string t = to_json t |> Yojson.to_string

  let add_operator t (operator : Node.operator Node.t) =
    {
      t with
      operators =
        ref { node = Any operator; nodes_to = []; nodes_from = [] }
        :: t.operators;
    }

  let add_dag_node t (type a) ~(node_to_add : a Node.t) (type b)
      ~(parent : b Node.t) =
    match parent with
    | Operator _ ->
        {
          t with
          operators =
            List.map t.operators ~f:(fun candidate ->
                let { node; _ } = !candidate in
                if any_node_equal node (Any parent) then
                  ref
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
                else candidate);
        }
    | _ ->
        let rec add_helper current_node visited_nodes =
          let { node; _ } = !current_node in
          if
            List.exists !visited_nodes ~f:(fun visited_node ->
                any_node_equal visited_node node)
          then !current_node
          else if any_node_equal node (Any parent) then
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
          else
            let () = visited_nodes := node :: !visited_nodes in
            {
              !current_node with
              nodes_to =
                List.map !current_node.nodes_to ~f:(fun neighbour ->
                    ref (add_helper neighbour visited_nodes));
            }
        in
        { t with root = ref (add_helper t.root (ref [])) }

  let find_node t (type a) (node_to_find : a Node.t) =
    match node_to_find with
    | Operator _ ->
        let open Option.Let_syntax in
        let%map found =
          List.find t.operators ~f:(fun operator ->
              let { node; _ } = !operator in
              any_node_equal node (Any node_to_find))
        in
        found
    | _ ->
        let rec find_helper current_node visited_nodes =
          let { node; _ } = current_node in
          if
            List.exists !visited_nodes ~f:(fun visited_node ->
                any_node_equal visited_node node)
          then None
          else if any_node_equal node (Any node_to_find) then
            Some (ref current_node)
          else
            let () = visited_nodes := node :: !visited_nodes in
            let results =
              List.map current_node.nodes_to ~f:(fun node_ref ->
                  find_helper !node_ref visited_nodes)
            in
            List.find results ~f:Option.is_some |> Option.join
        in
        find_helper !(t.root) (ref [])

  let _find_attribute_by_id t attribute_id_to_find =
    let rec find_helper current_node visited_nodes =
      let { node; _ } = current_node in
      if
        List.exists !visited_nodes ~f:(fun visited_node ->
            any_node_equal visited_node node)
      then None
      else
        match node with
        | Any (Attribute { attribute_id; _ }) ->
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
    find_helper !(t.root) (ref [])

  let add_edge t (type a) ~(from : a Node.t) (type b) ~(to_ : b Node.t) =
    let from_ref = find_node t from in
    let to_ref = find_node t to_ in
    match (from_ref, to_ref) with
    | Some from_ref, Some to_ref ->
        from_ref := { !from_ref with nodes_to = to_ref :: !from_ref.nodes_to };
        to_ref := { !to_ref with nodes_from = from_ref :: !to_ref.nodes_to }
    (* print_s [%sexp (!from_ref : dag_node)] *)
    | None, _ ->
        raise_s
          [%message
            "Could not find node in dag"
              ~node:(Any from : any_node)
              ~dag:(to_string t : string)]
    | _, None ->
        raise_s
          [%message
            "Could not find node in dag"
              ~node:(Any to_ : any_node)
              ~dag:(to_string t : string)]

  let delete_edge t (type a) ~(from : a Node.t) (type b) ~(to_ : b Node.t) =
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
    (* print_s [%sexp (!from_ref : dag_node)] *)
    | None, _ ->
        raise_s
          [%message
            "Could not find node in dag"
              ~node:(Any from : any_node)
              ~dag:(to_string t : string)]
    | _, None ->
        raise_s
          [%message
            "Could not find node in dag"
              ~node:(Any to_ : any_node)
              ~dag:(to_string t : string)]

  let governing_organisation_node t (type a) (node : a Node.t) =
    let rec helper current_node =
      match current_node.node with
      | Any (Organisation organisation) -> Some (Node.Organisation organisation)
      | Any (Location _) ->
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
          List.map !node_ref.nodes_from ~f:(fun node_ref -> helper !node_ref)
        in
        List.find results ~f:Option.is_some |> Option.join
    | None ->
        raise_s
          [%message
            "Could not find node in dag"
              ~node:(Any node : any_node)
              ~dag:(to_string t : string)]

  (* Has permission to the attribute if the condition associated with
      the attribute halts. Then can use that attribute to create
     permission path to other nodes.*)
  let has_permission t operator (type a) (node : a Node.t) =
    let rec helper current_node attributes_held =
      let met_conditions attribute_condition attributes_held =
        let rec met_conditions_helper condition =
          match condition with
          | Node.Attribute_required attribute ->
              List.exists attributes_held ~f:(fun attribute_candidate ->
                  Node.equal (Attribute attribute) attribute_candidate)
          | And (cond1, cond2) ->
              met_conditions_helper cond1 && met_conditions_helper cond2
          | Or (cond1, cond2) ->
              met_conditions_helper cond1 || met_conditions_helper cond2
        in
        met_conditions_helper attribute_condition
      in
      match current_node.node with
      | Any (Location _) | Any (Organisation _) ->
          any_node_equal current_node.node (Any node)
      | _ ->
          let () =
            attributes_held :=
              match current_node.node with
              | Any (Attribute attribute) ->
                  Node.Attribute attribute :: !attributes_held
              | _ -> !attributes_held
          in
          let in_operator =
            match current_node.node with Any (Operator _) -> true | _ -> false
          in
          List.map current_node.nodes_to ~f:(fun node_ref ->
              if in_operator then helper !node_ref attributes_held
              else
                match !node_ref.node with
                | Any (Attribute { attribute_condition; _ }) ->
                    if met_conditions attribute_condition !attributes_held then
                      helper !node_ref attributes_held
                    else false
                | _ -> helper !node_ref attributes_held)
          |> List.exists ~f:(fun res -> res)
    in
    match find_node t operator with
    | Some operator_ref -> helper !operator_ref (ref [])
    | None ->
        raise_s
          [%message
            "Could not find operator in dag"
              ~operator:(Any operator : any_node)
              ~dag:(to_string t : string)]

  let can_add_permission_edge_to t (operator : Node.operator Node.t) (type a)
      (node : a Node.t) =
    match node with
    | Node.Operator _ -> false
    | Organisation _ | Location _ -> (
        match governing_organisation_node t node with
        | Some node -> has_permission t operator node
        | None -> false)
    | Attribute { attribute_id = { maintainer; _ }; _ } ->
        Node.equal (Operator maintainer) operator

  let _can_be_under t ~(operator : Node.operator Node.t) (type a)
      ~(node : a Node.t) =
    match node with
    | Operator _ | Attribute _ -> false
    | Organisation _ -> true
    | Location _ ->
        Node.equal (Node.location "root") node || has_permission t operator node
end

type t = {
  position_tree : Position_tree.t ref;
  permission_dag : Permission_DAG.t;
}
[@@deriving sexp_of]

let create operator_node =
  let root_node = Node.location "root" in
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
  Permission_DAG.add_edge permission_dag ~from:operator_node ~to_:root_node;
  { position_tree = root; permission_dag }

let add_location t location (type a) ~(parent : a Node.t) ~entrances =
  let { position_tree; permission_dag } = t in
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
      { position_tree; permission_dag }
  | _ -> t

(* val add_organisation : t -> Node.organisation Node.t -> inside:'a Node.t -> t *)
let add_operator t ~operator =
  let { position_tree; permission_dag } = t in
  let root_node = Node.location "root" in
  let () =
    Position_tree.splice_node ~root:position_tree ~node_to_splice:(ref operator)
      ~parent:root_node
  in
  let permission_dag = Permission_DAG.add_operator permission_dag operator in
  Permission_DAG.add_edge permission_dag ~from:operator ~to_:root_node;
  { position_tree; permission_dag }

let root_node = Node.location "root"

let add_organisation t ~(maintainer : Node.operator Node.t)
    ~(organisation : Node.organisation Node.t) (type a) ~(parent : a Node.t) =
  let { position_tree; permission_dag } = t in
  let permission_dag =
    Permission_DAG.add_dag_node permission_dag ~node_to_add:organisation ~parent
  in
  Permission_DAG.add_edge permission_dag ~from:maintainer ~to_:organisation;
  { position_tree; permission_dag }

let add_attribute t ~(attribute : Node.attribute Node.t) =
  match attribute with
  | Attribute { attribute_id = { maintainer; _ }; attribute_condition } ->
      let { permission_dag; _ } = t in
      let permission_dag =
        Permission_DAG.add_dag_node permission_dag ~node_to_add:attribute
          ~parent:(Node.operator maintainer)
      in
      Node.attributes_from_condition attribute_condition
      |> List.map ~f:(fun condition_attribute ->
             Node.Attribute condition_attribute)
      |> List.iter ~f:(fun condition_node ->
             Permission_DAG.add_edge permission_dag ~from:condition_node
               ~to_:attribute);
      { t with permission_dag }

let add_permission_edge t ~operator ~from ~to_ =
  let { permission_dag; _ } = t in
  match
    Permission_DAG.can_add_permission_edge_to permission_dag operator to_
  with
  | true -> Permission_DAG.add_edge permission_dag ~from ~to_
  | false ->
      raise_s
        [%message
          "No permission to add edge"
            ~permission_dag:(Permission_DAG.to_string permission_dag : string)
            (operator : Node.operator Node.t)
            (from : Node.operator Node.t)
            ~to_:(Any to_ : any_node)]

let delete_permission_edge t ~operator ~node =
  let { permission_dag; _ } = t in
  match
    Permission_DAG.can_add_permission_edge_to permission_dag operator node
  with
  | true -> Permission_DAG.delete_edge permission_dag ~from:operator ~to_:node
  | false ->
      raise_s
        [%message
          "No permission to add edge"
            ~permission_dag:(Permission_DAG.to_string permission_dag : string)
            (operator : Node.operator Node.t)
            ~node:(Any node : any_node)]

let can_access t ~operator ~node =
  let { position_tree; permission_dag } = t in
  let rec helper (current_node : Position_tree.t) visited =
    if
      List.exists !visited ~f:(fun node ->
          any_node_equal current_node.node node)
    then false
    else
      let () = visited := current_node.node :: !visited in
      if any_node_equal current_node.node (Any node) then true
      else
        List.map current_node.children ~f:(fun child_ref ->
            match !child_ref.node with
            | Any (Operator _) -> helper !child_ref visited
            | Any (Location location) ->
                if
                  Permission_DAG.has_permission permission_dag operator
                    (Location location)
                then helper !child_ref visited
                else false
            | _ -> false)
        |> List.exists ~f:(fun result -> result)
  in
  match Position_tree.find_parent position_tree operator with
  | Some parent -> helper !parent (ref [])
  | None ->
      raise_s
        [%message
          "Node not found"
            ~position_tree:(Position_tree.to_string !position_tree : string)]

let move_operator t ~(operator : Node.operator Node.t) (type a)
    ~(to_ : a Node.t) =
  let { position_tree; permission_dag } = t in
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

let to_json t =
  `Assoc
    [
      ("position_tree", Position_tree.to_json !(t.position_tree));
      ("permission_dag", Permission_DAG.to_json t.permission_dag);
    ]

(* val splice_node : t -> node:Position_tree.t -> parent:'a Node.t -> t
   val routes : t -> Node.location Node.t -> Node.location Node.t list list
   val delete_location : t -> Node.location Node.t -> t
   val add_permission_edge : t -> from:'a Node.t -> to_:'a Node.t -> t

   val add_attribute :
     t -> Node.attribute Node.t -> maintainer:Node.operator Node.t -> t

   val delete_permission : t -> from:'a Node.t -> to_:'a Node.t -> t
   val is_transition_valid : current_state:t -> new_state:t -> bool *)
