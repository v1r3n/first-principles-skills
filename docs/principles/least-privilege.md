# Least Privilege / Least Knowledge

## In One Sentence

Components should know and access only what they need to fulfill their responsibility -- nothing more.

## The Key Question

"Does this component have access to things it doesn't use?"

## Why It Matters

Every unnecessary permission, dependency, or piece of knowledge a component holds is a liability. A service that has write access to a database table it only reads from can accidentally corrupt data. A module that receives an entire user object when it only needs an email address is coupled to the user schema for no reason. A Lambda function with `AdministratorAccess` can be exploited to do anything in the AWS account if compromised.

Least privilege limits the blast radius of mistakes and security breaches. When a component can only access what it needs, a bug in that component can only damage what it touches. When a credential is compromised, the attacker gains access to only the resources that credential covers. This principle applies at every layer: IAM policies, database grants, API scopes, function parameters, and module imports.

Beyond security, least privilege improves comprehensibility. When a function's signature declares exactly what it needs, you can understand its behavior without reading its implementation. When a service's IAM role lists five specific permissions instead of a wildcard, you know exactly what the service does with external resources. Narrow interfaces are self-documenting interfaces.

## What Violation Looks Like

- A microservice running with a database user that has full DDL privileges (CREATE, DROP, ALTER) when it only needs SELECT and INSERT on two tables.
- A function that accepts a full `User` object as a parameter but only accesses the `email` field. Every caller must now construct or have access to a full `User` even when they only have an email address.
- An OAuth integration that requests `read:org`, `write:repo`, `admin:hooks`, and `delete:repo` scopes when the application only reads repository metadata.

## What Alignment Looks Like

- IAM roles scoped to the exact resources and actions each service needs. The order-processing service can read from the orders table and write to the shipments queue, and nothing else.
- Functions that accept the specific data they need (`sendNotification(email: string, message: string)`) rather than broad objects (`sendNotification(user: User, context: NotificationContext)`).
- API tokens with short lifetimes and narrow scopes, rotated automatically. Each integration gets its own token with the minimum permissions for its use case.

## Related Principles

- [Information Hiding](information-hiding.md) -- Information hiding restricts what a module reveals; least privilege restricts what it can access. They're complementary.
- [Separation of Concerns](separation-of-concerns.md) -- Well-separated concerns naturally have narrow access requirements, because each concern touches only its own domain.
- [Coupling and Cohesion](coupling-and-cohesion.md) -- Broad access creates implicit coupling. Narrowing access forces explicit, minimal dependencies.

## The Litmus Test

For any component, list everything it can access -- database tables, API endpoints, environment variables, function parameters. Cross-reference that list with what the component actually uses. Every item on the first list that isn't on the second list is an excess privilege.
