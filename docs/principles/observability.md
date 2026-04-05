# Observability

## In One Sentence

The system should explain its own behavior so that operators can understand what happened, why, and what to do about it.

## The Key Question

"If this breaks at 3am, can the on-call engineer understand what happened without reading the source code?"

## Why It Matters

There is a fundamental asymmetry in software operations: building a system takes months, but diagnosing a production incident may take minutes -- or it needs to. The difference between a 5-minute resolution and a 5-hour outage often comes down to whether the system produces enough information to make its internal state visible from the outside.

Observability is not the same as monitoring. Monitoring asks known questions ("Is CPU above 80%? Is error rate above 1%?"). Observability equips you to answer questions you haven't thought of yet. When a user reports that their order confirmation took 30 seconds, you need to trace that specific request through every service it touched, see where the time was spent, and understand the state of the system at that moment. You can't predefine a dashboard for every possible failure mode.

The three pillars -- structured logs, metrics, and distributed traces -- each serve a different purpose. Logs capture discrete events with context. Metrics track aggregate behavior over time. Traces follow individual requests across service boundaries. Together, they let you move from "something is wrong" to "this specific thing is wrong because of that specific cause" without deploying debug code or restarting services.

## What Violation Looks Like

- A service that logs unstructured text messages like `"Processing order..."` and `"Done."` with no request ID, no timing information, and no structured fields. Correlating logs across services is impossible.
- A distributed system with no trace propagation. When a request fails, each service's logs must be manually correlated by timestamp -- which doesn't work reliably under concurrent load.
- A batch processing job that reports only success or failure at the end, with no visibility into individual record processing. When it fails halfway through, there's no way to know which records were processed and which weren't.

## What Alignment Looks Like

- Every log entry includes a correlation ID, timestamp, service name, and structured fields relevant to the operation. Searching by correlation ID returns the complete history of a request across all services.
- Key business operations emit metrics (request count, latency percentile, error rate by type) that feed alerting rules. The team can detect anomalies before users report them.
- Distributed tracing is enabled across all services, with spans annotating significant operations (database queries, cache lookups, external API calls). A trace view shows exactly where time was spent for any given request.

## Related Principles

- [Fail-Fast](fail-fast.md) -- Failing fast produces the errors and exceptions that observability surfaces. Without fail-fast, problems are silent; without observability, even loud problems go unheard.
- [Graceful Degradation](graceful-degradation.md) -- Observability is what tells you that the system has degraded. Without it, you don't know you're running in degraded mode until a user complains.
- [Separation of Concerns](separation-of-concerns.md) -- Observability instrumentation should be separate from business logic. Cross-cutting concerns like logging and tracing are best handled by middleware or aspect-oriented patterns.

## The Litmus Test

Imagine a user reports a problem with a specific operation. Can you, without modifying code, trace that operation from the edge of the system to every backend it touches, see what happened at each step, and identify the root cause? If not, observability is insufficient.
