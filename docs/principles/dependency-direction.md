# Dependency Direction

## In One Sentence

Depend on abstractions, not concretions; depend inward toward stable core logic, not outward toward volatile infrastructure.

## The Key Question

"Does the core logic depend on infrastructure, or does infrastructure depend on the core?"

## Why It Matters

The direction of dependencies determines what breaks when something changes. If your order-processing logic imports a PostgreSQL client directly, changing the database means changing the business logic. If your business logic defines an interface ("I need to store orders") and the database layer implements that interface, changing the database means changing the database layer only. The business logic never knew or cared how orders were stored.

This is the Dependency Inversion Principle at its core, but the concept extends beyond class-level design. At the architecture level, it means that core domain logic should not depend on web frameworks, database drivers, message brokers, or any external infrastructure. The infrastructure adapts to the core, not the other way around. This produces systems where the most important code -- the business rules -- is also the most stable and the most testable.

Getting dependency direction wrong is the root cause of many common problems: "We can't test business logic without spinning up a database." "Upgrading the framework requires changing every service class." "We can't reuse the pricing engine in the CLI tool because it depends on the HTTP request context." These are all symptoms of outward-facing dependencies, where core logic has been coupled to infrastructure details.

## What Violation Looks Like

- A domain service class that imports `express.Request` and reads query parameters directly. The business logic is now coupled to HTTP, and reusing it in a CLI tool, background job, or gRPC handler requires refactoring.
- A core calculation module that calls `boto3.client('s3').get_object()` directly. Testing requires either a real S3 bucket or mocking AWS SDK internals.
- A React component that contains business validation logic inline. The validation can't be reused in the API layer, and testing it requires rendering the component.

## What Alignment Looks Like

- A ports-and-adapters (hexagonal) architecture where domain logic defines interfaces (ports) and infrastructure code implements them (adapters). The domain module has zero imports from infrastructure packages.
- A use-case layer that accepts dependencies through constructor injection. Testing means passing in-memory fakes; production means passing real clients. The use-case code is identical in both environments.
- A CLI tool and a web API that share the same core library because the core library depends on no transport or framework -- it accepts plain data and returns plain data.

## Related Principles

- [Information Hiding](information-hiding.md) -- Abstractions at the dependency boundary are an application of information hiding: the core doesn't know the implementation details of its infrastructure.
- [Reversibility](reversibility.md) -- Correct dependency direction makes infrastructure choices reversible, because the core logic doesn't change when the infrastructure does.
- [Separation of Concerns](separation-of-concerns.md) -- Domain logic and infrastructure are separate concerns. Dependency direction enforces that separation at the import level.

## The Litmus Test

Open your core domain module and look at its import statements. If it imports database drivers, HTTP frameworks, cloud SDKs, or message broker clients, the dependency direction is inverted. Core logic should import only language primitives, domain types, and interfaces it defines itself.
