# Least Astonishment

## In One Sentence

System behavior should match the reasonable expectations of the people who interact with it.

## The Key Question

"Would a new team member be surprised by how this works?"

## Why It Matters

Software systems are maintained by humans, used by humans, and debugged by humans. When a system behaves in ways that defy reasonable expectations, it creates a cognitive tax on everyone who interacts with it. A function called `getUser()` that modifies the database is surprising. An API endpoint that returns 200 OK with an error in the body is surprising. A "delete" button that archives instead of deleting is surprising. Each surprise demands mental effort to learn, remember, and work around.

The cost of astonishment scales with team size and turnover. A system designed by one person who understands all its quirks is usable by that one person. When new engineers join, each surprising behavior becomes a trap. They'll call `getUser()` expecting a read-only operation and introduce a subtle bug. They'll check for HTTP 200 and miss the error buried in the response body. The original designer may have had reasons for each decision, but those reasons are invisible to newcomers.

Least astonishment doesn't mean "make everything obvious to beginners." It means "follow established conventions and your own system's patterns consistently." If your API uses snake_case everywhere, one endpoint that uses camelCase is astonishing. If your system uses exceptions for error handling, one module that returns error codes is astonishing. Consistency is the foundation: once a developer understands one part of your system, they should be able to predict how the rest works.

## What Violation Looks Like

- A function named `validateOrder()` that validates the order and also saves it to the database as a side effect. Callers who just want to check validity end up creating records.
- An API that returns HTTP 200 for all responses, encoding success or failure in a custom JSON field. Clients that check status codes (the standard approach) will miss every error.
- A configuration key named `timeout` that, in one service, means connection timeout in milliseconds, and in another service, means request timeout in seconds. Copy-pasting configuration between services produces silent misbehavior.

## What Alignment Looks Like

- Functions named for what they do, with no hidden side effects. `validateOrder()` validates and returns a result. `saveOrder()` persists. `validateAndSaveOrder()` does both, and the name says so.
- HTTP APIs that use status codes according to their RFC definitions: 200 for success, 400 for client errors, 404 for missing resources, 500 for server errors. Clients that follow HTTP standards work correctly.
- A codebase with consistent naming conventions, error handling patterns, and project structure across all modules. A developer who has worked in one module can navigate any other module without a guide.

## Related Principles

- [Fail-Fast](fail-fast.md) -- Silent failures are among the most astonishing behaviors a system can exhibit. Failing explicitly is predictable; swallowing errors is surprising.
- [Single Source of Truth](single-source-of-truth.md) -- When the same concept has different representations in different places, it's surprising. A single source of truth eliminates this class of astonishment.
- [Simplicity](simplicity.md) -- Complex systems with many special cases are inherently more surprising than simple systems with consistent rules.

## The Litmus Test

Show a function signature, API endpoint, or configuration key to an engineer unfamiliar with the codebase. Ask them to predict what it does. If their prediction is wrong, the design violates least astonishment, and you should either rename, restructure, or document the unexpected behavior.
