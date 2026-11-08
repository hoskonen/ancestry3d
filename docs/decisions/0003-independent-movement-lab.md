# 0003 — Independent movement laboratory

Status — Accepted
Date — 2026-11-08
Related — [Task 04 investigation](../architecture/04-game-foundation-investigation.md)

## Context and alternatives

The visual prototype has a working camera and lighting comparison but no collision course. Building movement inside it would couple the first motor tests to the settlement's geometry and controls.

## Decision and consequences

Keep the prototype available and build a separately launchable movement laboratory with deliberate collision fixtures. The lab can compose the reusable player and follow rig. Its initial orthographic camera is an experiment and can be tuned independently.
