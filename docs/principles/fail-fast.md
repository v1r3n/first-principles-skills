# Fail-Fast / Explicit Errors

## In One Sentence

Surface problems at the earliest possible moment with clear, actionable information.

## The Key Question

"If this input is invalid or this assumption is wrong, when does the system find out?"

## Why It Matters

The cost of a bug is roughly proportional to the distance between where the error originates and where it's detected. An invalid email address caught by input validation costs a user five seconds. The same invalid address discovered when a welcome email bounces three days later costs an engineer an hour of debugging, a support ticket, and a confused user.

Fail-fast systems are designed to detect problems as close to their source as possible. Input is validated at the boundary. Preconditions are checked at the top of functions. Configuration is validated at startup, not when the first request happens to use it. Contracts between modules are enforced explicitly rather than relying on callers to "just know" the rules.

Implicit failure is the opposite pattern, and it's insidious because the system appears to work. A function receives a null and passes it along instead of rejecting it. A configuration value is missing and the system silently falls back to a default that makes sense in development but causes data loss in production. A foreign key violation is caught and swallowed, leaving orphaned records that surface as mysterious bugs weeks later. Every implicit failure is a debugging timebomb.

## What Violation Looks Like

- A function that receives a null user ID and passes it through multiple layers before a NullPointerException finally occurs in an unrelated method, producing a stack trace that points nowhere near the actual bug.
- An application that reads configuration at startup but doesn't validate it until the first request touches the misconfigured path -- potentially hours later, and potentially in production under load.
- A data ingestion pipeline that silently drops malformed records instead of rejecting the batch, leading to slowly growing data gaps that aren't noticed until a downstream report looks wrong.

## What Alignment Looks Like

- Input validation at the API boundary that rejects malformed requests with specific error messages ("field 'email' must be a valid email address") before any business logic executes.
- An application that validates all required configuration values, database connectivity, and external service reachability during startup. If anything is wrong, it fails to start with an explicit message rather than starting and failing on the first relevant request.
- A type system used to make illegal states unrepresentable. Instead of accepting a `string` and checking if it's a valid currency code at runtime, the function accepts a `CurrencyCode` type that can only be constructed from valid values.

## Related Principles

- [Observability](observability.md) -- Failing fast generates the signals that observability systems capture. The two principles work together: fail-fast produces errors, observability makes them visible.
- [Least Astonishment](least-astonishment.md) -- Silent failures are the ultimate surprise. Explicit, early errors set clear expectations.
- [Graceful Degradation](graceful-degradation.md) -- These principles are complementary, not contradictory. Fail-fast applies to programming errors and invalid inputs. Graceful degradation applies to expected partial failures in distributed systems.

## The Litmus Test

Introduce a subtle error -- an invalid value, a missing configuration key, a malformed message -- at the edge of the system. How many layers does it travel before something notices? The fewer, the better.
