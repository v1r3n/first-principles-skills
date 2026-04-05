# Backpressure

## In One Sentence

Systems should communicate their capacity limits and push back on producers when demand exceeds what they can handle.

## The Key Question

"What happens when load exceeds capacity?"

## Why It Matters

Every system has a throughput limit. The question is not whether that limit exists, but what happens when it's reached. Without backpressure, the answer is usually one of two bad outcomes: the system falls over entirely (out of memory, thread pool exhaustion, cascading timeouts), or it silently drops work (lost messages, abandoned connections, incomplete processing). Both outcomes are worse than the alternative: telling the producer to slow down.

Backpressure is the mechanism by which a downstream system signals to an upstream system that it's at capacity. TCP's flow control is backpressure. HTTP 429 (Too Many Requests) is backpressure. A bounded queue that blocks when full is backpressure. A load balancer that returns 503 when all backends are busy is backpressure. The pattern is universal: rather than accepting more work than you can handle and degrading quality for everyone, you explicitly reject or defer excess work so that the work you do accept gets processed correctly.

The absence of backpressure is a common cause of cascading failures. Service A sends requests to Service B faster than B can process them. B's request queue grows unboundedly. B's memory usage climbs. B starts garbage collecting aggressively, slowing down further. B's response times increase, causing A's requests to time out. A retries, sending even more requests. B runs out of memory and crashes. Without backpressure, overload becomes failure becomes worse overload.

## What Violation Looks Like

- An unbounded in-memory queue between a message consumer and a processing pipeline. Under high load, the queue grows until the process runs out of memory and is killed by the OOM killer.
- An API that accepts every incoming request regardless of how many are already in flight. Under sustained load, response times degrade for all users because the server is context-switching between thousands of concurrent requests rather than completing any of them.
- A data pipeline where the ingestion rate is decoupled from the processing rate with no feedback mechanism. Data accumulates in a staging area until disk space runs out or processing lag becomes unacceptable.

## What Alignment Looks Like

- A bounded work queue with a configured maximum depth. When the queue is full, producers receive an explicit "queue full" response and can decide whether to retry, drop, or route to an overflow path.
- An API gateway that enforces rate limits per client and per endpoint, returning HTTP 429 with a `Retry-After` header. Clients know exactly when they can retry, and the backend is protected from overload.
- A streaming pipeline using reactive streams (e.g., Project Reactor, RxJava, Kafka consumer configuration) where the consumer controls how many items it pulls from the producer. The producer cannot overwhelm the consumer because the consumer sets the pace.

## Related Principles

- [Graceful Degradation](graceful-degradation.md) -- Backpressure is one mechanism for graceful degradation: instead of failing under load, the system degrades by rejecting excess work.
- [Fail-Fast](fail-fast.md) -- Rejecting work you can't handle is a form of failing fast. It's better to return an immediate 429 than to accept the request and time out 30 seconds later.
- [Observability](observability.md) -- Backpressure events (rejected requests, full queues, rate-limit hits) must be observable. If you can't see backpressure happening, you can't tune your capacity or identify abusive clients.

## The Litmus Test

Send 10x your expected peak traffic to any component. Does it degrade gracefully and recover when load subsides, or does it collapse and require manual intervention to restart? If the latter, it lacks backpressure.
