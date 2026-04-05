# Idempotency

## In One Sentence

Repeating an operation should produce the same result as executing it once.

## The Key Question

"What happens if this operation runs twice?"

## Why It Matters

In any distributed system -- and most modern systems are distributed -- operations will sometimes be executed more than once. A network timeout occurs, and the client retries the request. A message broker delivers the same message twice. A cron job overlaps with its previous run. A user double-clicks a submit button. If the operation isn't idempotent, the second execution creates a duplicate order, sends a duplicate email, charges a credit card twice, or corrupts data.

Idempotency is the property that makes retry-safety possible. When an operation is idempotent, retrying it is always safe. This fundamentally simplifies error handling: instead of building elaborate exactly-once delivery mechanisms (which are impossible in the general case), you build at-least-once delivery and make the operations safe to repeat.

The pattern applies at every level. HTTP PUT and DELETE are defined as idempotent. Database upserts (INSERT ... ON CONFLICT UPDATE) are idempotent. Infrastructure-as-code tools are designed to be idempotent -- running `terraform apply` twice produces the same infrastructure. When you design operations as idempotent from the start, the entire system becomes more resilient to the inevitable imperfections of distributed computing.

## What Violation Looks Like

- A payment API endpoint that creates a new charge every time it's called with the same parameters. A client retry due to a network timeout results in a double charge.
- A message consumer that appends a record to a database for every message received, with no deduplication. Reprocessing a message (due to broker redelivery or consumer restart) creates duplicate records.
- A deployment script that runs database migrations by executing raw SQL statements without tracking which migrations have already been applied. Running the script twice creates duplicate tables or fails with "table already exists" errors.

## What Alignment Looks Like

- A payment API that accepts an idempotency key with each request. If the same key is submitted twice, the second request returns the result of the first without creating a new charge. Stripe's API is a well-known example of this pattern.
- A message consumer that uses a deduplication table or message ID to detect and skip messages it has already processed. Redelivered messages are acknowledged and discarded.
- Infrastructure provisioning using declarative tools (Terraform, Kubernetes manifests, CloudFormation) where the tool computes the delta between desired state and actual state. Applying the same configuration twice results in no changes on the second run.

## Related Principles

- [Fail-Fast](fail-fast.md) -- Idempotency lets you fail fast and retry safely. If an operation fails, you can immediately retry without worrying about partial execution creating inconsistencies.
- [Graceful Degradation](graceful-degradation.md) -- Idempotent operations enable retry-based recovery, which is a key mechanism for graceful degradation under transient failures.
- [Single Source of Truth](single-source-of-truth.md) -- Idempotency often depends on a single source of truth for operation state (e.g., an idempotency key store) to detect duplicates.

## The Litmus Test

Take any write operation in the system. Execute it twice with identical inputs. If the second execution changes the system state beyond what the first execution produced, the operation is not idempotent, and you should ask what happens when (not if) it gets retried.
