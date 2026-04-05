# Worked Example: Architecture Review

> **Scenario:** A startup runs an e-commerce platform built as 12 microservices, operated by a team of 4 developers. They process a few hundred orders per day. The team reports that shipping features takes longer than expected and debugging production issues is painful. They invoke `/fp:architecture` and describe the system.

---

## Phase 1: Decompose

**What problem is actually being solved?**

An e-commerce platform that lets customers browse products, place orders, and receive deliveries. The business needs to ship features quickly, maintain uptime during business hours, and keep operational costs manageable for a seed-stage startup.

**Actors and real needs:**

- **Customers** — need a reliable shopping experience; page loads under 2s, checkout that doesn't fail, accurate inventory
- **4-person dev team** — need to ship features weekly, debug issues quickly, deploy with confidence
- **Business** — needs to iterate on product-market fit fast; operational cost must stay low

**Irreducible constraints:**

- Team size: 4 developers (hard resource constraint)
- Scale: hundreds of orders/day, thousands of daily active users (measured, not projected)
- Budget: seed-stage; infrastructure cost is scrutinized monthly
- Uptime: business hours reliability matters; 3am downtime is acceptable
- Compliance: PCI for payment processing (can be offloaded to Stripe)

**Clean-slate sketch:**

Given 4 developers, hundreds of orders/day, and the need for iteration speed, the simplest system that satisfies all constraints is a well-structured monolith with clear module boundaries, a single relational database, and a third-party payment processor. Twelve network boundaries for four developers and hundreds of orders per day is solving a scaling problem that does not exist.

---

## Phase 2: Surface Assumptions

| Assumption | Source | Cost if Wrong |
|---|---|---|
| Microservices are the right architecture for this system | Convention — "modern platforms use microservices" | **High** — 12 services for 4 developers means each developer owns 3 services; cross-service features require coordinating deployments across multiple repos; debugging requires tracing calls across services |
| Kafka for inter-service communication | Convention — "event-driven architecture is best practice" | **High** — Kafka adds operational burden (broker management, partition tuning, consumer group coordination) for a system that processes ~200 messages/day; a simple database-backed queue or direct HTTP calls would suffice |
| Each service has its own database (but 8 of 12 services connect to the same PostgreSQL instance, different schemas) | Convention — "microservices should own their data" | **Medium** — the team followed the pattern in name but not in practice; services still share a database, getting the worst of both worlds (cross-service queries are forbidden by convention but trivially possible, creating hidden coupling) |
| Services must communicate asynchronously via events | Convention — "synchronous calls create coupling" | **Medium** — the order flow requires Product, Inventory, Pricing, Cart, Checkout, Payment, Fulfillment, and Notification services to coordinate; what should be a single transaction is now a distributed saga with manual compensation logic |
| The system will need to scale to millions of orders | Projection — no evidence this is near-term | **High** — premature optimization for scale has traded away the team's primary asset: development velocity |

---

## Phase 3: Reason Upward

Starting from the fundamentals — 4 developers, hundreds of orders, need for speed:

**Natural boundaries in this problem:**

The e-commerce domain has genuine conceptual boundaries: catalog management, order processing, payment, fulfillment, and customer accounts. But "conceptual boundary" does not mean "network boundary." At this scale, these are modules within an application, not distributed services.

**What must change together:**

When the team adds a new product attribute (e.g., "color"), it touches catalog display, search filtering, cart line items, and order history. In the current architecture, this is a change to 4+ services with coordinated deployment. In a monolith, it is one PR.

**Where data naturally lives:**

All core data (products, orders, customers, inventory) is relational and highly interconnected. Orders reference products and customers. Inventory is a constraint on orders. Pricing depends on products and promotions. This data has high gravity — it wants to live together in one relational database, accessed through well-defined module interfaces.

**Simplest structure that satisfies constraints:**

A modular monolith with:
- Clear module boundaries matching the domain (catalog, orders, payments, fulfillment, accounts)
- A single PostgreSQL database with schema-level separation between modules
- Module interfaces enforced by code (public API surfaces per module, private internals)
- Payment processing delegated to Stripe (PCI compliance offloaded)
- A single deployment artifact, one CI/CD pipeline, one set of logs

This satisfies every irreducible constraint. Adding network boundaries is warranted only when a specific constraint demands it — and none currently do.

---

## Phase 4: Anchor Against Principles

**Reversibility** — Violated. Distributed transactions (sagas with compensation logic across 5 services for a single order) are extremely hard to unwind. The team has built irreversible infrastructure for a problem they don't have. Consolidating back to a monolith means migrating data, rewriting inter-service contracts, and untangling async event flows. *"What is the cost of unwinding the distributed order saga in 6 months if you decide monolith was the right call?"*

**Coupling & Cohesion** — Violated. The architecture claims loose coupling but achieves the opposite. Eight services share a PostgreSQL instance. Services call each other in long chains (Cart -> Pricing -> Inventory -> Product). A change to the Product schema cascades through four services. The coupling is the same as a monolith, but with network hops, serialization overhead, and distributed failure modes added. *"Do things that change together live together? Or do they change together but live apart?"*

**Simplicity** — Violated. The system has 12 services, a Kafka cluster, a service mesh, distributed tracing infrastructure, and a saga orchestrator. The actual business logic (CRUD operations on products, orders, and customers) is straightforward. The infrastructure-to-logic ratio is inverted — more code manages distributed systems concerns than solves business problems.

**Separation of Concerns** — Partially aligned. The domain boundaries are well-identified (catalog, orders, payments). The mistake is in how they're separated: network boundaries instead of module boundaries. Separation of Concerns does not require separate deployments.

**Observability** — Degraded by architecture. Debugging an order failure requires correlating logs across 5+ services, following Kafka message traces, and checking saga state. In a monolith, it would be a single stack trace. The team has distributed tracing, but they report that tracing a production issue still takes hours. *"If an order fails at 2pm, how long does it take to identify the root cause?"*

**Least Privilege / Least Knowledge** — Violated. Services share a database instance, meaning each service technically has access to every other service's data. The "separate schema" convention is enforced by team discipline, not by infrastructure. A single misconfigured connection string exposes all data.

---

## Phase 5: Assessment

# First Principles Assessment: E-Commerce Platform Architecture
**Mode:** Architecture
**Depth:** Complex

## Executive Summary

This architecture solves a scaling problem the business does not have, at the cost of the asset it needs most: development velocity. Twelve microservices for four developers and hundreds of daily orders creates distributed systems complexity — coordinated deployments, distributed debugging, saga-based transactions — without the scaling benefits that justify that complexity. The architecture was adopted from convention ("microservices are modern") rather than derived from constraints.

## The Fundamental Problem

Enable a small team to build and iterate on an e-commerce platform quickly, serving hundreds of orders per day with acceptable reliability, at startup-stage costs. The primary constraint is team bandwidth, not system throughput.

## Assumptions Surfaced

- **Assumption:** Microservices are necessary for a well-architected system
- **Risk if wrong:** Each developer owns 3 services; cross-cutting features require multi-service coordination; debugging is 5-10x slower than in a monolith
- **Justification found:** None for current scale — microservices solve team scaling and independent deployment problems that a 4-person team doesn't have

- **Assumption:** Kafka is needed for inter-service messaging
- **Risk if wrong:** Operational overhead of a distributed message broker for ~200 orders/day; a single PostgreSQL table with a background worker would handle this volume for years
- **Justification found:** None — no throughput or decoupling requirement that justifies it

- **Assumption:** The system will need to handle millions of orders soon
- **Risk if wrong:** The team is optimizing for a future that may not arrive, while paying the complexity cost today; if the business pivots (common at seed stage), the architecture is expensive to adapt
- **Justification found:** None — no growth data or contractual commitment supports this projection

## Findings

### Critical

- **Finding:** The architecture introduces distributed systems complexity for a workload that a single application server handles trivially
- **Principle:** Simplicity
- **Reasoning:** Hundreds of orders per day is roughly 0.002 requests/second for order processing. A single Node.js or Python process handles thousands of requests/second. The 12-service architecture adds network latency, serialization, distributed failure modes, and operational overhead with zero throughput benefit. The team's primary complaint — slow feature delivery — is a direct consequence.
- **Explore further:** If you could rebuild this system in a single weekend hackathon, would you choose 12 services?

- **Finding:** Distributed order processing (saga across 5 services) creates an irreversible architectural commitment for a problem that is naturally transactional
- **Principle:** Reversibility
- **Reasoning:** An order is: validate cart, check inventory, calculate price, charge payment, create order record. This is a single database transaction in a monolith. The saga pattern with compensation logic across 5 services is orders of magnitude more complex, harder to reason about, and nearly impossible to consolidate later without a rewrite.
- **Explore further:** How many production incidents in the last quarter were caused by saga failures, partial completions, or inconsistent state across services?

### Moderate

- **Finding:** Eight services share a PostgreSQL instance, creating hidden coupling while losing the benefits of a shared database
- **Principle:** Coupling & Cohesion
- **Reasoning:** The architecture has the operational overhead of separate services (network boundaries, separate deployments, inter-service contracts) combined with the coupling of a shared database (schema changes can cascade, connection pool contention). This is the worst of both approaches.
- **Explore further:** If two services share a database, in what meaningful sense are they separate services?

- **Finding:** Kafka operates at a fraction of its designed capacity, creating operational burden without benefit
- **Principle:** Simplicity
- **Reasoning:** Kafka is designed for high-throughput event streaming (millions of messages/second). At ~200 orders/day, the team maintains broker infrastructure, monitors consumer lag, manages partitions, and handles rebalancing — all for a workload that a database-backed job queue handles trivially. The operational knowledge required to run Kafka reliably is a significant tax on a 4-person team.
- **Explore further:** How many hours per month does the team spend on Kafka-related operational tasks (broker maintenance, debugging consumer issues, partition management)?

### Minor

- **Finding:** Service mesh and distributed tracing add infrastructure that would be unnecessary in a simpler architecture
- **Principle:** Simplicity
- **Reasoning:** These are good tools for managing distributed systems complexity. But the better question is whether the distributed systems complexity should exist at all. Removing the disease is better than treating the symptoms.
- **Explore further:** What percentage of your infrastructure budget goes to tools that manage the complexity of distribution vs. tools that deliver business value?

## What's Working Well

- **Domain boundaries are well-identified.** The team has a clear understanding of bounded contexts (catalog, orders, payments, fulfillment, accounts). This knowledge transfers directly to module boundaries in a monolith.
- **PCI compliance is offloaded to Stripe.** This is correct first-principles reasoning — delegate the hardest compliance problem to a specialist.
- **Observability investment** (distributed tracing, structured logging) shows operational maturity. These practices carry over regardless of architecture.

## Recommendations

1. **Consolidate into a modular monolith with the same domain boundaries as modules** — addresses the core Simplicity and Reversibility findings. Preserve the team's domain modeling work as module interfaces, but remove network boundaries. A single deployment artifact eliminates coordinated releases, distributed debugging, and saga complexity.

2. **Replace Kafka with a PostgreSQL-backed job queue (e.g., pg-boss, Oban, or a simple SKIP LOCKED query)** — addresses the Kafka operational overhead finding. At hundreds of orders/day, a database-backed queue is simpler to operate, easier to debug, and has no additional infrastructure cost.

3. **Replace the distributed saga with a database transaction** — addresses the Reversibility finding. Order processing becomes: BEGIN, validate, reserve inventory, charge payment (via Stripe API), create order, COMMIT. If any step fails, ROLLBACK. This is simpler, faster, and correct by construction.

4. **Enforce module boundaries with code, not networks** — addresses the Coupling finding. Use package-private/internal visibility, defined public API surfaces per module, and architecture tests (e.g., ArchUnit) to enforce boundaries. This gives you the modularity benefits of microservices without the operational cost.

5. **Plan the migration as a strangler fig: consolidate incrementally** — start with the most painful cross-service flow (order processing), merge those services into a single module, validate, and repeat. Keep Stripe integration as-is. Target 2-3 months for full consolidation, with each step independently deployable.
