# Coupling and Cohesion

## In One Sentence

Related things should live together (high cohesion), and unrelated things should not depend on each other (low coupling).

## The Key Question

"Do things that change together live together? Do unrelated things depend on each other?"

## Why It Matters

Coupling and cohesion are two sides of the same coin, and they determine the practical cost of change in a system. High cohesion means a module contains everything it needs to fulfill its responsibility -- you don't have to chase logic across five files to understand one feature. Low coupling means a change to one module doesn't cascade into changes elsewhere.

When cohesion is low, making a single feature change requires coordinating across multiple modules, each of which only owns a fragment of the concern. This is the "shotgun surgery" problem: a feature request turns into a dozen pull requests across a dozen repositories. When coupling is high, modules that shouldn't know about each other are entangled through shared data structures, global state, or implicit contracts. Changing one service's database schema breaks another service that queries the same table directly.

The goal is not zero coupling -- that's impossible in any useful system. The goal is that coupling reflects real domain relationships, not implementation accidents. Two modules that process different stages of the same order naturally share the concept of an order. But they shouldn't share an internal data structure or a database connection pool.

## What Violation Looks Like

- A "utils" package containing unrelated functions -- string formatting, date parsing, HTTP helpers, and crypto wrappers. Nothing in the package is cohesive; consumers couple to the whole package for one function.
- Two microservices that share a database and read each other's tables directly. Changing a column in service A breaks service B, defeating the purpose of the service boundary.
- A feature that requires coordinated deployments across three services because the request format, business logic, and response format are spread across all three.

## What Alignment Looks Like

- A module organized by domain capability (e.g., `billing/`) where invoice creation, payment processing, and receipt generation live together because they change together, even though they involve different technical layers.
- Services that communicate through well-defined APIs or events, each owning its own data store. Changing the internal schema of one service has no effect on others.
- A library where each package has a clear, singular purpose and minimal dependency on sibling packages. Consumers can import `auth` without pulling in `analytics`.

## Related Principles

- [Separation of Concerns](separation-of-concerns.md) -- Separation tells you what the concerns are; coupling and cohesion tell you whether you've organized code around them effectively.
- [Composition over Inheritance](composition-over-inheritance.md) -- Inheritance often introduces tight coupling between parent and child; composition achieves reuse with looser coupling.
- [Information Hiding](information-hiding.md) -- Hiding implementation details is the primary mechanism for reducing coupling.

## The Litmus Test

For cohesion: pick a module and list the reasons it might change. If those reasons are unrelated to each other, cohesion is low. For coupling: change an internal detail of one module and see if any test outside that module breaks. If it does, coupling is too high.
