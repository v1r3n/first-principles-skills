# Single Source of Truth

## In One Sentence

Every piece of knowledge in the system should have one authoritative home, and all other references should derive from it.

## The Key Question

"If this fact changes, how many places need updating?"

## Why It Matters

When the same piece of information lives in multiple places, those places will eventually disagree. It's not a question of if, but when. A user's email address stored in both the users table and the billing table. A tax rate defined in both the backend configuration and the frontend constants file. A service URL hardcoded in three different deployment manifests. The moment one copy is updated and the others aren't, the system enters an inconsistent state that may not be detected for days or months.

The damage goes beyond data inconsistency. Duplicated knowledge creates a maintenance tax on every change. Developers must remember every location where a fact is stored, and they must update all of them atomically. New team members, who don't carry the institutional knowledge of where all the copies live, are almost certain to miss one. Code review can catch some of these, but it's an unreliable defense against a structural problem.

The fix is to ensure that every fact has exactly one authoritative source, and all other uses derive from it. The billing system reads the user's email from the user service, not from its own copy. The tax rate is defined in one configuration file and injected into both backend and frontend at build time. The service URL is defined in one place and referenced everywhere else.

## What Violation Looks Like

- The same validation rules (e.g., "email must be valid," "amount must be positive") implemented independently in both the frontend and the backend, with subtly different regex patterns or threshold values.
- A constants file in each microservice defining the same set of error codes, leading to drift when one service adds a new code and the others don't.
- Database schema definitions maintained both in migration files and in a separate ORM model definition, with no automated check that they agree.

## What Alignment Looks Like

- Validation rules defined in a shared schema (e.g., JSON Schema, protobuf definitions) from which both frontend and backend validation code is generated. One change propagates everywhere.
- Feature flags managed by a single service, with all other services querying it at runtime rather than maintaining local copies of flag states.
- API contracts defined in an OpenAPI spec from which server stubs and client SDKs are generated. The spec is the source of truth; the code is derived.

## Related Principles

- [Separation of Concerns](separation-of-concerns.md) -- Each concern having a single home is how separation of concerns manifests at the data and knowledge level.
- [Coupling and Cohesion](coupling-and-cohesion.md) -- A single source of truth increases cohesion (the knowledge lives with its owner) and reduces coupling (consumers don't carry their own copies).
- [Simplicity](simplicity.md) -- Eliminating duplicated knowledge is one of the most direct paths to a simpler system.

## The Litmus Test

Pick any business rule, configuration value, or data definition. Search the codebase for it. If you find it defined in more than one place with no derivation relationship between the copies, you have a source-of-truth violation.
