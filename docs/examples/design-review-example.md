# Worked Example: Design Review

> **Scenario:** A SaaS platform team has written a design doc for a new notification system. The design proposes a Notification Service with four sub-services (EmailService, SMSService, PushService, InAppService), a Preferences Database, and a polling-based delivery pipeline. The user invokes `/fp:design` and pastes the design summary.

---

## Phase 1: Decompose

**What problem is actually being solved?**

The design doc title is "Notification Service Design," but that names a solution, not a problem. Working backward: why do notifications exist? Users need to know when something requires their attention. The fundamental problem is **attention routing** — getting the right information to the right person at the right time through the right channel.

**Actors and real needs:**

- **End users** — need to learn about events that require their action, without being overwhelmed by noise
- **Product teams** — need to trigger user-facing messages when domain events occur, without building channel-specific logic
- **Ops/on-call** — need to understand delivery failures and why a user did or did not receive a message

**Irreducible constraints:**

- External channel APIs (email via SMTP/SES, SMS via Twilio, push via APNs/FCM) — these are physics; we cannot change them
- Users must be able to control what they receive — regulatory (CAN-SPAM, GDPR) and product requirement
- Delivery latency expectations vary by channel: push/in-app within seconds, email within minutes, SMS within seconds

**Clean-slate sketch:**

An event-driven router that receives domain events, resolves user preferences, selects channel(s), and dispatches. Channel adapters handle protocol differences but share the core routing and preference logic.

---

## Phase 2: Surface Assumptions

| Assumption | Source | Cost if Wrong |
|---|---|---|
| Polling-based delivery (workers poll a notifications queue table every 30s) | Default — carried over from the existing batch email system | **High** — adds 30s latency to push/SMS, which users expect in real-time; will require a full rewrite to move to event-driven |
| Each channel needs its own service with separate deployment | Convention — "microservices means separate services" | **Medium** — four services share ~80% of their logic (preference lookup, template rendering, delivery tracking); maintaining four copies creates drift and bugs |
| User preferences stored in a dedicated Preferences DB, separate from the User DB | Preference — the team "didn't want to touch the User service" | **High** — creates a second source of truth for user data; preference changes in one DB won't reflect in the other without sync logic that doesn't exist in the design |
| All four channels needed at launch | Unexamined — the design lists all four as launch requirements | **Medium** — in-app and email cover 90% of use cases; SMS and push could ship later, reducing launch scope by half |

---

## Phase 3: Reason Upward

Starting from the fundamental problem (attention routing), the natural structure emerges:

1. **Domain events are the trigger, not API calls.** The notification system should react to events ("order shipped," "payment failed"), not receive pre-formatted messages. This keeps channel logic out of product code.

2. **Preference resolution is the core, not a side concern.** The most important decision is "should this user see this event, and through which channel?" This logic is the heart of the system, not a lookup in a side database.

3. **Channel dispatch is an adapter, not a service.** Email, SMS, push, and in-app differ only in protocol and payload format. The shared logic (template rendering, delivery tracking, retry policy) is identical. A single service with channel adapters is the natural structure.

4. **Delivery should be event-driven, not polled.** The domain events are already asynchronous. Consuming them from a message bus and dispatching immediately matches the natural data flow — polling adds latency and complexity for no benefit.

**Derived structure:** Event bus -> NotificationRouter (preference resolution + template rendering) -> ChannelAdapter (email | sms | push | in-app) -> DeliveryTracker.

---

## Phase 4: Anchor Against Principles

**Separation of Concerns** — Partially aligned. The design correctly separates channels from each other. But it fails to separate the routing concern (who gets what) from the dispatch concern (how to send it). Routing logic is duplicated across all four services.

**Single Source of Truth** — Violated. User preferences live in a Preferences DB while user contact info (email, phone, device tokens) lives in the User DB. The design has no sync mechanism. When a user changes their email, the Preferences DB will serve stale data. *"If a user updates their email address, how many databases need to know?"*

**Simplicity (YAGNI)** — Violated. Four separate services for four channels that share 80% of their logic. The design justifies this as "independent scaling," but the scale requirements (stated in the doc as ~50K notifications/day) don't warrant independent scaling. A single service handles this volume trivially. *"What specific scaling bottleneck requires separate deployments for channels that process 12K messages/day each?"*

**Reversibility** — Mixed. The polling-based approach is easy to replace (medium reversibility), but the four-service split creates distributed state and inter-service contracts that are expensive to consolidate later (low reversibility).

**Coupling & Cohesion** — Misaligned. Things that change together (template rendering, delivery tracking, retry logic) are spread across four services. Things that change independently (channel protocols) are correctly separated but at the wrong granularity — they should be adapters within a service, not separate services.

---

## Phase 5: Assessment

# First Principles Assessment: Notification System Design
**Mode:** Design
**Depth:** Moderate

## Executive Summary

The notification system design solves the wrong problem at the wrong granularity. It treats "send notifications through multiple channels" as the problem, when the actual problem is "route user attention to the right channel." This framing error leads to an over-decomposed architecture (four services for one concern) and a data model that violates single source of truth.

## The Fundamental Problem

Users need to know when something requires their attention. The system must decide what to tell them, through which channel, respecting their preferences and channel-specific constraints (latency, format, deliverability). The core challenge is intelligent routing, not message dispatch.

## Assumptions Surfaced

- **Assumption:** Polling-based delivery is acceptable
- **Risk if wrong:** Push and SMS latency bloated by 30s; user-facing impact on time-sensitive notifications (2FA codes, security alerts)
- **Justification found:** None — inherited from the batch email system

- **Assumption:** Each channel requires a separate service
- **Risk if wrong:** 80% shared logic duplicated four ways; bugs fixed in one service but not others; deployment coordination overhead for a 4-person team
- **Justification found:** None — "independent scaling" cited but volume doesn't warrant it

- **Assumption:** Preferences stored separately from user data
- **Risk if wrong:** Stale contact info served to channel dispatchers; user updates their phone number but SMS goes to old number
- **Justification found:** Partial — avoids coupling to User service, but creates a worse problem (data inconsistency)

## Findings

### Critical

- **Finding:** User preferences and contact information are split across two databases with no synchronization mechanism
- **Principle:** Single Source of Truth
- **Reasoning:** When a user changes their email or phone number in the User DB, the Preferences DB has no way to learn about it. The design creates a consistency gap in the most sensitive part of the system — where to deliver messages.
- **Explore further:** If a user changes their phone number and immediately triggers a 2FA SMS, which number receives it?

### Moderate

- **Finding:** Four separate services duplicate the shared logic of template rendering, delivery tracking, retry, and preference lookup
- **Principle:** Coupling & Cohesion
- **Reasoning:** These concerns change together (e.g., a new retry policy should apply to all channels). Distributing them across four services means coordinated deployments for what should be a single change. For a 4-person team, this is a significant operational burden.
- **Explore further:** When you add a fifth channel (e.g., Slack or webhook), do you create a fifth service, or does the pattern break down?

- **Finding:** Polling-based delivery adds unnecessary latency for real-time channels
- **Principle:** Simplicity
- **Reasoning:** The system already has domain events. Polling a database table converts an event-driven input into a batch process, then converts it back to individual dispatches. This is complexity that produces worse results.
- **Explore further:** What problem does polling solve that consuming events directly from the bus would not?

### Minor

- **Finding:** All four channels are scoped for launch when email + in-app cover the primary use cases
- **Principle:** Simplicity (YAGNI)
- **Reasoning:** SMS and push add external vendor integration, device token management, and carrier-specific edge cases. Deferring them reduces launch scope significantly without blocking the core value.
- **Explore further:** What percentage of your current users have opted into push notifications or provided phone numbers?

## What's Working Well

- **Channel separation as a concept** is sound — email and SMS have genuinely different delivery semantics, failure modes, and retry strategies. The instinct to separate them is correct; the granularity (services vs. adapters) is what needs adjustment.
- **Preference-aware delivery** is the right approach — many notification systems skip user preferences and just blast all channels, leading to notification fatigue.
- **Delivery tracking** is included in the design from the start, which supports observability.

## Recommendations

1. **Merge the four channel services into one NotificationRouter with pluggable channel adapters** — addresses the cohesion finding. Shared logic lives once; channel-specific protocol handling is an adapter interface. This cuts deployment units from four to one and eliminates cross-service coordination.

2. **Move user notification preferences into the User service or read contact info from User DB at dispatch time** — addresses the Single Source of Truth violation. Either colocate preferences with user data, or always fetch contact info fresh from the authoritative source at send time.

3. **Replace polling with event consumption from the existing message bus** — addresses the latency finding. Domain events are already published; the notification system should subscribe to them directly. This eliminates the notifications queue table and the 30s polling delay.

4. **Launch with email and in-app only; add SMS and push as fast-follows** — addresses the YAGNI finding. The adapter pattern from recommendation 1 makes adding channels later a matter of implementing a new adapter, not deploying a new service.
