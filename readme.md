# Motivation
Authentication is necessary if we want to specify who can access a system and under
what conditions they are allowed to do so. It is an important building block in ensuring
information security and preventing abuse of the system.

If a Cambridge College wants to organise an event in collaboration with other Colleges,
verifying guests’ affiliation becomes a hard problem. The Colleges have multiple sources
of truth about the potential attendees and need to come to an agreement on which ones to
use and when. As separate institutions, Colleges want to exchange a minimal amount of
private information and cannot delegate the authentication procedure to a third party as
that would require unconditional trust in how their data would be handled – an unrealistic
assumption introducing all the problems of a central point of failure.

A promising solution involves a decentralised approach, where each College would
locally store a copy of a global state describing public authentication policies involving
all other Colleges. On the first interaction with their College, students would be granted
a digital certificate proving their association, which could then be shared with other
members of the network. Every participant in the system could then create authentication
policies, which automatically grant access to their resources to all the students at that
College. They could do so by only listening to standarised messages broadcasting the
College’s granting of certificates removing part of the friction associated with managing
explicit cooperation.

As the certificates could be associated only with each user’s unique, random identifier,
the users would effectively remain pseudonymous. No College could track members of
other Colleges beyond their authentication attempts to the College’s own resources.

With the design and implementation of this system, we need to prioritise:

- Expressivity: How can we allow the users to express a wide spectrum of authentication policies?
The primary aim of the system is to allow users to create authentication policies
involving conditions that can only be verified by other participants in the system.
Users should be able to cleanly express a variety of such conditions, and other actors,
i.e. system participants, should be allowed to access resources and gain additional
privileges upon meeting those conditions.

- Usability: How can we make the system easy and safe to use?
It should be straightforward for any end user of the system to broadcast and grant
access to resources, and identity attributes (e.g. Student at the University X or Fel-
low at College Y) to other actors. The system should automatically check whether
any user has all the required privileges to access a resource while minimising the
need for human action. Additionally, since it is very difficult for human operators
to interact with cryptographic primitives directly, we should abstract all such
interaction away from the end user.
- Integrity: How can we ensure that only authorised agents will have access to pro-
tected resources?
Before making any changes to the state of the system, it is necessary to ensure
that the actor requesting the changes has the privilege to do so. In a decentralised
context, this can be ensured with message signatures, which can prove the
identity of the message’s sender.

As we want the system to be suitable for deployment in a decentralised environment, to
ensure the above goals, we will have to handle fundamental issues of distributed systems:
- Scalability: How can the system handle increasing number of participants?
With a growing number of participants, the state of the system increases in size,
which comes with larger storage requirements and higher latency for carrying out
state changes. Hence, in a fully trustless environment where each participant would
need to have their own copy of the system, the aggregate storage and computation
requirements would grow quadratically with the number of users. To ensure that
the system remains scalable, we will aim for a decomposable design, which allows
every agent to only store and perform computations on the parts of the system
which they care about, lowering individual computation costs.
- Availability: How can we guarantee that authentication can always be performed?
For a positive user experience, each authentication request should be handled swiftly.
This requires each of the servers in the network to hold all the relevant information
about the resources it is responsible for, and the actors that can request access to
them.
- Consistency: How can we ensure that the state of the system remains in sync
between all participants?
When creating an authentication system, we want to make sure that after granting
an actor certain privileges, such action will be reflected by every participant. As each
actor in the system can now hold their own copy of the system’s state we need to
make sure that changes happening to one of the copies will be broadcasted to others.
Given, the possibility of arbitrary delays for message transfers and computations,
the requirement can be relaxed to eventual consistency, where we want to ensure that
eventually all the updates will be broadcasted. In decentralised systems nowadays,
this issue can be handled by gossip protocols, where the participants exchange
information about state changes with each other.

This project implements GraphAuth – an authentication system
of my own design, which tackles these challenges. The core idea is to represent the
state of the system as a directed acyclic graph of permissions describing who has access
to which resources and under which circumstances. The graph structure
implicitly holds partial information about the history of the system providing traceability
and its decomposability ensures higher scalability. Each resource can be
associated with a server (usually controlled by the same party that controls the resource),
which will handle the authentication for it, allowing for decentralised deployment of the
system. Careful use of cryptographic primitives secures the system. Polang – a
domain specific language (DSL) I created, and an out-of-the-box support for spatial access
policies (i.e. policies controlling access to physical and virtual spaces) facilitate ease of
interaction.

## Structure of the repository
The authentication system directory contains all the OCaml code. It is split into six main
subdirectories. This includes the source code directory, containing the implementation
of the core of the system and the implementation of Polang. The rest of the directories
include a unit, integration, end-to-end test directories, a benchmarking directory, and a
directory that contains the executable for the interpretation of Polang.

The contents of the frontend directory are structured according to the standard React
template, with the source code written in the App.js file, containing the structure of
the UI and the graph.js file containing the implementation of the force graphs.

The server directory contains a single javascript file, which emulates a single server running the authentication system.

## Running

Build the OCaml code by ```dune build```

Run the interpreter by ```dune exec -- bin/parser/parser_main.exe```

Run the server by ```node server.js```

Run the frontend by ```npm start```
