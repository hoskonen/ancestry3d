# 0001 — World-space movement intent

Status — Accepted
Date — 2026-11-08
Related — [Task 04 investigation](../architecture/04-game-foundation-investigation.md)

## Context and alternatives

Keyboard and controller should share movement behavior. The alternatives were polling devices inside the motor, sending screen-space input to the motor, or converting input before it reaches the motor.

## Decision and consequences

A scene-local input adapter converts device actions and camera heading into bounded world-space planar intent. The motor owns movement and collision. Tests and future steering can supply the same intent. The scene must wire the adapter explicitly and define how it supplies zero intent when disabled.
