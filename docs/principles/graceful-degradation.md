# Graceful Degradation

## In One Sentence

Partial failure should not mean total failure -- the system should continue providing value with reduced capability rather than stopping entirely.

## The Key Question

"If dependency X goes down, does the whole system stop?"

## Why It Matters

In a distributed system, partial failures are not exceptional -- they are the normal operating condition. Network partitions, service outages, database failovers, and overloaded dependencies happen regularly. A system that treats every dependency as essential will be down as often as its least reliable component. If you depend on five services and each has 99.9% availability, a system without graceful degradation has at best 99.5% availability (0.999^5).

Graceful degradation is the design strategy of deciding, in advance, what the system can still do when parts of it fail. An e-commerce site whose recommendation engine goes down should still display products and accept orders -- it just shows generic recommendations or none at all. A ride-sharing app whose surge pricing service is unavailable should still match riders with drivers, perhaps at a default rate. The key insight is that most features are not equally critical, and users would rather have a working system with reduced functionality than a broken system with no functionality.

This requires explicit decisions about which capabilities are essential and which are optional. Those decisions must be made during design, not during an incident. Circuit breakers, fallback responses, timeout budgets, and feature flags are the implementation tools, but the real work is the product decision: "What does the degraded experience look like, and is it acceptable?"

## What Violation Looks Like

- An API gateway that returns 500 for all requests when the authentication service is slow, even though some endpoints are public and don't require authentication.
- A checkout page that fails entirely because the "customers also bought" recommendation service is unresponsive. The critical path (placing an order) is blocked by a non-critical dependency.
- A monitoring dashboard that shows a blank page when one of six data sources is unavailable, instead of rendering the five panels that have data and showing an error state for the sixth.

## What Alignment Looks Like

- A product page that displays cached pricing when the real-time pricing service is down, with a subtle indicator that prices may not reflect current promotions. Users can still browse and buy.
- A circuit breaker on the fraud detection service that, when the circuit opens, allows low-risk transactions to proceed while flagging them for manual review later. The business continues operating with a slightly different risk posture.
- A mobile app that caches the last known state and operates in read-only mode when the backend is unreachable, synchronizing changes when connectivity is restored.

## Related Principles

- [Fail-Fast](fail-fast.md) -- These principles complement each other. Fail-fast catches programming errors and invalid inputs early. Graceful degradation handles expected infrastructure failures at runtime. Knowing which failures to fail-fast on and which to degrade around is a critical design decision.
- [Observability](observability.md) -- You need to know when the system is operating in degraded mode. Without observability, degraded operation can persist unnoticed, potentially causing subtle data issues.
- [Backpressure](backpressure.md) -- Backpressure is a mechanism for graceful degradation under load: instead of failing, the system signals that it needs the caller to slow down.

## The Litmus Test

List every external dependency your system has. For each one, answer: "What does the user experience look like when this dependency is completely unavailable?" If the answer is "the system stops working," that dependency is a single point of failure and needs a degradation strategy.
