# First Principles Catalog

> **This catalog is a reference, not a checklist.** During Phase 4 (Anchor Against Principles), select principles based on what you discovered in Phases 1-3. Not every principle applies to every review. Choose the ones that are most relevant to the findings at hand.

---

## Tier 1 — Foundational (Always Relevant)

| # | Principle | Essence | Key Question | When Most Relevant |
|---|-----------|---------|--------------|-------------------|
| 1 | Separation of Concerns | Each unit has one reason to exist and one reason to change | "If requirement X changes, how many places need to change?" | All modes |
| 2 | Information Hiding | Implementation details behind stable interfaces | "Can I change the internals without breaking consumers?" | Design, Code |
| 3 | Coupling & Cohesion | Related things together, unrelated things apart | "Do things that change together live together? Do unrelated things depend on each other?" | All modes |
| 4 | Simplicity (YAGNI/KISS) | Nothing exists without justification from a real constraint | "What happens if I remove this? Does anything break that matters today?" | All modes |
| 5 | Single Source of Truth | Every piece of knowledge has one authoritative home | "If this fact changes, how many places need updating?" | Design, Architecture |

## Tier 2 — Structural (Architecture & Design Focus)

| # | Principle | Essence | Key Question | When Most Relevant |
|---|-----------|---------|--------------|-------------------|
| 6 | Least Privilege / Least Knowledge | Components know and access only what they need | "Does this component have access to things it doesn't use?" | Architecture, Design |
| 7 | Reversibility | Prefer decisions that are cheap to change | "What's the cost of unwinding this decision in 6 months?" | Architecture, Planning |
| 8 | Dependency Direction | Depend on abstractions, not concretions; depend inward, not outward | "Does the core logic depend on infrastructure, or does infrastructure depend on the core?" | Architecture, Design |
| 9 | Fail-Fast / Explicit Errors | Surface problems at the earliest possible moment | "If this input is invalid, when does the system find out?" | Code, Design |
| 10 | Composition over Inheritance | Build behavior from small, combinable pieces | "Am I inheriting behavior I don't need to get behavior I do?" | Design, Code |

## Tier 3 — Operational (Scale & Production Focus)

| # | Principle | Essence | Key Question | When Most Relevant |
|---|-----------|---------|--------------|-------------------|
| 11 | Observability | The system explains its own behavior | "If this breaks at 3am, can the on-call engineer understand what happened?" | Architecture, Design |
| 12 | Idempotency | Repeating an operation produces the same result | "What happens if this runs twice?" | Design, Code |
| 13 | Graceful Degradation | Partial failure doesn't mean total failure | "If dependency X goes down, does the whole system stop?" | Architecture |
| 14 | Backpressure | Systems communicate their capacity limits | "What happens when load exceeds capacity?" | Architecture |
| 15 | Least Astonishment | Behavior matches reasonable expectations | "Would a new team member be surprised by how this works?" | All modes |

---

## How to Use This Catalog

- In **Phase 4**, scan the catalog for principles relevant to your Phase 1-3 findings.
- For each relevant principle, apply the **Key Question** to the subject under review.
- A violated principle is a finding; note the severity based on impact.
- The "When Most Relevant" column is guidance, not a rule — any principle can apply in any mode.
