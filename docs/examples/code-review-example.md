# Worked Example: Code Review

> **Scenario:** A developer submits a PR containing an authentication module. The reviewer invokes `/fp:code` on the file `src/auth/login.ts`. The module handles user login with validation, rate limiting, token generation, audit logging, and session management — all within a single function.

---

## Input: The Code Under Review

```typescript
// src/auth/login.ts

import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { db } from "../db";
import { redis } from "../redis";
import { sendEmail } from "../email";

const JWT_SECRET = "sk-auth-2024-prod-key";
const SESSION_TTL = 86400;

export async function login(email: string, password: string, ip: string) {
  // Rate limiting
  const attempts = await redis.get(`login:${ip}`);
  if (attempts && parseInt(attempts) > 5) {
    await db.query(
      "INSERT INTO audit_log (event, email, ip, timestamp) VALUES ($1,$2,$3,$4)",
      ["rate_limited", email, ip, new Date()]
    );
    throw new Error("Too many attempts");
  }

  // Find user
  const result = await db.query("SELECT * FROM users WHERE email = $1", [email]);
  const user = result.rows[0];
  if (!user) {
    await redis.incr(`login:${ip}`);
    await redis.expire(`login:${ip}`, 900);
    throw new Error("Invalid credentials");
  }

  // Check password
  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    await redis.incr(`login:${ip}`);
    await redis.expire(`login:${ip}`, 900);
    // Lock account after 10 failed password attempts
    const failCount = await db.query(
      "SELECT COUNT(*) FROM audit_log WHERE email=$1 AND event='failed_login' AND timestamp > NOW() - INTERVAL '1 hour'",
      [email]
    );
    if (parseInt(failCount.rows[0].count) >= 10) {
      await db.query("UPDATE users SET locked = true WHERE email = $1", [email]);
      await sendEmail(email, "Account Locked", "Your account has been locked due to multiple failed login attempts.");
    }
    await db.query(
      "INSERT INTO audit_log (event, email, ip, timestamp) VALUES ($1,$2,$3,$4)",
      ["failed_login", email, ip, new Date()]
    );
    throw new Error("Invalid credentials");
  }

  // Check if account is locked
  if (user.locked) {
    throw new Error("Account is locked");
  }

  // Generate token
  const token = jwt.sign(
    { userId: user.id, email: user.email, role: user.role },
    JWT_SECRET,
    { expiresIn: "24h" }
  );

  // Create session
  await redis.set(`session:${user.id}`, JSON.stringify({
    token,
    ip,
    userAgent: "unknown",
    createdAt: new Date().toISOString(),
  }), "EX", 86400);

  // Audit log
  await db.query(
    "INSERT INTO audit_log (event, email, ip, timestamp) VALUES ($1,$2,$3,$4)",
    ["login_success", email, ip, new Date()]
  );

  // Update last login
  await db.query("UPDATE users SET last_login = $1 WHERE id = $2", [new Date(), user.id]);

  return { token, userId: user.id };
}
```

---

## Phase 1: Decompose

**What is this code actually doing?**

Reading the function line by line, it performs five distinct responsibilities:

1. **Rate limiting** — tracking and enforcing login attempt limits per IP (lines 13-20)
2. **Authentication** — verifying the user's identity via email/password (lines 23-46)
3. **Account security** — locking accounts after repeated failures, sending notification emails (lines 36-42)
4. **Session management** — creating JWT tokens and Redis sessions (lines 53-65)
5. **Audit logging** — recording login events for security review (lines 18-19, 43-46, 68-71)

These are five separate concerns with five different reasons to change, five different failure modes, and five different testing requirements — all woven into a single 60-line function.

**Irreducible constraints:**

- Authentication must be correct — a flaw here is a security vulnerability
- Rate limiting must execute before expensive operations (password hashing)
- Audit logging must capture both successes and failures
- The function is called on every login — performance matters

---

## Phase 2: Surface Assumptions

| Assumption | Location | Cost if Wrong |
|---|---|---|
| bcrypt is the permanent password hashing algorithm | `login.ts:31` — `bcrypt.compare` is hardcoded | **High** — migrating hashing algorithms (e.g., to argon2) requires changing this function and writing a migration strategy; no abstraction layer exists |
| JWT secret is a hardcoded string | `login.ts:7` — `const JWT_SECRET = "sk-auth-2024-prod-key"` | **Critical** — secret is in source code, visible in version control; if the repo is compromised, all tokens are compromised; rotation requires a code change and deploy |
| Rate limit threshold is 5 attempts per 15 minutes | `login.ts:14,27-28` — magic numbers `5` and `900` | **Medium** — tuning rate limits requires code changes and deployment; different environments (dev, staging, prod) cannot have different limits |
| Session TTL is 24 hours | `login.ts:8,62` — `86400` appears twice as a magic number | **Medium** — TTL is duplicated: once in the constant (line 8, unused for JWT), once in the JWT `expiresIn` (line 57, string "24h"), and once in the Redis `EX` (line 62, number 86400). Three representations of one value. Changing it requires finding and updating all three. |
| Account lockout is determined by counting audit log rows | `login.ts:36-39` — query counts `failed_login` events in the last hour | **Medium** — the lockout decision depends on audit log retention and query performance; if audit logs are archived or pruned, lockout stops working; this couples a security mechanism to a logging mechanism |

---

## Phase 3: Reason Upward

Given that this code handles five distinct concerns, what's the simplest correct structure?

**Natural boundaries:**

Each responsibility has a different reason to change and a different testing surface:
- Rate limiting changes when abuse patterns change (tuning thresholds, switching from IP-based to account-based)
- Authentication changes when password policies change (algorithm upgrade, MFA addition)
- Account security changes when security policies change (lockout rules, notification content)
- Session management changes when session requirements change (TTL, multi-device, token format)
- Audit logging changes when compliance requirements change (what to log, retention, format)

**Simplest correct structure:**

```
validateInput(email, password, ip)        // fail fast — before any I/O
  -> checkRateLimit(ip)                   // fail fast — before expensive operations
  -> authenticate(email, password)        // core responsibility: verify identity
  -> checkAccountStatus(user)             // verify account is usable
  -> createSession(user, ip)              // establish session
  -> auditLog("login_success", ...)       // record outcome
```

Each step is a function with a single responsibility, testable in isolation, with dependencies injected rather than hardcoded. The `login` function becomes an orchestrator that calls these steps in sequence.

**Dependencies should be injected, not imported:**

The current function reaches directly into `db`, `redis`, `sendEmail`, and hardcoded constants. This makes testing require a real database and Redis instance (or complex mocking of module imports). Injecting these dependencies makes each function testable with simple stubs.

---

## Phase 4: Anchor Against Principles

**Separation of Concerns** — Violated. Five concerns in one function. If the rate limiting strategy changes (e.g., from IP-based to account-based), the developer must modify the same function that handles token generation and audit logging. The blast radius of any change spans the entire authentication flow. *"If the rate limiting strategy changes, how many unrelated concerns could you accidentally break?"*

**Information Hiding** — Violated. Any caller of `login()` is implicitly coupled to the internal flow: rate limiting happens first, then lookup, then password check, then lock check. If the order changes (e.g., check lock status before password comparison — which is actually the correct order), callers don't know, but the audit log behavior changes. The internal implementation is not hidden; it leaks through side effects.

**Fail-Fast** — Violated. The account lock check (`if (user.locked)`) happens at line 49, after the expensive `bcrypt.compare` call at line 31. A locked account still triggers password hashing (CPU-intensive), database queries for failure counting, and potentially an email send — all before discovering the account is locked. The lock check should be the first thing after user lookup.

**Single Source of Truth** — Violated. Session TTL is expressed three ways: `const SESSION_TTL = 86400` (declared but not used for JWT), `expiresIn: "24h"` (JWT option as a string), and `"EX", 86400` (Redis TTL as a number). If someone changes one and misses the others, the JWT expiry and Redis session expiry will diverge, creating sessions that are valid by token but expired in Redis, or vice versa.

**Simplicity** — Partially violated. The account lockout mechanism depends on counting rows in the audit log table, coupling a security mechanism to a logging mechanism. If audit logs are archived, rotated, or the query becomes slow on large tables, the lockout feature breaks silently.

---

## Phase 5: Assessment

# First Principles Code Review: Authentication Module
**Depth:** Moderate
**Files reviewed:** `src/auth/login.ts`

## Executive Summary

The `login()` function correctly implements authentication logic but violates fundamental engineering principles by combining five distinct concerns into a single function. The most urgent issue is a hardcoded JWT secret in source code — a security vulnerability. Beyond that, the function's structure makes it difficult to test, difficult to modify safely, and contains a logic error where locked accounts still trigger expensive password hashing before the lock is checked.

## Inferred Responsibilities

This code handles: (1) IP-based rate limiting, (2) credential authentication via bcrypt, (3) account lockout with email notification, (4) JWT token generation and Redis session creation, and (5) security audit logging. These five responsibilities serve different stakeholders (security team, product, compliance) and change for different reasons.

## Assumptions Surfaced

- **Assumption:** JWT secret can live in source code
- **Location:** `login.ts:7`
- **Risk if wrong:** Repository compromise exposes the signing key; all issued tokens can be forged; secret rotation requires code change and deploy; the secret is visible to every developer with repo access

- **Assumption:** bcrypt will remain the hashing algorithm
- **Location:** `login.ts:31`
- **Risk if wrong:** Algorithm migration (to argon2id, for example) requires modifying the authentication function directly; no abstraction supports multiple algorithms during a migration period

- **Assumption:** Session TTL is always 24 hours across all contexts
- **Location:** `login.ts:7-8, 57, 62`
- **Risk if wrong:** Three representations of the same value will diverge; JWT and Redis session expiry will mismatch, causing either premature session expiry or ghost sessions

## Findings

### Critical

- **Finding:** JWT signing secret is hardcoded in source code
- **Location:** `login.ts:7`
- **Code:** `const JWT_SECRET = "sk-auth-2024-prod-key";`
- **Principle:** Information Hiding
- **Reasoning:** The secret is in plain text in version control. Anyone with read access to the repository can forge authentication tokens. The secret cannot be rotated without a code change and deployment. This is a security vulnerability, not just a code quality issue.
- **Explore further:** Is this secret currently in a production repository? If so, it should be considered compromised and rotated immediately, regardless of other changes.

### Moderate

- **Finding:** Five responsibilities in one function make changes risky and testing expensive
- **Location:** `login.ts:12-76` (entire function)
- **Principle:** Separation of Concerns
- **Reasoning:** Modifying rate limiting logic risks breaking token generation. Testing authentication requires setting up rate limiting state. Testing audit logging requires running through the entire login flow. Each concern should be independently testable and modifiable.
- **Explore further:** How do you currently test the rate limiting behavior? Do your tests require a running Redis instance?

- **Finding:** Locked account check occurs after expensive password hashing
- **Location:** `login.ts:49` (lock check) vs. `login.ts:31` (bcrypt compare)
- **Code:**
  ```typescript
  const valid = await bcrypt.compare(password, user.password_hash); // line 31 — expensive
  // ... 18 lines of failure handling ...
  if (user.locked) { // line 49 — should be first
  ```
- **Principle:** Fail-Fast
- **Reasoning:** `bcrypt.compare` is intentionally CPU-intensive (~100ms). For a locked account, this work is wasted. Worse, a locked account still increments the rate limiter and triggers the lockout counting query. Checking `user.locked` immediately after user lookup (line 24) short-circuits all unnecessary work.
- **Explore further:** Under a credential-stuffing attack against locked accounts, how much CPU is consumed by unnecessary bcrypt operations?

- **Finding:** Session TTL expressed three different ways with no single source
- **Location:** `login.ts:8, 57, 62`
- **Code:**
  ```typescript
  const SESSION_TTL = 86400;                    // line 8 — unused for JWT
  { expiresIn: "24h" }                          // line 57 — JWT expiry as string
  "EX", 86400                                   // line 62 — Redis TTL as number
  ```
- **Principle:** Single Source of Truth
- **Reasoning:** Three representations of "24 hours" that must be kept in sync manually. The declared constant `SESSION_TTL` is not even used by the JWT configuration, which has its own string literal. A developer changing the Redis TTL might not find the JWT string, creating sessions that are valid by token but expired in the session store.
- **Explore further:** If you changed `SESSION_TTL` to 3600, would the system behave correctly? (Answer: no — JWT would still use "24h".)

### Minor

- **Finding:** Rate limit values are magic numbers with no configuration path
- **Location:** `login.ts:14, 27-28`
- **Code:**
  ```typescript
  if (attempts && parseInt(attempts) > 5)       // line 14 — why 5?
  await redis.expire(`login:${ip}`, 900);       // line 28 — why 900?
  ```
- **Principle:** Information Hiding
- **Reasoning:** Threshold (5) and window (900s) are embedded in logic with no documentation of why these values were chosen. Tuning requires a code change and deploy. Different environments cannot use different values.
- **Explore further:** Were these values chosen based on analysis of real traffic patterns, or are they defaults?

- **Finding:** Account lockout depends on counting audit log rows
- **Location:** `login.ts:36-39`
- **Principle:** Coupling & Cohesion
- **Reasoning:** The lockout mechanism is coupled to the audit log table. If audit logs are archived, the lockout query returns fewer results and stops locking accounts. These are two different concerns (security enforcement vs. compliance logging) that should not depend on each other's data.
- **Explore further:** What happens to account lockout if the audit_log table is partitioned or rows older than 30 days are archived?

## What's Working Well

- **Consistent error messages for invalid credentials.** Both "user not found" and "wrong password" return `"Invalid credentials"`, preventing user enumeration. This is a security best practice that many auth implementations get wrong.
- **Rate limiting exists and runs before authentication.** The instinct to rate-limit before expensive operations is correct (though the lock check ordering undermines this for locked accounts).
- **Audit logging captures both successes and failures.** The function logs rate limits, failed logins, and successful logins, providing a complete audit trail for security review.

## Recommendations

1. **Move JWT secret to environment configuration immediately** at `login.ts:7` — addresses the Critical finding. Replace `const JWT_SECRET = "sk-auth-2024-prod-key"` with `const JWT_SECRET = process.env.JWT_SECRET`. Add a startup check that fails fast if the variable is missing. Rotate the compromised secret.

2. **Move the lock check to immediately after user lookup** at `login.ts:24-26` — addresses the Fail-Fast finding. Insert `if (user.locked) { auditLog("locked_login_attempt", ...); throw new Error("Account is locked"); }` before the `bcrypt.compare` call. This eliminates wasted CPU and prevents locked accounts from affecting rate limit counters.

3. **Extract each responsibility into its own function with dependency injection** across `login.ts:12-76` — addresses the Separation of Concerns finding. Create: `checkRateLimit(ip, limiter)`, `authenticate(email, password, userRepo)`, `checkAccountStatus(user)`, `createSession(user, ip, sessionStore)`, `auditLog(event, context, logger)`. The `login()` function becomes an orchestrator that calls these in sequence.

4. **Define session TTL once and derive all representations from it** at `login.ts:8` — addresses the Single Source of Truth finding. Define `const SESSION_TTL_SECONDS = 86400` and use it everywhere: `{ expiresIn: SESSION_TTL_SECONDS }` for JWT (jsonwebtoken accepts seconds), `"EX", SESSION_TTL_SECONDS` for Redis.

5. **Extract rate limit and lockout thresholds to configuration** at `login.ts:14, 28, 38` — addresses the magic numbers finding. Move to a config object: `{ rateLimit: { maxAttempts: 5, windowSeconds: 900 }, lockout: { maxFailures: 10, windowMinutes: 60 } }`. This enables per-environment tuning and documents the intent of each value.

6. **Decouple account lockout from audit log storage** at `login.ts:36-39` — addresses the coupling finding. Track failed attempts in a dedicated counter (Redis key or `users.failed_attempts` column) rather than querying the audit log. Reset the counter on successful login.
