# Five-Phase Reasoning Framework

## Overview

This is a five-phase reasoning engine for first-principles analysis. It is NOT a checklist — you decompose the problem first, then reason upward, then anchor against principles. The phases build on each other. Each phase's output feeds the next. Do not skip phases; do not treat them as independent steps.

When executing this framework, think before producing output. The value is in the reasoning, not in filling sections.

---

## Phase 1: Decompose

Strip the problem to fundamental truths. Ignore existing solutions, conventions, and prior art.

Ask and answer these questions explicitly:

- **What problem is actually being solved?** Name the problem itself, not the solution someone chose. If the input describes a solution, work backward to the underlying problem.
- **Who are the actors?** Identify every human, system, and process that touches this problem. What are their real needs — not what they asked for, but what they actually need to succeed?
- **What are the hard, irreducible constraints?** Separate physics (latency, bandwidth, compute), business rules (compliance, SLAs, contracts), regulatory requirements (data residency, audit), and resource limits (team size, budget, timeline). These are non-negotiable. Everything else is a choice.
- **What would a solution look like with zero legacy, zero convention, zero bias?** Imagine you are solving this for the first time with no existing codebase, no inherited patterns, no organizational inertia. What would you build?

Output: a concise problem statement, actor map, constraint list, and a clean-slate sketch.

---

## Phase 2: Surface Assumptions

Identify what is taken for granted. Every system carries hidden assumptions — find them.

Probe each of these dimensions:

- **Technology choices made by default.** Is the language, framework, database, or protocol chosen because it fits the problem, or because it was already there? Name each default choice and ask: would you pick this today for this problem?
- **Patterns followed by convention.** Microservices, REST, event sourcing, hexagonal architecture — are these patterns here because they solve a specific problem in this context, or because "that's how we do things"? Identify each pattern and state what problem it solves here.
- **Requirements vs. inherited preferences.** Challenge every stated requirement. Is "must support 10,000 concurrent users" a measured need or a guess? Is "must use PostgreSQL" a real constraint or a comfort choice? Separate hard requirements from soft preferences.
- **Cost of each assumption if wrong.** For every assumption surfaced, estimate the blast radius. A wrong database choice may cost months of migration. A wrong API boundary may cost years of workarounds. Rank assumptions by cost-if-wrong.

Output: an assumption inventory with source (default, convention, preference) and cost-if-wrong rating (high, medium, low).

---

## Phase 3: Reason Upward

Build from the fundamentals identified in Phases 1-2 toward what the solution should look like. Do not reference existing architecture yet — derive structure from the problem.

Work through these questions:

- **What are the natural boundaries in this problem?** Where do concerns genuinely separate? Boundaries should reflect real domain divisions, not organizational charts or framework conventions.
- **What must change together? What can change independently?** Identify coupling that is inherent to the problem vs. coupling that was introduced by implementation. Group things by rate-of-change and reason-for-change.
- **Where does data naturally live? How does it naturally flow?** Follow the data. Where is it created, transformed, read, and archived? The natural data flow often reveals the right component boundaries and communication patterns.
- **What are the simplest structures that satisfy the real constraints?** Start with the simplest possible design that meets every irreducible constraint from Phase 1. Add complexity only when a specific constraint demands it. Name the constraint that justifies each added element.

Output: a derived structure with explicit justification for every boundary, component, and interaction.

---

## Phase 4: Anchor Against Principles

Cross-check the derived structure from Phase 3 against established engineering principles.

Reference: [principle-catalog.md](principle-catalog.md)

Execute as follows:

- **Select principles by relevance, not by sequence.** Review findings from Phases 1-3. Identify which principles are genuinely engaged by this problem. A data-flow problem engages different principles than an API design problem. Do not apply every principle mechanically.
- **For each relevant principle, apply its Key Question** to the subject under review. State the question, provide your answer based on evidence from the prior phases, and note alignment or misalignment.
- **Flag tensions between principles.** Principles sometimes conflict (e.g., simplicity vs. extensibility, consistency vs. autonomy). When they do, state the tension explicitly and reason about which principle takes priority in this specific context and why.
- **Not every principle applies to every review.** It is better to apply five principles deeply than fifteen superficially. If a principle is not relevant, skip it — do not force-fit.

Output: a principle alignment map showing which principles apply, how the subject aligns or misaligns, and reasoning for each judgment.

---

## Phase 5: Produce Assessment

Generate layered output that is actionable and traceable. Every finding must connect back to evidence from prior phases.

Structure the assessment as follows:

- **Direct findings.** State what is aligned with first-principles reasoning and what is not. For each misalignment, explain why it is misaligned — trace it to a specific assumption (Phase 2), a constraint violation (Phase 1), or a principle conflict (Phase 4).
- **Severity classification:**
  - *Critical* — Fundamentally misaligned with the problem's nature. Likely to cause structural failure, irreversible tech debt, or constraint violations.
  - *Moderate* — Driven by unexamined assumptions. Creates risk that compounds over time but is correctable.
  - *Minor* — Convention over optimality. Works but leaves value on the table.
- **Socratic questions.** For each finding, pose 1-2 questions that invite the user to think deeper. These are not rhetorical — they should surface information you do not have or force a genuine tradeoff decision.
- **Concrete recommendations.** Each recommendation must trace to a principle or fundamental truth. State what to do, why, and what it costs. Never recommend without acknowledging tradeoffs.

Reference output templates: [output-templates.md](output-templates.md)

---

## Mode Priority and Cross-Skill Awareness

The four skills that reference this framework operate at different altitudes. Respect their priority order:

1. **Design** (`/fp:design`) — Highest altitude. Problem definition, user needs, system purpose.
2. **Architecture** (`/fp:architecture`) — System structure, boundaries, communication patterns.
3. **Planning** (`/fp:plan`) — Execution strategy, sequencing, risk mitigation.
4. **Code Review** (`/fp:code`) — Implementation quality, patterns, correctness.

Apply these rules:

- If the input concerns a higher-altitude problem than the invoked mode handles, suggest switching. Example: a `/fp:code` invocation that reveals a fundamental design flaw should recommend `/fp:design` first.
- If the input concerns a lower-altitude problem, proceed but note that a deeper review at the appropriate level may add value.
- If invoked with no input and no conversational context, offer all four modes with a one-line description of each.
- If input is ambiguous, state which mode you are using and why, then offer to switch.

---

## Depth Scaling

Adapt the depth of analysis to the scope of the problem. Do not over-analyze simple problems or under-analyze complex ones.

**Three depth levels:**

| Level | Trigger | Decomposition | Findings | Approach |
|-------|---------|---------------|----------|----------|
| **Simple** | Single component, clear scope | Brief — focus on key constraints | 3-5 findings | Concise phases, prioritize actionability |
| **Moderate** | Multi-component, some ambiguity | Full — all Phase 1 questions | 5-10 findings | Complete framework, balanced depth |
| **Complex** | System-level, high stakes | Deep — recursive decomposition | Comprehensive with severity | Exhaustive phases, flag unknowns |

**Natural language mapping:**
- "light", "quick", "brief", "glance" → Simple
- "thorough", "detailed", "review" → Moderate
- "deep", "comprehensive", "exhaustive", "full audit" → Complex

If no depth is specified, infer from the scope of the input. A single function defaults to Simple. A system design document defaults to Complex. State the chosen depth and offer to adjust.
