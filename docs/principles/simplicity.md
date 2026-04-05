# Simplicity (YAGNI / KISS)

## In One Sentence

Nothing should exist in the system without justification from a real, present constraint.

## The Key Question

"What happens if I remove this? Does anything break that matters today?"

## Why It Matters

Complexity is the silent killer of software projects. It doesn't arrive all at once -- it accumulates in small increments, each one justified by a plausible future scenario. "We might need to support multiple databases someday, so let's add an abstraction layer." "This could become a hot path, so let's optimize it now." "Other teams might want to use this differently, so let's make it configurable." Each decision adds a little complexity. Over time, the system becomes harder to understand, harder to change, and harder to debug -- not because any single decision was wrong, but because the accumulated weight of speculative decisions is crushing.

YAGNI (You Aren't Gonna Need It) and KISS (Keep It Simple, Stupid) are expressions of the same fundamental truth: the cost of unnecessary complexity is real and immediate, while the benefit of premature generalization is speculative and often never materializes. Studies of real codebases consistently show that the majority of "extensibility" hooks, configuration options, and abstraction layers are never used for their intended purpose.

Simplicity is not the absence of sophistication. A well-designed hash table is simple in interface and sophisticated in implementation. Simplicity means that every element earns its place by solving a problem that exists right now. When a new requirement arrives that genuinely needs the abstraction, you add it then -- with the benefit of actually understanding the real requirement instead of guessing.

## What Violation Looks Like

- A factory pattern wrapping a single implementation that has never had and shows no concrete indication of needing a second implementation. The factory adds indirection without value.
- A configuration system that supports YAML, JSON, TOML, and environment variables when the application has only ever been configured through environment variables. Four parsers, four test paths, four sources of bugs.
- A microservices architecture for an application with a single team, a single deployment target, and no independent scaling requirements. The network boundary adds latency, failure modes, and operational complexity without any corresponding benefit.

## What Alignment Looks Like

- A function that does one thing directly, with no hooks, callbacks, or extension points, because no second use case has materialized. When one does, refactoring to add the extension is straightforward because the code is simple enough to modify confidently.
- A monolithic application that deploys as a single unit because the team is small and all components scale together. The team acknowledges they'll extract services if independent scaling becomes a real need, but not before.
- A data model that represents exactly the entities the system currently manages, with no "just in case" tables or columns. New entities are added when new features require them.

## Related Principles

- [Reversibility](reversibility.md) -- Simple decisions are inherently more reversible. The less you've built, the less you have to undo.
- [Separation of Concerns](separation-of-concerns.md) -- Well-separated concerns make simplicity easier: you can keep each module simple because it only handles one thing.
- [Coupling and Cohesion](coupling-and-cohesion.md) -- Unnecessary abstractions often introduce coupling between layers that don't need to interact.

## The Litmus Test

Point at any abstraction, configuration option, or architectural boundary. Ask: "What specific, current requirement does this serve?" If the answer starts with "in case" or "someday," it's a candidate for removal.
