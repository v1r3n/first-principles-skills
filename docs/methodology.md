# First-Principles Thinking for Software Engineering

A standalone guide for engineers who want to reason from fundamentals instead of defaulting to convention.

---

## Why First Principles?

Most software decisions are made by analogy. "Netflix uses microservices, so we should too." "Our last company used event sourcing and it worked fine." "That's the standard way to do it in Spring Boot." These decisions aren't necessarily wrong, but they bypass the question of whether they're right *for your specific problem*. Analogy-based reasoning imports the conclusions of someone else's analysis without importing the analysis itself. You get the answer without understanding the question it was answering.

First-principles thinking works differently. Instead of starting from existing solutions and adapting them, you strip a problem down to the things you know to be true -- the hard constraints, the actual requirements, the real user needs -- and build upward from there. Elon Musk famously applied this to battery costs: instead of accepting that battery packs cost $600/kWh because that's what the market charged, he asked what the raw materials cost ($80/kWh) and worked upward from there. The same logic applies to software architecture. Instead of accepting that "you need a message queue here" because that's the pattern, ask what the actual data flow requires and derive the right communication mechanism.

This doesn't mean ignoring established patterns. Patterns exist because they solve real problems, and reinventing every wheel is a waste of time. The point is to understand *why* a pattern fits before adopting it. When you reason from first principles, you might arrive at the same microservices architecture everyone else uses -- but you'll know exactly why each service boundary exists, and you'll avoid the boundaries that don't earn their keep.

---

## The Approach

The methodology follows five phases. Each phase's output feeds the next. The value is in the reasoning, not in filling out templates.

### Phase 1: Decompose

Strip the problem to fundamental truths. Identify the actual problem being solved (not the solution someone proposed), the actors involved, and the hard constraints -- physics, business rules, regulatory requirements, resource limits. Everything else is a choice, not a given. The exercise of imagining a solution with zero legacy, zero convention, and zero organizational inertia reveals which parts of the current design are driven by the problem and which are driven by history.

### Phase 2: Surface Assumptions

Every system carries hidden assumptions. Technology choices made by default ("we're a Java shop"), patterns followed by convention ("we always use REST"), requirements that are actually preferences ("must support 10,000 concurrent users" -- says who?). This phase inventories those assumptions and estimates the blast radius of each one being wrong. A wrong API boundary costs years of workarounds. A wrong database choice costs months of migration. A wrong logging format costs a day. Prioritize accordingly.

### Phase 3: Reason Upward

Build from the fundamentals you identified toward what the solution should look like. Where do concerns genuinely separate? What must change together, and what can change independently? Where does data naturally live and flow? Start with the simplest structure that satisfies every irreducible constraint, and add complexity only when a specific constraint demands it. Name the constraint that justifies each added element -- if you can't name one, the element doesn't belong.

### Phase 4: Anchor Against Principles

Cross-check your derived structure against established engineering principles. Separation of concerns, information hiding, coupling and cohesion, simplicity, fail-fast, and others. The principle catalog (see below) provides the reference set, but the key is selecting principles by relevance, not applying them mechanically. A data-flow problem engages different principles than an API design problem. Apply five principles deeply rather than fifteen superficially. When principles conflict -- simplicity versus extensibility, consistency versus autonomy -- state the tension and reason about which one wins in your context.

### Phase 5: Produce Assessment

Report findings with traceability. Every finding should connect to evidence from the prior phases: a violated principle, an unexamined assumption, a missed constraint. Classify severity -- critical (structural misalignment), moderate (unexamined assumptions creating compounding risk), or minor (convention over optimality). Pose questions that surface missing information or force genuine tradeoff decisions. Recommend concretely, with tradeoffs acknowledged.

---

## Applying It

The most natural entry point is a design review or architecture discussion. Before the meeting, ask yourself: "What problem are we actually solving?" Write it down in one sentence. If you can't, the problem isn't well-defined yet, and that's your first finding. When someone proposes a solution, resist the urge to evaluate it immediately. Instead, work backward: what problem does this solve, what are the hard constraints, and does the proposed structure follow from those constraints?

In code reviews, the approach scales down. You're not decomposing an entire system, but you can still ask first-principles questions. "Why is this a class and not a function?" "What assumption does this retry logic encode about the failure mode?" "If this requirement changes, how many files need to change?" These questions surface coupling, hidden assumptions, and accidental complexity that a line-by-line review might miss.

For planning sessions, the assumption-surfacing phase is especially valuable. Project plans are built on a foundation of estimates, and estimates are built on assumptions. "We can reuse the existing auth service" assumes the auth service supports your new requirements. "This will take two sprints" assumes the team has done something similar before. Making these assumptions explicit converts invisible risks into visible ones you can manage.

A few practical tips. Start with the problem statement, not the proposed solution -- it's much harder to think from first principles once a specific design is on the table and anchoring bias takes hold. Challenge technology choices with "why this, specifically?" -- not as an attack, but as a genuine inquiry. When you find yourself saying "that's how it's usually done," pause and ask whether "usually" applies here. And keep a written record: the value of the analysis compounds when future engineers can read your reasoning, not just your conclusions.

---

## The Principle Catalog

The methodology references 15 engineering principles organized into three tiers:

**Tier 1 -- Foundational (Always Relevant)**
These apply to virtually every design decision: [Separation of Concerns](principles/separation-of-concerns.md), [Information Hiding](principles/information-hiding.md), [Coupling and Cohesion](principles/coupling-and-cohesion.md), [Simplicity](principles/simplicity.md), and [Single Source of Truth](principles/single-source-of-truth.md).

**Tier 2 -- Structural (Architecture and Design Focus)**
These shape system structure and boundaries: [Least Privilege](principles/least-privilege.md), [Reversibility](principles/reversibility.md), [Dependency Direction](principles/dependency-direction.md), [Fail-Fast](principles/fail-fast.md), and [Composition over Inheritance](principles/composition-over-inheritance.md).

**Tier 3 -- Operational (Scale and Production Focus)**
These govern runtime behavior and resilience: [Observability](principles/observability.md), [Idempotency](principles/idempotency.md), [Graceful Degradation](principles/graceful-degradation.md), [Backpressure](principles/backpressure.md), and [Least Astonishment](principles/least-astonishment.md).

Each principle file explains the essence, key question, what violation and alignment look like in practice, and how the principle relates to others. They are deep-dives, not summaries -- read them when a principle is relevant to a decision you're making.

---

## Further Reading

- **David Parnas**, "On the Criteria To Be Used in Decomposing Systems into Modules" (1972). The foundational paper on information hiding and module boundaries. Still the best argument for why "what changes together" matters more than "what is logically similar."

- **Fred Brooks**, "No Silver Bullet -- Essence and Accident in Software Engineering" (1986). The distinction between essential complexity (inherent to the problem) and accidental complexity (introduced by the solution) is the intellectual backbone of first-principles analysis.

- **Edsger Dijkstra**, "On the role of scientific thought" (1974). Introduces separation of concerns as a disciplined approach to managing complexity. The origin of the phrase itself.

- **John Ousterhout**, "A Philosophy of Software Design" (2018). A modern, practical treatment of complexity management. Especially strong on deep modules, information hiding, and the costs of shallow abstractions.
