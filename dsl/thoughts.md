## General DSL

As Pembroke I want to be able to write:

Create Property X inside Property A. (Where Property A is also inside Pembroke. So I want to be able to create entities at
arbitrary points inside the subtree I represent. )

Give Anil a proof that he is a fellow. (Whenever a proof of a permission is granted, DSL should remember that, so these can be suggested again.)

Give Anil permission to access Anil's office if he is proven to be a fellow.

Give Supervisee A permission to accesss Anil's office given a proof of being Anil's supervisee and a proof that Anil is in his office.

As Anil I want to be able to write:

Give supervisee A a proof that he is my supervisee

## Proof module 

Within the DSL it should be possible to describe the proof system. In particular, we want the system administrator to give us an implementation of the Proof module. This implementation should be extensible from the perspective of the administrator if they want to add in different variants of proofs. We also need to give the system administrator ability to inherit the proofs associated with the entity it is encapsulated in. For example if we have that Pemborke is inside Cambridge, it should have the access to the proofs of someone being a supervisor of some other person. 

In the more concrete implementation we also need to be aware of who supplied any given proof, as we want to make sure that the proof of Pembroke fellowship is given by Pembroke. The choice now is whether during the creation of a proof variant we specify conditions on which entities are able to supply the proofs of that kind or whether we specify in the KYPs the conditions on the proof supplier.

## Physical vs Virtual

To handle the virtual world, perhaps we could say that any entity is able to produce multiple clones of its virtual counterpart, which can inhabit the virtual tree. 

## Temporality

At some point we will have to expand the system with the passage of time. One way in which we could to that is to make the system tick every period of time. Another would be such that whenever we have a time dependant proof, the system will tick on the discrete times mentioned in that proof. It would also tick whenever the system transitions to a different state.