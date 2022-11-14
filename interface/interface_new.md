
```ocaml

(* Assumptions of the [Identifier] are such that it should be unique and shouldn't allow for impersonation. *)

module Identifier : sig
    type t
    type secret
    val generate_secret : unit -> secret
    val generate_identifier_from_secret : secret -> t

end = struct
    type t = Cryptography.Public_key.t
    type secret = Cryptography.Private_key.t
    let generate_secret = Cryptography.generate_private_key
    let generate_identifier_from_secret private_key = Cryptography.public_key private_key
end

module Entity : sig
    type t

    val register_entity : Indentifier.t -> entity
end

module Proof : sig
  type t
  type ts

  val location :~entity:Entity.t -> ~time:Time.t -> lat:float -> lng:float -> t
  val DOB : ~entity:entity.t -> ~date:Date.t -> t

  val add_proof : ts -> t -> ts
  val singleton : t -> ts
  val empty_proof : t
end = struct

  type t = [
    `Location of Entity.t * Time.t -> float * float
    | `DOB of Entity.t * Date.t
  ]

  type ts = t list

  let location ~entity ~time ~lat ~lng = `Location (entity, time, lat, lng)

  let age ~entity ~date = `DOB (entity,date)

  let add_proof ts t =
    (* Assesrts ts doesn't already have a DOB or location for the given entity *)
    t :: ts

  let singleton t = [ t ]
end

module Circumstance : sig

    type t
    type ts

    val circumstances_met : ts -> Proof.ts -> bool
    val add_circumstance : ts -> t -> ts
    val singleton : t -> ts
    val empty_circumstance : t
end

module Authentication_system : sig


    type physical_token

    (* Returns a tuple of the [identity_token] and the proof that the token belongs to the [assignee]. *)
    val assign_token : ~assigner:Entity.t -> ~assignee:Entity.t -> ~assignee_proofs:Proof.ts -> (physical_token*Proof.t)

    type permission

    (* Describes the permission and the circumstances under which it is valid. *)
    type know_your_permission = (Entity.t * Circumstance.ts * permission)

    val master_provider : Entity.t

    (* Given an [Entity.t], identity provider and a list of existing proofs for that entity, 
      give a list of new proofs that are a superset of the original proofs. *)
    val provide_proofs : ~provider:Entity.t -> ~providee:Entity.t -> ~proofs:Proof.ts -> Proof.ts
    
    type kyp_granter = ~providee:Entity.t -> ~required_proofs:Proof.ts -> ?physical_token:physical_token -> know_your_permission list
    
    val generate_kyp_granter : ~provider:Entity.t -> ~provider_proofs:Proofs.ts -> ~circumstances_to_get_kyp:Circumstance.ts ->             ~kyp_circumstances:Circumstance.ts -> kyp_granter 

    (* On authentication validity of some of the [Proof.ts] from [kyps] might be checked automatically by 
        the [provider]. Validity of other circumstances has to be supplied from the [providee]. *)
    val authenticate : ~provider:Entity.t -> ~providee:Entity.t -> ~required_proofs:Proof.ts -> ~kyps:know_your_permission list -> bool
    
  end

  ```

Anil, Patrick and Michał want to organise a supervision. To do so, everyone's university card has to grant access to Anil's office
for the period of the supervision, and everyone has to be able to leave the premises independent of the time.
As only Anil is a member of the Pembroke college, ha can provide Patrick and Michał with proofs that they are his guests for the time of 
the supervision. The persmissions to enter can be granted to non-Pembroke members under the restriction that
they can only access the parts of Pembroke necessery to get to the supervision area and the supervisor will have to be present
in that area for the duration of the supervision.

  ```ocaml

  module Door_access (AS : Authentication_system) : sig

    type card_reader
    type door_lock

    val card_readers : card_reader list
    val door_locks : door_lock list

    val card_reader_access_granter : AS.kyp_granter

    val give_card_reader_lock_access : card_reader -> door_lock -> AS.know_your_permission

    val give_kyp_to_open_door : ~providee:Entity.t -> ~door_lock:door_lock -> ~proofs:Proof.ts -> AS.know_your_permission

    (* Opens the door or not. *)
    val read_card : ~physical_token:AS.physical_token -> ~card_reader:card_reader -> ~kyps:AS.know_your_permission list -> ~proofs:Proof.ts -> unit

  end = struct

    type card_reader = Entity.t
    type door_lock = Entity.t

    let card_readers = ...
    let door_locks = ...

    let card_reader_access_granter = 
         AS.generate_kyp_granter ~provider:AS.master_provider ~provider_profs:(Proof.singleton Proof.empty_proof) ~circumstances_to_get_kyp:(Circumstance.singleton Circumstance.empty_circumstance) ~kyp_circumstances:(Circumstance.singleton Circumstance.empty_circumstance
    

    let give_card_reader_lock_access card_reader door_lock = card_reader_access_granter ~providee:card_reader ~required_proofs:(Proof.singleton)



  end

  module Pembroke_supervision_access (DS : Door_access AS : Authentication_system) : sig

  val supervisor_proofs : ~supervisor:Entity.t -> ~supervisee:Entity.t -> ~supervisee_proofs:Proof.ts -> Proof.ts

  type location = {
    identifier : Identifier.t ;
    doors : (Identifier.t * DS.door_lock) list
  }

  val locations = location list

  val exits = location list

  val location_en_route_nearest_exit : ~current_location:location -> ~location_to_check:location -> bool

  (* Gives the location of the [entity] if the [requester] proves that they are entitled of this information. *)
  val request_location_proof : ~requester:Entity.t -> ~proofs:Proof.ts -> Entity.t -> Proof.t

  end = struct

  end


```


