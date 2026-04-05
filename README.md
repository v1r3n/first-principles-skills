# fp — First Principles Thinking for Software Engineering

> A Claude Code plugin that reasons from fundamentals, not conventions.

## What is this?

This plugin applies first-principles thinking to software engineering. Instead of running through checklists or enforcing style guides, it decomposes problems to their fundamental truths, surfaces hidden assumptions, reasons upward from real constraints, and anchors findings against core engineering principles.

Unlike conventional review tools that pattern-match against known good practices, fp works bottom-up. It starts by asking "what problem are we actually solving?" and builds toward a solution structure derived from the problem itself — not from convention, habit, or cargo-culted patterns.

The plugin is designed for AI assistants (Claude Code primarily), but the methodology is fully documented for human use too. Whether you're using it through Claude Code or reading the framework directly, the reasoning process is the same.

## The Five Phases

```
Decompose → Surface Assumptions → Reason Upward → Anchor Against Principles → Produce Assessment
```

1. **Decompose** — Strip the problem to fundamental truths: the real problem, the actors, the hard constraints.
2. **Surface Assumptions** — Identify what is taken for granted: default technology choices, conventional patterns, inherited preferences.
3. **Reason Upward** — Build from fundamentals toward what the solution should look like, without referencing existing architecture.
4. **Anchor Against Principles** — Cross-check the derived structure against established engineering principles, selecting by relevance not by rote.
5. **Produce Assessment** — Generate layered, actionable findings with severity, Socratic questions, and concrete recommendations.

## Modes

| Mode | Command | When to Use |
|------|---------|-------------|
| Design Review | `/fp:design` | Evaluate feature/system designs before or during implementation |
| Architecture Review | `/fp:architecture` | Evaluate service boundaries, data storage, communication patterns |
| Planning | `/fp:plan` | Start new projects/features with a principled foundation |
| Code Review | `/fp:code` | Review code for structural and logical issues, not style nits |

## Installation

```bash
# From the Claude Code marketplace
/plugin install fp

# Or test locally
claude --plugin-dir /path/to/first-principles-skills
```

## Quick Examples

**`/fp:design`** — Share a design doc or describe your feature, and get a gap analysis between your design and what first-principles reasoning suggests.

**`/fp:architecture`** — Point it at your codebase or describe your system, and learn whether your architecture follows from real constraints or from convention.

**`/fp:plan`** — Describe a problem you're solving, and get a principled foundation: key decisions ordered by irreversibility, with options and trade-offs.

**`/fp:code src/auth/`** — Get a structural and logical review of your code, with findings traced to specific principles and file:line references.

## The Principle Catalog

### Tier 1 — Foundational (Always Relevant)

| # | Principle | Essence |
|---|-----------|---------|
| 1 | Separation of Concerns | Each unit has one reason to exist and one reason to change |
| 2 | Information Hiding | Implementation details behind stable interfaces |
| 3 | Coupling & Cohesion | Related things together, unrelated things apart |
| 4 | Simplicity (YAGNI/KISS) | Nothing exists without justification from a real constraint |
| 5 | Single Source of Truth | Every piece of knowledge has one authoritative home |

### Tier 2 — Structural (Architecture & Design Focus)

| # | Principle | Essence |
|---|-----------|---------|
| 6 | Least Privilege / Least Knowledge | Components know and access only what they need |
| 7 | Reversibility | Prefer decisions that are cheap to change |
| 8 | Dependency Direction | Depend on abstractions, not concretions; depend inward, not outward |
| 9 | Fail-Fast / Explicit Errors | Surface problems at the earliest possible moment |
| 10 | Composition over Inheritance | Build behavior from small, combinable pieces |

### Tier 3 — Operational (Scale & Production Focus)

| # | Principle | Essence |
|---|-----------|---------|
| 11 | Observability | The system explains its own behavior |
| 12 | Idempotency | Repeating an operation produces the same result |
| 13 | Graceful Degradation | Partial failure doesn't mean total failure |
| 14 | Backpressure | Systems communicate their capacity limits |
| 15 | Least Astonishment | Behavior matches reasonable expectations |

## For Humans

The methodology behind this plugin is documented for humans too. See [`docs/methodology.md`](docs/methodology.md) for a standalone guide to applying first-principles thinking to software engineering.

## Contributing

Contributions welcome. The principle catalog is extensible — if you think a fundamental principle is missing, open an issue or PR.

## License

MIT
