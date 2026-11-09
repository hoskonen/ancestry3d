# 0004 — Authoritative world clock ownership

Status — Accepted
Approval date — 2026-11-08
Related — [Task 10A world time design](../architecture/10-world-time-design.md)

## Context and problem

The sandbox's day/night flag describes lighting. Future simulation needs monotonic game time that can pause, scale and cross multiple boundaries without depending on a lighting scene.

## Alternatives

- Make the environment's day/night state authoritative. This would couple gameplay to scene presentation and its debug controls.
- Introduce an autoload or use engine-global time scaling. This would make ownership global before multiple scenes need a shared timeline and could affect unrelated processing.
- Use a scene-independent clock value object owned and explicitly stepped by the playground.

## Decision and rationale

Choose the scene-independent clock. Keep elapsed game seconds authoritative and emit one interval per advance. The playground owns lifetime and tick order, and lighting derives its phase without writing time. Debug jumps go through the playground and are explicit clock operations.

## Consequences and trade-offs

New sandbox instances start independently. A future shared session can own and pass the clock explicitly. Consumers define how to handle the boundaries in a large jump. Persistence and offline progression require separate decisions.
