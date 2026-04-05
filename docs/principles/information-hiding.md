# Information Hiding

## In One Sentence

Implementation details belong behind stable interfaces so that internal changes don't ripple outward.

## The Key Question

"Can I change the internals of this module without breaking its consumers?"

## Why It Matters

Every piece of exposed implementation detail becomes a dependency. When a module reveals how it stores data, how it communicates with other services, or what algorithms it uses internally, consumers couple to those details -- often unintentionally. The moment someone writes code that depends on the fact that your user records are sorted by creation date (because that's how the database happens to return them), changing the sort order becomes a breaking change.

Information hiding, as described by Parnas in 1972, is the discipline of deciding what to reveal and what to conceal at each module boundary. The interface is a contract; everything behind it is free to change. This is what makes systems evolvable. You can swap a PostgreSQL backend for DynamoDB, replace a linear search with a hash lookup, or restructure internal data representations -- all without touching consumer code.

The hardest part is identifying what to hide. The answer is: anything likely to change. Database schemas, wire formats, third-party library APIs, caching strategies, error recovery mechanisms -- these are all implementation details that should not leak through module boundaries.

## What Violation Looks Like

- An ORM entity class used directly in API responses, so every database schema change requires a new API version or a breaking change for clients.
- A shared library that exposes its internal dependency on a specific HTTP client, forcing all consumers to upgrade when the library switches from Apache HttpClient to OkHttp.
- A module that returns raw database rows (dictionaries or tuples) instead of domain objects, coupling every consumer to the database schema.

## What Alignment Looks Like

- A repository layer that returns domain objects, not ORM entities or raw query results. The database can be restructured, indexes changed, or queries rewritten without any impact on business logic.
- An API client library that exposes a domain-specific interface (e.g., `getUser(id)`) while internally handling authentication, retry logic, and serialization. Consumers never see the HTTP layer.
- A configuration module that provides typed accessor methods (`getMaxRetries()`) rather than exposing the raw config file, environment variables, or config map it reads from.

## Related Principles

- [Separation of Concerns](separation-of-concerns.md) -- Separation identifies the boundaries; information hiding enforces them.
- [Dependency Direction](dependency-direction.md) -- Depending on abstractions rather than concretions is information hiding applied to dependency relationships.
- [Least Privilege](least-privilege.md) -- Limiting what a component can access is the runtime analog of limiting what it can see at design time.

## The Litmus Test

Look at the public interface of any module. For each element it exposes, ask: "Is this part of what this module *does*, or part of *how* it does it?" If it's the latter, it's a leak.
