open Core

module Identifier = struct
  type t = string
end

module Proof = struct
  type t = Fellow | Supervisee of Identifier.t
  type ts = t list

  let add_proof ts t = t :: ts
  let singleton t = [ t ]
  let empty = []

  let equal t1 t2 = 
    match t1,t2 with
    |Fellow, Fellow -> true
    |Supervisee a, Supervisee b -> String.equal a b 
    |_ -> false
end

module Permission = struct
  type t = In of Identifier.t | Out of Identifier.t
end

module KYP = struct
  type t = { permission : Permission.t; required_proofs : Proof.ts }
end

type entity = {
  identifier : Identifier.t;
  proofs : Proof.ts;
  kyps : KYP.t list;
}

let make_entity identifier proofs kyps = { identifier; proofs; kyps }

type t = Leaf of entity | Branch of entity * t list

let entity_of_node = function
  |Leaf entity -> entity
  |Branch (entity, _subtrees) -> entity

let root = ref (Leaf (make_entity "Pembroke" Proof.empty []))
let create identifier = Leaf (make_entity identifier Proof.empty [])

let splice_subtree ~current_state ~subtree ~new_parent =
  let rec splice = function
    | Leaf { identifier; proofs; kyps } as node ->
        if identifier = new_parent then
          Branch ({ identifier; proofs; kyps }, [ subtree ])
        else node
    | Branch ({ identifier; proofs; kyps }, subtrees) ->
        if identifier = new_parent then
          Branch ({ identifier; proofs; kyps }, subtree :: subtrees)
        else Branch ({ identifier; proofs; kyps }, List.map splice subtrees)
  in
  splice current_state

let required_proofs_met required_proofs proofs = List.for_all required_proofs ~f:(fun required_proof -> List.exists proofs ~f:(fun proof -> 
        Proof.equal required_proof proof))

let is_transition_valid ~current_state ~next_state = 
  let check_new_child child parent_in_current = 
    let is_child_of child_identifier parent = 
      match parent with 
      |Leaf _ -> false
      |Branch(_, subtrees) -> List.exists subtrees ~f:(fun node -> let {identifier;_} = entity_of_node node in String.equal identifier child_identifier)
    in
    match parent_in_current with 
    |Leaf _ -> false
    |Branch({identifier; proofs; kyps}, subtrees) -> let {identifier=child_identifier; proofs; kyps} = entity_of_node child in 
    List.exists subtrees ~f:(fun parent_node -> 
      let {identifier=parent_identifier;_}  = entity_of_node parent_node in
      List.exists kyps ~f:(fun kyp -> (match kyp with 
      |{permission = Out parent_identifier; required_proofs} -> required_proofs_met required_proofs proofs && is_child_of child_identifier parent_node
      |_ -> false)))
    in
    let rec check old_node new_node =
