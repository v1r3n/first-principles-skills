Use the template matching your current mode. Adapt section depth to complexity — a simple review gets brief sections, a complex one gets thorough sections. Skip sections that don't apply (e.g., "Assumptions Surfaced" might be empty for a trivial code review).

## Assessment Report (Design and Architecture modes)

```markdown
# First Principles Assessment: [Subject]
**Mode:** [Design | Architecture]
**Depth:** [Simple | Moderate | Complex]

## Executive Summary
[2-3 sentences: what was reviewed, overall finding, most important insight]

## The Fundamental Problem
[What this is actually trying to solve, stripped of solution language.
What are the irreducible constraints.]

## Assumptions Surfaced
[For each assumption found:]
- **Assumption:** [what's being taken for granted]
- **Risk if wrong:** [what breaks]
- **Justification found:** [none / partial / strong]

## Findings

### Critical
[Findings where the solution is fundamentally misaligned with the problem]
- **Finding:** [direct statement]
- **Principle:** [which principle is violated or relevant]
- **Reasoning:** [why this matters, traced to fundamentals]
- **Explore further:** [Socratic question for deeper thought]

### Moderate
[Same structure as Critical — findings where assumptions introduce risk]

### Minor
[Same structure — findings where convention is chosen over optimality]

## What's Working Well
[Things that ARE well-aligned with first principles — this isn't just a criticism tool]

## Recommendations
[Numbered, concrete, each tied to a finding]
1. [Action] — addresses Finding X, because [reasoning]
```

## Code Review Report (Code Review mode)

```markdown
# First Principles Code Review: [Subject]
**Depth:** [Simple | Moderate | Complex]
**Files reviewed:** [list of file paths]

## Executive Summary
[2-3 sentences: what was reviewed, overall finding, most important insight]

## Inferred Responsibilities
[What this code is actually trying to do, derived from reading it — not from
comments or documentation, but from what the code actually does]

## Assumptions Surfaced
[For each assumption found in the code:]
- **Assumption:** [what's being taken for granted]
- **Location:** [file:line_number or file:function_name]
- **Risk if wrong:** [what breaks]

## Findings

### Critical
- **Finding:** [direct statement]
- **Location:** [file:line_number or range]
- **Code:** [relevant snippet, if short]
- **Principle:** [which principle is violated]
- **Reasoning:** [why this matters, traced to fundamentals]
- **Explore further:** [Socratic question]

### Moderate
[Same structure]

### Minor
[Same structure]

## What's Working Well
[Code patterns that are well-aligned with first principles]

## Recommendations
[Numbered, concrete, each with file:location]
1. [Action] at [file:location] — addresses Finding X, because [reasoning]
```

## Planning Report (Planning mode)

```markdown
# First Principles Foundation: [Project/Feature]

## The Problem (Decomposed)
[What we're actually solving, stripped of solution language]

## Constraints (Irreducible)
[Hard constraints that any solution must satisfy — physics, business rules,
regulatory, resource limitations]

## Assumptions (To Be Validated)
[Things we're assuming that should be consciously accepted or investigated]
- **Assumption:** [what]
- **Why we're assuming it:** [reasoning]
- **How to validate:** [concrete step]

## Key Decisions
[Ordered by irreversibility — most costly to change first]
1. **[Decision name]**
   - What it determines: [scope of impact]
   - First-principles reasoning: [why this matters]
   - Options:
     - A: [approach] — [trade-offs]
     - B: [approach] — [trade-offs]
   - Reversibility: [low / medium / high]

## Suggested Solution Shape
[High-level structure that follows from the fundamentals — not a detailed
design, but the natural shape implied by the constraints and decisions]

## Open Questions
[Genuine unknowns that need answers before proceeding]
1. [Question] — blocks [which decision or aspect]
```
