# 0002 — CharacterBody3D locomotion

Status — Accepted
Date — 2026-11-08
Related — [Task 04 investigation](../architecture/04-game-foundation-investigation.md)

## Context and alternatives

The first character needs authored acceleration and braking with physical contacts. Transform-driven motion would require custom contact handling. Rigid-body motion would put responsiveness and turning under a different control model.

## Decision and consequences

Use a grounded `CharacterBody3D` and capsule with `move_and_slide()`. The motor owns locomotion and exposes resolved movement for presentation. The visual child is replaceable. Slope, wall and ledge behavior must be verified against the project's physics engine.
