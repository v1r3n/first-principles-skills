# Reversibility

## In One Sentence

Prefer decisions that are cheap to change over decisions that lock you in.

## The Key Question

"What's the cost of unwinding this decision in six months?"

## Why It Matters

Software development is an exercise in decision-making under uncertainty. You don't know exactly how requirements will evolve, which assumptions will prove wrong, or what the system will need to look like in two years. Given that uncertainty, the cost of being wrong on any given decision depends almost entirely on how reversible that decision is.

Some decisions are naturally hard to reverse: the choice of primary programming language, the fundamental data model, the decision to go multi-tenant versus single-tenant. These deserve deep analysis and caution. Other decisions -- which web framework to use, how to structure a configuration file, whether to use a specific library -- are relatively cheap to change. Treating all decisions as equally consequential is wasteful; treating all decisions as equally inconsequential is reckless.

The practical implication is to bias toward options that preserve future flexibility. Use interfaces and abstractions at the boundaries where you're least certain. Prefer feature flags over hard-coded behavior. Choose data formats that can evolve (additive schemas, optional fields). When two approaches are roughly equivalent, pick the one that's easier to walk back from. This doesn't mean avoiding commitment -- it means saving your commitment for the decisions that genuinely matter.

## What Violation Looks Like

- Choosing a proprietary database with a custom query language and no standard migration path, when an open-source alternative with SQL compatibility would meet the same requirements.
- Embedding a vendor's SDK deeply into business logic instead of wrapping it behind an internal interface. Switching vendors now means rewriting every call site.
- Committing to a multi-year contract for infrastructure that the team hasn't validated at scale, based on a vendor's benchmarks rather than your own workload testing.

## What Alignment Looks Like

- Wrapping third-party services (payment processors, email providers, cloud storage) behind internal interfaces. The interface is stable; the implementation behind it can be swapped.
- Using feature flags to gradually roll out a new behavior, with the ability to instantly revert if problems emerge. The old code path remains intact until the new one is proven.
- Choosing additive-only schema migration strategies where new fields are optional and old fields are deprecated rather than removed. Rollback means deploying the previous version, not running a reverse migration.

## Related Principles

- [Simplicity](simplicity.md) -- Simple designs are inherently more reversible. Less code, fewer dependencies, and fewer abstractions mean less to undo.
- [Information Hiding](information-hiding.md) -- Hiding implementation details behind interfaces is the primary mechanism for making technology choices reversible.
- [Dependency Direction](dependency-direction.md) -- Depending on abstractions rather than concretions keeps the door open for changing the concretions.

## The Litmus Test

For any significant decision, ask: "If we need to change this in six months, what does that look like?" If the answer involves months of migration work, rewriting core logic, or coordinating changes across many teams, the decision deserves more scrutiny upfront -- or a more reversible alternative.
