Anil, Patrick and Michał want to organise a supervision. To do so, everyone's university card has to grant access to Anil's office
for the period of the supervision, and everyone has to be able to leave the premises independent of the time.
As only Anil is a member of the Pembroke college, ha can provide Patrick and Michał with proofs that they are his guests for the time of 
the supervision. The persmissions to enter can be granted to non-Pembroke members under the restriction that
they can only access the parts of Pembroke necessery to get to the supervision area and a Pembroke member will have to be present
in that area for the duration of the supervision.

```ocaml

module Proof : sig
  type t
  type ts

  val location : lat:float -> lng:float -> t
  val age : int -> t

  val add_proof : ts -> t -> ts
  val singleton : t -> ts
end = struct

  type t = [
    `Location of float * float
    | `Age of int
  ]

  type ts = t list

  let location ~lat ~lng = `Location (lat, lng)

  let age i = `Age i

  let add_proof ts = function
    | (`Age _) as t -> 
        (* Assesrts ts doesn't already have an age *)
        t :: ts
    | _ -> ts 

  let singleton t = [ t ]
end

module Circumstance : sig
  type kinds
  type kind

  val location : lat:float -> lng:float -> kind
  val age : int -> kind

  val add_kind : kinds -> kind -> kinds
  val singleton : kind -> kinds
end = struct

  type kind = [
    `Location of float * float
    | `Age of int
  ]

  type kinds = kind list

  let location ~lat ~lng = `Location (lat, lng)

  let age i = `Age i

  let add_kind ks = function
    | (`Age _) as v -> 
        (* Assesrts ks doesn't already have an age *)
        v :: ks
    | _ -> ks 

  let singleton v = [ v ]
end


module type Authentication_system = sig
    type entity
    type physical_token

    (* Give a proof that [entity] is the rightful owner of the [physical_token] *)
    val token_ownership_proof : entity -> physical_token -> Proof.ts -> Proof.t

    type permission

    (* Describes the permission and the circumstances under which it is valid *)
    type know_your_permission = (Circumstance.kinds * permission)

    val master_identity_provider : entity

    (* val identity_provider : identity_provider
       
    *)

    (* Given a person, identity provider and a list of existing proofs for that person, 
      give a list of new proofs that are a superset of the original proofs. *)
    val provide_proofs : ~provider:entity -> ~providee:entity -> ~proofs:Proof.ts -> Proof.ts
    
    type kyp_granter = ~providee:entity -> ~required_proofs:Proof.ts -> ?physical_token:physical_token -> know_your_permission list
    
    val generate_kyp_granter : ~provider:entity -> ~provider_proofs:Proofs.ts -> kyp_granter 

    (* On authentication validity of some of the [Circumsntaces.kinds] from [kyps] might be checked automatically by 
        the [provider]. Validity of other circumstances has to be supplied from the [providee] as [Proof.ts]. *)
    val authenticate : ~provider:entity -> ~providee:entity -> ~required_proofs:Proof.ts -> ~kyps:know_your_permission list -> bool
    
  end

  module DoorAccess (AS : Authentication_system) = struct
    type request
    type response

    type open_door = AS.person -> AS.identity_provider -> AS.location -> bool

    let anil_student anil : Proof.kinds =
      Proof.singleton @@ Proof.location ~lat:1. ~lng:1.

    let open_door : open_door = fun person ip loc ->
      let proofs = AS.provide_identity person [] in
      List.for_all List.mem proofs 

    type handler = Proof.kinds -> request -> response
  end



```

In the above scenario, we could then instantiate requirements as tuples of Anil's location and time to dynamically grant permissions to enter 
locations on the route to Anil's location. Additionally, we would also have requirements as tuples of person and location, in order to give 
them the permissions to access all the locations until the exit from the college premises.


