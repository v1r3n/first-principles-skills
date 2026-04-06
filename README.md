# /fp

Your team adopted microservices because Netflix did. You chose Kafka because "event-driven is best." You split into 12 services for 4 developers. Sound familiar?

**/fp** is a Claude Code plugin that catches this. It applies first-principles thinking to your software — decomposing problems to their fundamental truths, surfacing the assumptions nobody questioned, and telling you what your design *should* look like based on what it actually needs to do.

This isn't a linter. It's not a checklist. It reasons from the ground up.

## How it works

When you run `/fp:design`, `/fp:architecture`, `/fp:plan`, or `/fp:code`, the plugin doesn't pattern-match against "best practices." Instead, it runs a five-phase reasoning process:

**1. Decompose** — What problem are we *actually* solving? Not "we need a notification service" — but "users need to know when something requires their attention." Strip away the solution language and find the real problem.

**2. Surface Assumptions** — What was decided by default? "PostgreSQL because we always use PostgreSQL." "Microservices because modern." "REST because REST." Every unjustified assumption is a risk.

**3. Reason Upward** — Given only the real problem and real constraints, what *should* the solution look like? Build up from fundamentals. Compare that against what's actually proposed.

**4. Anchor Against Principles** — Cross-check against 15 engineering principles (Separation of Concerns, Reversibility, Fail-Fast, etc.) — not as a checklist, but selectively based on what the analysis revealed.

**5. Produce Assessment** — Direct findings with severity, Socratic questions for deeper exploration, and concrete recommendations. Plus what's working well — this isn't just a criticism tool.

**Why this works:** A checklist tells you *what* to check. First-principles reasoning tells you *why* something is wrong — traced all the way back to the fundamental truth it violates. That's the difference between "this coupling is bad" and "this coupling means a pricing change will cascade through 6 services because the boundary was drawn along technical layers, not business domains."

## Installation

```bash
/plugin install fp
```

Or test locally:

```bash
claude --plugin-dir /path/to/first-principles-skills
```

## Usage

```
/fp:design                  Review a design doc or feature spec
/fp:architecture             Review system architecture
/fp:plan                     Plan a new project from first principles
/fp:code src/auth/           Review code for structural issues
```

## What you get

**Design Review** — "Your notification system design assumes each channel needs its own service. But 80% of the logic is shared. The real boundary isn't the channel — it's the routing decision. A single preference-aware router with channel adapters would eliminate the duplication and the preference-sync bug you don't know you have yet."

**Architecture Review** — "You have 12 microservices, 4 developers, and hundreds of orders per day. The microservices architecture was adopted because 'modern systems use microservices,' but your actual constraints (modest scale, small team, rapid iteration) point to a well-structured monolith with clear module boundaries. The distributed transactions you're fighting are accidental complexity — the problem didn't demand them."

**Planning** — "You said 'we need feature flags.' But the real problem is release risk management. A boolean toggle system with an admin UI solves 90% of that. The targeting engine, the percentage rollouts, the rule builder — those are solutions to problems you haven't confirmed you have. Start with the simplest thing that addresses the actual risk. Expand when the need is proven."

**Code Review** — "Your `login()` function handles authentication, rate limiting, token generation, audit logging, and session management. That's five responsibilities in one function. The hardcoded JWT secret at `auth.ts:47` is a critical security issue. And the rate limit check at line 62 happens *after* the bcrypt comparison — meaning locked accounts still burn CPU on password hashing."

## The 15 Principles

Not a checklist — a reference. The plugin draws from these selectively based on what the analysis reveals.

| | Principle | The Question It Asks |
|---|-----------|---------------------|
| | **Foundational** | |
| 1 | Separation of Concerns | "If requirement X changes, how many places break?" |
| 2 | Information Hiding | "Can I change internals without breaking consumers?" |
| 3 | Coupling & Cohesion | "Do things that change together live together?" |
| 4 | Simplicity | "What happens if I delete this?" |
| 5 | Single Source of Truth | "If this fact changes, how many places need updating?" |
| | **Structural** | |
| 6 | Least Knowledge | "Does this component know things it doesn't need?" |
| 7 | Reversibility | "What's the cost of changing this decision in 6 months?" |
| 8 | Dependency Direction | "Does business logic depend on infrastructure, or vice versa?" |
| 9 | Fail-Fast | "If this input is invalid, when does the system find out?" |
| 10 | Composition over Inheritance | "Am I inheriting behavior I don't need?" |
| | **Operational** | |
| 11 | Observability | "If this breaks at 3am, can on-call understand what happened?" |
| 12 | Idempotency | "What happens if this runs twice?" |
| 13 | Graceful Degradation | "If dependency X dies, does everything stop?" |
| 14 | Backpressure | "What happens when load exceeds capacity?" |
| 15 | Least Astonishment | "Would a new team member be surprised by this?" |

Each principle has a [deep-dive doc](docs/principles/) with violation examples, alignment examples, and a litmus test.

## For humans

The methodology works without the plugin. See [`docs/methodology.md`](docs/methodology.md) for a standalone guide, or browse the [worked examples](docs/examples/) to see the five phases applied to real scenarios:

- [Design review of a notification system](docs/examples/design-review-example.md)
- [Architecture review of over-engineered microservices](docs/examples/architecture-review-example.md)
- [Planning a feature flag system from scratch](docs/examples/planning-example.md)
- [Code review of an authentication module](docs/examples/code-review-example.md)

## Philosophy

- **Reasoning > checklists** — A checklist catches known patterns. First-principles reasoning catches novel problems.
- **Decompose before you design** — If you can't state the problem without solution language, you don't understand the problem yet.
- **Assumptions are the #1 risk** — The most dangerous technical decisions are the ones nobody realized they were making.
- **Question convention, not for sport, but for fit** — "Microservices" isn't wrong. "Microservices because microservices" is.
- **Assessment, not judgment** — The goal is clarity about trade-offs, not a score.

## Contributing

PRs welcome. The principle catalog is extensible — if a fundamental principle is missing, open an issue or PR. If you have a great worked example of first-principles analysis, we want it.

## License

MIT
