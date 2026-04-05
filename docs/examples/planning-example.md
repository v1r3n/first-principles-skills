# Worked Example: Planning

> **Scenario:** An engineering team at a growing startup (30 engineers, 5 squads) says "we need feature flags." They've had two incidents in the past month caused by deploying code that wasn't ready for production. The tech lead invokes `/fp:plan` with: "We need to build a feature flag system. We're thinking of using LaunchDarkly but want to evaluate building our own first."

---

## Phase 1: Decompose

**What problem is actually being solved?**

The stated problem is "we need feature flags," but that names a solution. Working backward:

- Why feature flags? "To decouple deployment from release."
- Why decouple deployment from release? "Because our deploy-release coupling causes incidents."
- Why does deploy-release coupling cause incidents? "Because we deploy code that isn't ready, and we can't turn it off without a rollback."

The fundamental problem is **release risk management**: the team needs the ability to ship code safely and recover quickly when something goes wrong. Feature flags are one solution to this problem, but not the only one.

**Actors and real needs:**

- **Engineers** — need to deploy code without fear; need to control when a feature is visible to users without a redeploy
- **Product managers** — need to roll out features gradually; need to measure impact before full release
- **On-call engineers** — need to disable a broken feature in seconds, not minutes (current rollback takes 8-12 minutes)
- **QA** — need to test features in production-like environments before public release

**Irreducible constraints:**

- 30 engineers across 5 squads — system must be self-service, not bottlenecked on one team
- Deploys happen 3-5 times per day — flag evaluation must not add meaningful latency
- Current stack: TypeScript/Node.js backend, React frontend, PostgreSQL database
- Budget: startup, so cost matters, but not as much as engineering time
- The system must not become a single point of failure — if the flag system is down, the application should still work

**Clean-slate sketch:**

The simplest system that solves release risk management: a way to wrap unreleased code in a conditional that can be toggled without a deploy, with a UI for non-engineers to see and control the state. Everything beyond that needs justification from a specific constraint.

---

## Phase 2: Surface Assumptions

| Assumption | Source | Cost if Wrong |
|---|---|---|
| We need a full feature flag platform (targeting, segmentation, percentage rollouts, A/B testing) | Preference — the team has seen LaunchDarkly demos and is thinking in terms of its feature set | **Medium** — building targeting and segmentation is 10x the effort of boolean toggles; if the real problem is release risk, boolean toggles solve 90% of it |
| We should build our own | Preference — engineering teams often prefer building to buying | **High** — a production-grade flag system with SDKs, UI, audit logging, and reliability guarantees is a significant project; maintaining it is ongoing cost |
| Every feature needs a flag | Unexamined — no criteria for when to use flags vs. when a plain deploy is fine | **Medium** — flag proliferation creates tech debt; stale flags accumulate and become dead code branches that nobody removes |
| Flags need to evaluate in real-time (no caching) | Unexamined — assumed because "flags should be instant" | **Low** — most flags don't change frequently; caching with a 30-second TTL satisfies the "disable broken features quickly" requirement while being far simpler |
| We need client-side (React) and server-side (Node.js) flag evaluation | Requirement — both frontend and backend features need flags | **Low** — this is a real requirement, but the implementation can start server-side only and add client-side later |

---

## Phase 3: Reason Upward

Starting from the fundamental problem (release risk management), what's the minimal solution?

**Level 1: The irreducible core**

A feature flag is, at minimum, a named boolean that code checks at runtime and that an operator can toggle without deploying. This solves the stated problem: deploy code behind a flag, toggle it on when ready, toggle it off if it breaks.

**Implementation:** A `flags` table in the existing PostgreSQL database with columns `(name, enabled, updated_at)`. A thin SDK that queries this table (with in-memory caching and a 30-second refresh interval). An admin page in the existing internal tools app.

This is ~2 days of work and solves the two incidents that motivated this project.

**Level 2: What the team actually needs next**

After boolean toggles are working, the next real need is percentage rollouts — the ability to enable a feature for 10% of users, then 50%, then 100%. This is the "gradual release" use case that product managers need.

**Implementation:** Add a `rollout_percentage` column and a `user_id`-based hashing function for deterministic assignment. The SDK resolves `isEnabled(flagName, userId)` by hashing `flagName + userId` and comparing against the percentage threshold. ~1-2 days of additional work.

**Level 3: What might be needed later**

Targeting by user attributes (plan type, geography, company), A/B testing with metrics integration, and flag dependencies are legitimate features but not justified by any current constraint. Building them now is speculative.

**The build vs. buy decision from first principles:**

The fundamental question is: does the team's problem justify the ongoing maintenance cost of a custom system?

- Boolean toggles + percentage rollouts: trivial to build, trivial to maintain. Build.
- Full targeting/segmentation platform: substantial to build, ongoing maintenance burden. Buy (LaunchDarkly, Unleash, Flagsmith) only when a concrete need arises.

The decision isn't binary — start with a simple built solution, migrate to a vendor if/when the requirements outgrow it.

---

## Phase 4: Anchor Against Principles

**Reversibility** — The build-simple-first approach has high reversibility. Boolean toggles in PostgreSQL can be migrated to any flag vendor later by implementing their SDK interface. If the team builds a complex custom platform, migrating away is expensive (custom targeting rules, SDK integration points, admin UI workflows). Starting simple preserves optionality.

**Simplicity (YAGNI)** — Boolean toggles solve the stated problem (two incidents from deploy-release coupling). Percentage rollouts solve the next concrete need (gradual releases). Everything beyond that is speculative. *"What specific feature, with a specific user story, requires targeting rules today?"*

**Single Source of Truth** — The flag state must live in one place. A `flags` table in PostgreSQL is the single source. The SDK caches for performance but always refreshes from the database. If the team later adds a config file override or environment variable fallback, there must be a clear precedence order to avoid conflicting sources.

**Fail-Fast** — The flag SDK must handle the "flag system is down" case. If the database is unreachable, the SDK should serve cached values (graceful degradation), not crash the application. Missing flags should default to "disabled" (safe by default), and the SDK should log a warning so stale flags are noticed.

**Separation of Concerns** — Flag evaluation (should this user see this feature?) should be separate from flag management (creating, toggling, auditing flags). The SDK handles evaluation. The admin UI handles management. Neither should know about the other's internals.

---

## Phase 5: Assessment

# First Principles Foundation: Feature Flag System

## The Problem (Decomposed)

The team needs release risk management: the ability to deploy code safely and recover quickly when something goes wrong. Two recent incidents were caused by deploying code that was not ready for production, with rollback taking 8-12 minutes. The team needs a mechanism to decouple deployment from release — shipping code that is not yet active, and disabling it in seconds if problems arise.

This is not a "feature flag platform" problem. It is a safety net problem. The solution should be as simple as the problem.

## Constraints (Irreducible)

- Flag evaluation must add <10ms latency per check (application performance)
- Must work in both Node.js backend and React frontend
- 30 engineers across 5 squads must be able to create and manage flags self-service
- If the flag system is unavailable, the application must continue to function
- Must support the current deploy cadence of 3-5 deploys/day

## Assumptions (To Be Validated)

- **Assumption:** Boolean toggles + percentage rollouts cover current needs
- **Why we're assuming it:** The two triggering incidents would have been prevented by a simple on/off toggle; product has mentioned "gradual rollouts" but not "target users in segment X"
- **How to validate:** Ask product managers to list the next 5 features they want to roll out gradually and confirm that percentage-based rollout (not attribute-based targeting) is sufficient

- **Assumption:** Building simple is cheaper than buying and configuring LaunchDarkly
- **Why we're assuming it:** Boolean toggles are ~2 days of work; LaunchDarkly evaluation, procurement, integration, and training is likely 1-2 weeks; ongoing cost is ~$300-500/month
- **How to validate:** Get a LaunchDarkly trial, time the integration, compare total cost of ownership over 12 months

- **Assumption:** Flag cleanup won't be a problem if we keep it simple
- **Why we're assuming it:** Simple boolean flags are easy to grep for and remove
- **How to validate:** Establish a flag lifecycle policy before shipping: flags must have an owner and a planned removal date; review stale flags in the weekly engineering sync

## Key Decisions

*Ordered by irreversibility — most costly to change first.*

1. **Build vs. buy**
   - What it determines: Ongoing maintenance responsibility, feature ceiling, migration cost
   - First-principles reasoning: The current problem (deploy safety) requires a simple solution. Building a simple system is fast and creates no vendor dependency. Buying a platform provides features that aren't needed yet and creates integration coupling.
   - Options:
     - A: Build boolean toggles + percentage rollouts in-house (~3-4 days). Migrate to a vendor later if needs grow. *Trade-off: limited features, but solves the actual problem; migration cost if needs outgrow it.*
     - B: Adopt LaunchDarkly now (~1-2 weeks integration). Full feature set from day one. *Trade-off: ongoing cost ($300-500/mo), vendor dependency, features the team doesn't need yet.*
     - C: Deploy open-source solution (Unleash, Flagsmith) (~1 week setup). Self-hosted, full features. *Trade-off: operational burden of hosting, but no vendor lock-in and more features than option A.*
   - Reversibility: Medium (A->B migration is straightforward; B->A is painful)

2. **Flag storage backend**
   - What it determines: Latency, reliability, operational complexity
   - First-principles reasoning: Flags are small, rarely changing key-value pairs. The existing PostgreSQL database handles this trivially. A separate data store (Redis, etcd) adds operational cost with no benefit at this scale.
   - Options:
     - A: PostgreSQL table with in-memory SDK cache (30s refresh). *Trade-off: 30s propagation delay; leverages existing infrastructure.*
     - B: Redis with pub/sub for instant propagation. *Trade-off: new infrastructure dependency, but near-instant flag changes.*
   - Reversibility: High (storage backend is behind the SDK interface; swappable)

3. **SDK API design**
   - What it determines: How every engineer in the company interacts with flags; hard to change once adopted
   - First-principles reasoning: The API should be minimal, hard to misuse, and forward-compatible. `isEnabled(flagName)` for boolean checks, `isEnabled(flagName, userId)` for percentage rollouts. This interface is compatible with every vendor SDK, making future migration painless.
   - Options:
     - A: Minimal interface: `isEnabled(name, context?)` returning boolean. *Trade-off: simple, forward-compatible, but no typed variants.*
     - B: Rich interface with typed variants, default values, event hooks. *Trade-off: more expressive, but harder to migrate away from.*
   - Reversibility: Low (SDK API is used across the entire codebase; changing it is expensive)

## Suggested Solution Shape

**Phase 1 (Week 1):** Boolean toggles
- `flags` table in PostgreSQL: `(name VARCHAR PRIMARY KEY, enabled BOOLEAN, description TEXT, owner TEXT, created_at TIMESTAMP, updated_at TIMESTAMP)`
- Node.js SDK: loads all flags on startup, refreshes every 30s, exposes `isEnabled(name): boolean`
- Admin page in existing internal tools: list flags, toggle on/off, create/delete
- Default behavior: unknown flag returns `false` (safe by default), logs warning

**Phase 2 (Week 2):** Percentage rollouts
- Add `rollout_percentage INTEGER` column (0-100, null means use `enabled` boolean)
- SDK: `isEnabled(name, userId?)` — if percentage is set, hash `name+userId` for deterministic bucket assignment
- Admin UI: slider for rollout percentage

**Phase 3 (When needed, not before):** Evaluate whether to migrate to a vendor or build further
- Trigger: a concrete product requirement for user-attribute targeting or A/B testing with metrics
- Decision inputs: number of flags in use, team satisfaction with the current system, total maintenance cost over the preceding quarter

## Open Questions

1. **What is the acceptable flag propagation delay?** — if 30 seconds is too slow for incident response, the storage backend decision changes (Redis pub/sub for near-instant, at the cost of new infrastructure). Blocks: Decision 2.

2. **Should the frontend evaluate flags client-side or receive resolved flags from the backend?** — client-side evaluation requires shipping flag configuration to the browser (exposing flag names and rollout logic). Server-side resolution is simpler and more secure but requires a network call. Blocks: SDK API design for React.

3. **Who owns flag lifecycle?** — flags that outlive their purpose become dead code. The team needs a policy before the first flag ships: who creates, who reviews, who removes. Blocks: nothing, but prevents future tech debt.

4. **Is there an existing internal tools framework, or does the admin UI need to be built from scratch?** — this affects the Phase 1 timeline estimate. Blocks: Phase 1 delivery date.
