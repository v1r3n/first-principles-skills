# Separation of Concerns

## In One Sentence

Each unit of code should have one reason to exist and one reason to change.

## The Key Question

"If requirement X changes, how many places in the codebase need to change?"

## Why It Matters

Software systems grow in complexity not because individual components are hard to understand, but because the interactions between components become tangled. When a single module handles authentication, business logic, and database access, a change to any one of those concerns forces you to understand and risk breaking the other two. The cost of change rises nonlinearly with the number of concerns entangled in one place.

Separation of concerns is the primary tool for keeping that cost linear. When each module owns exactly one concern, changes are localized. A new authentication scheme doesn't touch business logic. A database migration doesn't require rewriting validation rules. The system becomes a collection of independent decisions rather than a web of interdependent ones.

This principle predates software engineering itself -- Dijkstra introduced it in 1974 as a strategy for intellectual manageability. The insight is that humans can only reason about a limited number of things at once, so the most effective way to handle a complex system is to ensure you never have to think about more than one concern at a time.

## What Violation Looks Like

- A REST controller that validates input, executes business rules, queries the database, and formats the HTTP response all in a single method. Changing the response format requires reading through database queries.
- A React component that fetches data, manages form state, handles routing logic, and renders UI. Adding a new form field requires understanding the data-fetching lifecycle.
- A CI/CD pipeline definition that mixes build steps, test execution, deployment commands, and notification logic in a single script with no clear boundaries between stages.

## What Alignment Looks Like

- A request handler that delegates to a validator, a service, and a presenter -- each in its own module. The handler orchestrates, each module does one thing.
- A data pipeline where ingestion, transformation, validation, and storage are separate stages with clear interfaces between them. You can replace the storage backend without touching the transformation logic.
- A frontend architecture where data fetching (hooks or services), state management, and presentation components are distinct layers. Adding a new API field means updating the data layer, not every component that displays the data.

## Related Principles

- [Coupling and Cohesion](coupling-and-cohesion.md) -- Separation of concerns defines *what* to separate; coupling and cohesion measure *how well* you did it.
- [Information Hiding](information-hiding.md) -- Once concerns are separated, information hiding keeps the boundaries stable.
- [Single Source of Truth](single-source-of-truth.md) -- Separated concerns should each own their data authoritatively.

## The Litmus Test

Pick any requirement change the system might need to accommodate. Trace the change through the codebase. If it touches more than one module that doesn't share its concern, concerns are entangled.
