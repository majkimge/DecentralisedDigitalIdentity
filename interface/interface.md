Anil, Patrick and Michał want to organise a supervision. To do so, everyone's university card has to grant access to Anil's office
for the period of the supervision, and everyone has to be able to leave the premises independent of the time.
As only Anil is a member of the Pembroke college, ha can provide Patrick and Michał with proofs that they are his guests for the time of 
the supervision. The persmissions to enter can be granted to non-Pembroke members under the restriction that
they can only access the parts of Pembroke necessery to get to the supervision area and a Pembroke member will have to be present
in that area for the duration of the supervision.

```ocaml

module Authentication_system : sig

type person
type physical_token
type know_your_permission
type permission
type proof

type identity_provider

(* Given a person, identity provider and a list of existing proofs for that person, give a list of new proofs. *)
val prove_identity : person -> identity_provider -> proof list -> proof list

type service_provider
type requirement
type kyp_granter = person -> proof list -> ?physical_token:physical_token -> know_your_permission list

val generate_kyp_granter : service_provider -> requirement list -> kyp_granter 
val authenticate : know_your_permission -> permission -> bool

type location
type location_graph
type time

(* Given a location that we want access to and the graph of locations, gives the list of locations to which we need access to reach the desired location. *)
val necessary_locations = location -> location_graph -> location list
end

```

In the above scenario, we could then instantiate requirements as tuples of Anil's location and time to dynamically grant permissions to enter 
locations on the route to Anil's location. Additionally, we would also have requirements as tuples of person and location, in order to give 
them the permissions to access all the locations until the exit from the college premises.


