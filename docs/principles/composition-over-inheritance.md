# Composition over Inheritance

## In One Sentence

Build behavior by combining small, focused components rather than extending class hierarchies.

## The Key Question

"Am I inheriting behavior I don't need in order to get behavior I do?"

## Why It Matters

Inheritance creates one of the tightest forms of coupling in object-oriented programming. A subclass is coupled not just to its parent's public interface, but to its implementation details -- internal state, method call order, constructor requirements, and side effects. Changes to the parent class can break subclasses in subtle ways, especially when the parent's behavior is overridden in some subclasses but not others. This is the fragile base class problem, and it makes deep inheritance hierarchies some of the hardest code to maintain.

Composition achieves code reuse by assembling behavior from independent parts. Instead of creating a `LoggingDatabaseConnection` that extends `DatabaseConnection`, you create a `Logger` and a `DatabaseConnection` and use them together. Each component has a clear, narrow interface. You can swap, test, and evolve them independently. You can combine them in ways the original authors never anticipated.

The practical difference becomes clear at scale. Inheritance hierarchies grow by adding layers. Every new requirement that doesn't fit the existing hierarchy either forces a refactor of the hierarchy or produces an awkward subclass that overrides half its parent. Composition grows by adding components. A new requirement is a new component, wired into the existing set. The existing components don't change.

## What Violation Looks Like

- A `BaseController` class that all controllers extend to get authentication, logging, and error handling. Some controllers don't need authentication, so they override the auth method to do nothing -- inheriting a capability just to disable it.
- A four-level deep class hierarchy (`Animal -> Mammal -> DomesticAnimal -> Dog`) where adding a `RobotDog` requires either multiple inheritance or a parallel hierarchy, because the taxonomy doesn't accommodate the new concept.
- A `BaseService` that provides database access, caching, and metrics collection. A new service that only needs metrics must either extend the full `BaseService` or duplicate the metrics code.

## What Alignment Looks Like

- Middleware pipelines (Express, ASP.NET, Django) where authentication, logging, rate-limiting, and error handling are independent, composable functions. Each endpoint declares which middleware it uses. No inheritance required.
- A payment processor built from composable components: a `Validator`, a `FraudChecker`, a `Gateway`, and a `Notifier`. New payment methods add a new `Gateway` implementation; everything else stays the same.
- React hooks or custom composables that encapsulate behavior (data fetching, form state, animation) as independent, reusable units. Components assemble the hooks they need, rather than extending a base component.

## Related Principles

- [Coupling and Cohesion](coupling-and-cohesion.md) -- Inheritance creates tight coupling between parent and child. Composition keeps coupling explicit and minimal.
- [Separation of Concerns](separation-of-concerns.md) -- Each composable unit handles one concern. Inheritance often bundles multiple concerns into a single hierarchy.
- [Simplicity](simplicity.md) -- Flat composition is easier to understand than deep hierarchies. You can see all the parts at the assembly point.

## The Litmus Test

Look at any class that uses inheritance. Ask: "Could I achieve the same reuse by passing a collaborator object instead of extending a parent class?" If yes, composition is probably the better choice.
