# First Principles Skill — Design Specification

**Date:** 2026-04-05
**Status:** Draft
**Author:** Viren (with Claude)

---

## Overview

A Claude Code skill that applies first-principles thinking to software engineering. It reviews designs, evaluates architecture, guides greenfield planning, and reviews code — all by decomposing problems to their fundamental truths, surfacing assumptions, reasoning upward, and anchoring against core engineering principles.

**Primary consumers:** AI assistants (Claude Code, Cursor, etc.)
**Secondary audience:** Human developers who want to understand and apply the methodology independently.

The skill is published as a Claude Code plugin on the Claude marketplace.

---

## Design Decisions

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| Core approach | Hybrid: decomposition-first with principle anchors | Gets the real power of first-principles reasoning (decompose then reason up) while using a principle catalog as a safety net, not the driver |
| Mode priority | Design > Architecture > Planning > Code Review | Reflects where first-principles thinking has the highest leverage |
| Output style | Layered: direct assessment + Socratic questions | Efficient for daily use, with depth available for learning |
| Relationship to other skills | Independent / standalone | Different lens applied deliberately, not coupled to brainstorming or planning workflows |
| Scale handling | Scale-agnostic with depth scaling | Simple/Moderate/Complex depth adapts to the subject |
| Target audience | AI-first, human-readable secondary | Skill instructs AI; docs teach humans |

---

## Core Framework: Five Phases

The skill operates as a five-phase reasoning engine that adapts its depth based on the mode and complexity.

### Phase 1: Decompose

Strip the problem down to its fundamental truths.

- What problem is actually being solved? (Not the solution — the *problem*)
- Who are the actors? What are their real needs?
- What are the hard, irreducible constraints? (Physics, business rules, regulatory, resource)
- What would a solution look like if we had zero legacy, zero convention, zero bias?

### Phase 2: Surface Assumptions

Identify what's been taken for granted.

- What technology choices were made by default rather than by reasoning?
- What patterns are being followed because "that's how it's done" vs. because they're the right fit?
- What requirements are actually requirements vs. inherited preferences?
- What's the cost of each assumption if it turns out to be wrong?

### Phase 3: Reason Upward

Given only the fundamentals from Phase 1, build toward what the solution *should* look like.

- What are the natural boundaries in this problem?
- What must change together? What can change independently?
- Where does data naturally live? How does it naturally flow?
- What are the simplest structures that satisfy the real constraints?

### Phase 4: Anchor Against Principles

Cross-check the reasoning against a catalog of fundamental principles to catch blind spots. The catalog is a reference, not a checklist — Phase 4 draws from it selectively based on relevance.

**Foundational Principles (Always Relevant):**

| Principle | Essence | Key Question |
|-----------|---------|--------------|
| Separation of Concerns | Each unit has one reason to exist and one reason to change | "If requirement X changes, how many places need to change?" |
| Information Hiding | Implementation details behind stable interfaces | "Can I change the internals without breaking consumers?" |
| Coupling & Cohesion | Related things together, unrelated things apart | "Do things that change together live together?" |
| Simplicity (YAGNI/KISS) | Nothing exists without justification from a real constraint | "What happens if I remove this?" |
| Single Source of Truth | Every piece of knowledge has one authoritative home | "If this fact changes, how many places need updating?" |

**Structural Principles (Architecture & Design Focus):**

| Principle | Essence | Key Question |
|-----------|---------|--------------|
| Least Privilege / Least Knowledge | Components know and access only what they need | "Does this component have access to things it doesn't use?" |
| Reversibility | Prefer decisions that are cheap to change | "What's the cost of unwinding this decision in 6 months?" |
| Dependency Direction | Depend on abstractions, not concretions; depend inward | "Does core logic depend on infrastructure, or vice versa?" |
| Fail-Fast / Explicit Errors | Surface problems at the earliest possible moment | "If this input is invalid, when does the system find out?" |
| Composition over Inheritance | Build behavior from small, combinable pieces | "Am I inheriting behavior I don't need?" |

**Operational Principles (Scale & Production Focus):**

| Principle | Essence | Key Question |
|-----------|---------|--------------|
| Observability | The system explains its own behavior | "If this breaks at 3am, can on-call understand what happened?" |
| Idempotency | Repeating an operation produces the same result | "What happens if this runs twice?" |
| Graceful Degradation | Partial failure doesn't mean total failure | "If dependency X goes down, does the whole system stop?" |
| Backpressure | Systems communicate their capacity limits | "What happens when load exceeds capacity?" |
| Least Astonishment | Behavior matches reasonable expectations | "Would a new team member be surprised by this?" |

The catalog is extensible. New principles can be added over time.

### Phase 5: Produce Assessment

Generate layered output:

- **Direct findings** — what's aligned with first principles, what's not, and why
- **Severity** — critical (fundamentally misaligned), moderate (assumption-driven risk), minor (convention over optimality)
- **Socratic questions** — deeper exploration prompts for each finding
- **Recommendations** — concrete suggestions, each traced back to the principle or fundamental truth it serves

---

## Four Modes of Operation

### Mode: Design Review (`/first-principles design`)

**When:** Evaluating a feature or system design before or during implementation.

**Input:** Design doc, spec, PRD, or verbal description. Reads relevant code if implementation has started.

**Phase emphasis:**
- Heavy on Phase 1 (Decompose) and Phase 2 (Surface Assumptions)
- Phase 3 produces an "ideal shape" to compare against the proposed design
- Phase 4 anchors against: Separation of Concerns, Cohesion, Information Hiding, Simplicity, Single Source of Truth

**Output focus:** Gap analysis between proposed design and what first-principles reasoning suggests.

### Mode: Architecture Review (`/first-principles architecture`)

**When:** Evaluating high-level architectural decisions — service boundaries, data storage, communication patterns, deployment topology.

**Input:** Architecture docs, diagrams (described), or inferred from codebase structure.

**Phase emphasis:**
- Phase 1 focuses on system-level constraints: scale, latency, consistency, team boundaries, operational requirements
- Phase 2 targets architectural cargo-culting
- Phase 3 reasons about natural service boundaries, data gravity, failure domains
- Phase 4 anchors against: Coupling, Least Knowledge, Reversibility, Fail-fast, Separation of Concerns

**Output focus:** Whether architecture follows from real constraints or from convention. Highlights high-cost irreversible decisions.

### Mode: Planning (`/first-principles plan`)

**When:** Starting something new — greenfield project or significant new feature.

**Input:** Problem statement, user needs, constraints. Can be informal.

**Phase emphasis:**
- Phase 1 is the star — deep decomposition before any solution is discussed
- Phase 2 challenges premature solution assumptions
- Phase 3 builds a skeleton design from fundamentals
- Phase 4 validates the skeleton
- Phase 5 output is forward-looking: decisions with reasoning, open questions, suggested decision order (most irreversible first)

**Output focus:** A principled foundation, not a complete design.

### Mode: Code Review (`/first-principles code`)

**When:** Reviewing existing code — PR review, legacy code analysis, refactoring assessment.

**Input:** File paths, PR diff, or description of what to review. Reads the code.

**Phase emphasis:**
- Phase 1 infers the problem from the code
- Phase 2 identifies code-level assumptions: magic numbers, implicit contracts, hidden coupling
- Phase 3 asks "given what this code needs to do, what's the simplest correct structure?"
- Phase 4 anchors against: Single Responsibility, Information Hiding, Coupling, Fail-fast, Simplicity

**Output focus:** Concrete code-level findings. Structural and logical issues, not style nits.

---

## Skill Invocation & Interaction

### Invocation

```
/first-principles <mode> [target]
```

- `/first-principles design` — review a design
- `/first-principles architecture` — review architecture
- `/first-principles plan` — plan a new project/feature
- `/first-principles code [path or PR]` — review code
- `/first-principles` (no mode) — skill assesses context and suggests appropriate mode

### Interaction Flow

```
User invokes skill
    │
    ▼
Skill determines mode (explicit or inferred)
    │
    ▼
Skill gathers input:
  - Reads relevant files/docs/code
  - Asks user for context if needed (max 2-3 targeted questions)
    │
    ▼
Skill runs five phases internally
    │
    ▼
Skill produces layered output
```

### Depth Scaling

- **Simple** (single component, small feature): Brief decomposition, 3-5 findings, lightweight output
- **Moderate** (multi-component feature, service design): Full decomposition, thorough assumption check, 5-10 findings
- **Complex** (system architecture, platform design): Deep decomposition, extensive assumption analysis, comprehensive findings with severity ratings

Inferred from input; user can override with `--depth deep`.

---

## Output Formats

### Assessment Report (Design, Architecture, Code Review modes)

```markdown
# First Principles Assessment: [Subject]
**Mode:** [Design | Architecture | Code Review]
**Depth:** [Simple | Moderate | Complex]

## Executive Summary
[2-3 sentences: what was reviewed, overall finding, most important insight]

## The Fundamental Problem
[What this is actually trying to solve, stripped of solution language]

## Assumptions Surfaced
- **Assumption:** [what's being taken for granted]
- **Risk if wrong:** [what breaks]
- **Justification found:** [none / partial / strong]

## Findings

### Critical
- **Finding:** [direct statement]
- **Principle:** [which principle is violated]
- **Reasoning:** [why this matters, traced to fundamentals]
- **Explore further:** [Socratic question]

### Moderate
[Same structure]

### Minor
[Same structure]

## What's Working Well
[Things well-aligned with first principles]

## Recommendations
1. [Action] — addresses Finding X, because [reasoning]
```

### Planning Report (Planning mode)

```markdown
# First Principles Foundation: [Project/Feature]

## The Problem (Decomposed)
[What we're actually solving]

## Constraints (Irreducible)
[Hard constraints any solution must satisfy]

## Assumptions (To Be Validated)
[Each should be consciously accepted or investigated]

## Key Decisions
[Ordered by irreversibility — most costly to change first]
1. **[Decision]**
   - What it determines: [scope of impact]
   - First-principles reasoning: [why this matters]
   - Options: [2-3 approaches with trade-offs]
   - Reversibility: [low/medium/high]

## Suggested Solution Shape
[High-level structure following from fundamentals]

## Open Questions
[Things needing answers before proceeding]
```

---

## Repository & Plugin Structure

```
first-principles-skills/
├── .claude-plugin/
│   └── plugin.json                    # Claude marketplace plugin manifest
├── skills/
│   └── first-principles/
│       ├── SKILL.md                   # Main skill file (Claude Code skill)
│       ├── references/
│       │   ├── principle-catalog.md   # Full principle catalog
│       │   └── output-templates.md    # Output format templates
│       └── modes/
│           ├── design-review.md       # Mode-specific guidance
│           ├── architecture-review.md
│           ├── planning.md
│           └── code-review.md
├── commands/
│   └── first-principles.md           # Slash command entry point
├── docs/
│   ├── methodology.md                # Standalone human-readable methodology
│   ├── principles/                   # Deep-dive on each principle (for humans)
│   │   ├── separation-of-concerns.md
│   │   ├── information-hiding.md
│   │   ├── coupling-and-cohesion.md
│   │   ├── simplicity.md
│   │   ├── single-source-of-truth.md
│   │   ├── least-privilege.md
│   │   ├── reversibility.md
│   │   ├── dependency-direction.md
│   │   ├── fail-fast.md
│   │   ├── composition-over-inheritance.md
│   │   ├── observability.md
│   │   ├── idempotency.md
│   │   ├── graceful-degradation.md
│   │   ├── backpressure.md
│   │   └── least-astonishment.md
│   └── examples/                     # Worked examples
│       ├── design-review-example.md
│       ├── architecture-review-example.md
│       └── planning-example.md
├── docs/superpowers/specs/           # Design specs
│   └── 2026-04-05-first-principles-skill-design.md
├── README.md                         # Overview, philosophy, quick start, install
├── CLAUDE.md                         # Project conventions for AI assistants
└── LICENSE                           # MIT license
```

### Plugin Manifest (`.claude-plugin/plugin.json`)

```json
{
  "name": "first-principles",
  "version": "1.0.0",
  "description": "Apply first-principles thinking to software design, architecture, planning, and code review. Decomposes problems to fundamentals, surfaces assumptions, and anchors findings against core engineering principles.",
  "author": {
    "name": "Viren",
    "url": "https://github.com/v1r3n"
  },
  "repository": "https://github.com/v1r3n/first-principles-skills",
  "license": "MIT",
  "keywords": [
    "first-principles",
    "design-review",
    "architecture",
    "code-review",
    "planning",
    "software-engineering",
    "principles",
    "reasoning"
  ]
}
```

### Skill File (`skills/first-principles/SKILL.md`)

The SKILL.md is the main artifact — it contains the complete instructions for the AI to execute the five-phase framework across all four modes. It references the principle catalog and mode-specific guidance files.

### Command File (`commands/first-principles.md`)

The slash command entry point that parses the mode argument and loads the skill. Enables `/first-principles design`, `/first-principles architecture`, etc.

---

## Marketplace Publishing

**Publishing path:** External/third-party plugin via the GitHub repo.

1. Plugin lives at `https://github.com/v1r3n/first-principles-skills`
2. Submit via the [plugin directory submission form](https://clau.de/plugin-directory-submission)
3. Users can install directly: `/plugin install first-principles` or test locally: `cc --plugin-dir /path/to/first-principles-skills`

**README.md** serves double duty: repo documentation and marketplace discovery page. It will include:
- Philosophy and approach overview
- Quick start / installation instructions
- Usage examples for each mode
- Link to the full methodology docs

---

## What's Out of Scope (v1)

- Hooks (no pre/post tool use automation needed)
- MCP servers (no external service integration)
- Agents (the skill runs in the main conversation context)
- Visual/diagram output (text-based only)
- Integration with other skills (independent by design)
- Automated fix application (the skill assesses and recommends; it doesn't modify code)
