open! Core

module Node = struct
  type operator = string [@@deriving compare, equal, sexp_of]
  type location = string [@@deriving compare, equal, sexp_of]
  type organisation = string [@@deriving compare, equal, sexp_of]

  type attribute_id = { maintainer : operator; name : string }
  [@@deriving compare, equal, sexp_of]

  let attribute_id maintainer name = { maintainer; name }

  module Attribute_condition = struct
    type t = Attribute_id of attribute_id | And of t * t | Or of t * t
    [@@deriving compare, equal, sexp_of]
  end

  type attribute = {
    attribute_id : attribute_id;
    attribute_condition : Attribute_condition.t;
  }
  [@@deriving compare, equal, sexp_of]

  type _ t =
    | Operator : operator -> operator t
    | Location : location -> location t
    | Organisation : organisation -> organisation t
    | Attribute : attribute -> attribute t
  [@@deriving sexp_of]

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

module Position_tree = struct
  type t = { node : any_node; children : t ref list } [@@deriving sexp_of]

  let splice_node ~root (type a) ~(node_to_splice : a Node.t ref) (type b)
      ~(parent : b Node.t) =
    let rec splice_helper (current_node : t) visited_nodes =
      let { node; children } = current_node in
      if
        List.exists !visited_nodes ~f:(fun visited_node ->
            any_node_equal visited_node node)
      then current_node
      else if any_node_equal node (Any parent) then
        {
          current_node with
          children =
            ref
              {
                node = Any !node_to_splice;
                children =
                  (match !node_to_splice with
                  | Operator _ -> []
                  | _ -> [ ref current_node ]);
              }
            :: children;
        }
      else
        let () = visited_nodes := node :: !visited_nodes in
        {
          current_node with
          children =
            List.map current_node.children ~f:(fun child_ref ->
                ref (splice_helper !child_ref visited_nodes));
        }
    in
    splice_helper root (ref [])

  let find_node t (type a) (node_to_find : a Node.t) =
    let rec find_helper (current_node : t ref) visited_nodes =
      let { node; children } = !current_node in
      if
        List.exists !visited_nodes ~f:(fun visited_node ->
            any_node_equal visited_node node)
      then None
      else if any_node_equal node (Any node_to_find) then Some current_node
      else
        let () = visited_nodes := node :: !visited_nodes in
        let results =
          List.map children ~f:(fun child_ref ->
              find_helper child_ref visited_nodes)
        in
        List.find results ~f:Option.is_some |> Option.join
    in

    find_helper t (ref [])

  let add_edge t (type a) (from : a Node.t) (type b) (to_ : b Node.t) =
    let from_ref = find_node t from in
    let to_ref = find_node t to_ in
    match (from_ref, to_ref) with
    | Some from_ref, Some to_ref ->
        from_ref := { !from_ref with children = to_ref :: !from_ref.children };
        to_ref := { !to_ref with children = from_ref :: !to_ref.children }
    | _ -> ()

  let _delete_node ~root (type a) ~(node_to_delete : a Node.t) =
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
  type dag_node = { node : any_node; nodes_to : dag_node ref list }
  [@@deriving sexp_of]
  (* nodes_to which I am pointing, nodes_from which I am being pointed to *)

  type t = { operators : dag_node ref list; root : dag_node ref }
  [@@deriving sexp_of]

  let add_operator t (operator : Node.operator Node.t) =
    {
      t with
      operators = ref { node = Any operator; nodes_to = [] } :: t.operators;
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
                        ref { node = Any node_to_add; nodes_to = [] }
                        :: !candidate.nodes_to;
                    }
                else candidate);
        }
    | _ ->
        let rec add_helper current_node visited_nodes =
          let { node; _ } = current_node in
          if
            List.exists !visited_nodes ~f:(fun visited_node ->
                any_node_equal visited_node node)
          then current_node
          else if any_node_equal node (Any parent) then
            {
              current_node with
              nodes_to =
                ref { node = Any node_to_add; nodes_to = [] }
                :: current_node.nodes_to;
            }
          else
            let () = visited_nodes := node :: !visited_nodes in
            {
              current_node with
              nodes_to =
                List.map current_node.nodes_to ~f:(fun neighbour ->
                    ref (add_helper !neighbour visited_nodes));
            }
        in
        { t with root = ref (add_helper !(t.root) (ref [])) }

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

  let add_edge t (type a) ~(from : a Node.t) (type b) ~(to_ : b Node.t) =
    let from_ref = find_node t from in
    let to_ref = find_node t to_ in
    match (from_ref, to_ref) with
    | Some from_ref, Some to_ref ->
        from_ref := { !from_ref with nodes_to = to_ref :: !from_ref.nodes_to }
    (* print_s [%sexp (!from_ref : dag_node)] *)
    | _ -> ()
end

type t = {
  position_tree : Position_tree.t ref;
  permission_dag : Permission_DAG.t;
}
[@@deriving sexp_of]

let create operator_node =
  let root_node = Node.location "root" in
  let root = { Position_tree.node = Any root_node; children = [] } in
  let position_tree =
    Position_tree.splice_node ~root ~node_to_splice:operator_node
      ~parent:root_node
  in
  let dag_root = { Permission_DAG.node = Any root_node; nodes_to = [] } in
  let dag_operator =
    { Permission_DAG.node = Any !operator_node; nodes_to = [] }
  in
  let permission_dag =
    { Permission_DAG.operators = [ ref dag_operator ]; root = ref dag_root }
  in
  Permission_DAG.add_edge permission_dag ~from:!operator_node ~to_:root_node;
  { position_tree = ref position_tree; permission_dag }

let add_location t location (type a) ~(parent : a Node.t) ~entrances =
  let { position_tree; permission_dag } = t in
  match entrances with
  | node :: tl ->
      let position_tree =
        Position_tree.splice_node ~root:!position_tree ~node_to_splice:location
          ~parent:node
      in
      List.iter tl ~f:(fun entrance ->
          Position_tree.add_edge (ref position_tree) !location entrance);
      let permission_dag =
        Permission_DAG.add_dag_node permission_dag ~node_to_add:!location
          ~parent
      in
      { position_tree = ref position_tree; permission_dag }
  | _ -> t

(* val add_organisation : t -> Node.organisation Node.t -> inside:'a Node.t -> t *)
let add_operator t ~operator =
  let { position_tree; permission_dag } = t in
  let root_node = Node.location "root" in
  let position_tree =
    Position_tree.splice_node ~root:!position_tree ~node_to_splice:operator
      ~parent:root_node
  in
  let permission_dag = Permission_DAG.add_operator permission_dag !operator in
  Permission_DAG.add_edge permission_dag ~from:!operator ~to_:root_node;
  { position_tree = ref position_tree; permission_dag }

let root_node = Node.location "root"

(* val splice_node : t -> node:Position_tree.t -> parent:'a Node.t -> t
   val routes : t -> Node.location Node.t -> Node.location Node.t list list
   val delete_location : t -> Node.location Node.t -> t
   val add_permission_edge : t -> from:'a Node.t -> to_:'a Node.t -> t

   val add_attribute :
     t -> Node.attribute Node.t -> maintainer:Node.operator Node.t -> t

   val delete_permission : t -> from:'a Node.t -> to_:'a Node.t -> t
   val is_transition_valid : current_state:t -> new_state:t -> bool *)
