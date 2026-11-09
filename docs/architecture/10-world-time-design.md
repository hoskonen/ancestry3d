# 10 — World time design

**Status — Approved for Task 10B.** This document defines the initial contract. See [ADR 0004](../decisions/0004-world-clock-ownership.md).

## 1. Existing implementation

[Audit A01](../audits/09-first-architecture-audit.md) identified the ownership gap. [Settlement lighting](../../prototypes/camera_experiment/settlement_lighting.gd) holds a binary `is_night` presentation flag and applies the environment, sun, fire and torch settings. The [standalone camera controller](../../prototypes/camera_experiment/camera_controller.gd) and [playground HUD](../../dev/playground/playground_debug.gd) both toggle it directly with N. There is no authoritative time yet.

The [playground](../../dev/playground/playground.gd) already owns scene composition and a physics tick for movement. Its environment wrapper strips preview input and cameras on entry, and the audit fixed repeated entry of that wrapper. Reset currently restores the player and camera while preserving lighting. Keep those scene roles and reset semantics.

## 2. Ownership and update order

Use a scene-independent GDScript `RefCounted` named `WorldClock`. It owns elapsed game seconds, rate and clock pause, and has no automatic processing. The playground owns its instance and calls `step(delta)` once at the start of its existing `_physics_process()`, before any early return for a fall reset. The input and movement path remains as it is. Other callers can advance a clock instance in tests without creating a scene.

Lighting receives time-derived presentation requests from the playground. The HUD reads clock state through the playground and sends debug commands back to it. Neither the lighting adapter nor the HUD advances the clock automatically. Future systems should receive a clock reference or an elapsed interval explicitly.

Use the physics callback's logical delta. The playground inherits ordinary scene-tree pause, so a paused tree supplies no ticks. World-clock pause suppresses only automatic clock advancement. Do not change `Engine.time_scale` for this feature. If another system later changes it, the supplied physics delta will already reflect that change. No wall-clock catch-up occurs after a pause, debugger break, unload or missed frame. Godot `Time` system dates and tick counters stay outside the simulation contract. [Godot Node processing](https://docs.godotengine.org/en/4.7/classes/class_node.html#class-node-private-method-physics-process) · [Engine time scale](https://docs.godotengine.org/en/4.7/classes/class_engine.html#class-engine-property-time-scale) · [Godot Time](https://docs.godotengine.org/en/4.7/classes/class_time.html)

## 3. Public clock contract

| Member | Proposed behavior |
| --- | --- |
| `elapsed_seconds() -> float` | Authoritative elapsed game seconds since day 0 at 00:00. |
| `day_index() -> int` | Zero-based day index. |
| `seconds_of_day() -> float` | Seconds since the most recent midnight, in `[0, 86400)`. The HUD derives hours and minutes by flooring to whole units. |
| `rate() -> float`, `is_paused() -> bool` | Read the active rate and pause state. A fresh clock starts at elapsed 0, rate 1 and unpaused. |
| `set_rate(game_seconds_per_engine_second: float) -> bool` | Accept finite rates in `[0.01, 3600]`, inclusive. Applies to the next automatic step. |
| `set_paused(paused: bool) -> bool` | Controls automatic advancement. Resume takes effect on the next step and adds no time by itself. |
| `step(engine_delta_seconds: float) -> bool` | Validate the delta, then advance by delta × rate if unpaused. Zero delta or a valid delta while paused is an accepted no-op. |
| `advance_seconds(game_seconds: float) -> bool` | Add an explicit nonnegative duration even while clock-paused. Rate has no effect. Zero is an accepted no-op. |
| `advanced(previous_seconds: float, current_seconds: float)` | One synchronous signal per successful positive change, emitted after the new value is stored. No signal for initialization, no-ops, rejected calls, rate changes or pause changes. |

Commands return true for accepted calls, including no-ops. They return false without partial mutation for negative or nonfinite inputs, out-of-range rates, nonfinite sums, elapsed values above the supported maximum, or positive updates that round to the same elapsed value. Reject all mutations attempted from inside an `advanced` callback. Listeners may read the new state synchronously and may request a later command through the owner. There is no queued re-entrant mutation or implicit logging from the clock. The caller decides how to surface a rejected command.

## 4. Representation, boundaries and lifecycle

- Store a single nonnegative 64-bit GDScript float. An hour is 3,600 seconds and a day is 86,400. Use floor division for the day index and derive the remainder from the same value. Midnight advances the day index and resets seconds of day to zero. Elapsed time stays monotonic. A read or a HUD format must never round the authoritative value.
- Cap elapsed time at exactly `2^40` seconds to keep useful subsecond precision over the supported range. Never silently wrap, saturate, rewind or snap across a boundary. Use ordinary float arithmetic with tolerance for fractional-step tests. Use exact integral values to test exact hour and day boundaries.
- Each notification describes **`(previous_seconds, current_seconds]`**. For a periodic boundary of length P, indices crossed are `floor(previous / P) + 1` through `floor(current / P)`, inclusive. An empty range means none crossed. A boundary exactly at the endpoint is included once and one exactly at the start is excluded.
- A jump emits one interval regardless of length. For example, day 0 23:30 → day 2 01:00 crosses 26 hour boundaries and two midnights. The clock does not replay intermediate ticks or emit an hour-changed signal per boundary. Consumers choose whether to aggregate elapsed time, evaluate the endpoint, or enumerate the specific boundaries they need. Future consumers must define their own catch-up cost and idempotence policy.
- A fresh playground instance starts on day 0 at 09:00, unpaused, with rate 60. Seed elapsed time before attaching listeners, then synchronize lighting and the HUD from the current value. Bind once for the lifetime of that instance. Re-entering the same instance keeps its clock, rate, pause and one signal connection. Detached playgrounds get no automatic ticks. Its retained environment uses the same presentation state on re-entry. If the owner explicitly advances the clock while detached, apply that endpoint to the retained lighting instance as well. Loading a new playground instance starts a new session. Player reset and fall recovery preserve the clock and rate.

## 5. Lighting and debug controls

For Task 10B, derive daytime from **`06:00 ≤ local time < 18:00`**. Use the existing daytime settings in that window and existing nighttime settings otherwise. On initialization, synchronize once. On an interval, evaluate its **endpoint** and apply the existing preset only when the desired phase differs from the current presentation state. A jump that crosses dawn and dusk and ends in the same phase leaves the preset alone. There is no transient flash or replay of skipped sunsets.

Use immediate changes initially so fog, lanterns, shadows and directional light retain their tested settings. A later visual experiment could blend sun intensity and color around dawn and dusk using time of day as input. It should isolate any mutable Environment resources per scene instance and keep discrete torch/shadow thresholds explicit. Interpolation, astronomical motion and weather are outside 10B.

In the playground, **N** advances authoritative time to the opposite phase's representative hour. From daytime, advance to 21:00 that day. From nighttime, advance to the earliest 09:00 strictly later than the current timestamp. Thus 02:00 → same-day 09:00 and 21:00 → next-day 09:00. N uses manual advance, so it works during clock pause without changing rate or pause. It respects the clock's maximum and reports a rejected jump in diagnostics. **P** toggles clock pause only. Add a compact HUD readout for zero-based day, `HH:MM`, rate and pause state. Keep the initial rate a playground configuration value. Additional shortcuts and controller bindings are deferred.

The standalone prototype's N remains a visual comparison and has no clock. There is no independent visual override in the playground in 10B. If one is added later, label it explicitly, leave elapsed time untouched and resynchronize to the current phase when it clears. Hiding diagnostics does not suspend time. Keep the existing movement, camera and reset controls.

## 6. Acceptance tests

Use GUT unit tests without scenes for clock rules. Use a small number of integration tests with a real playground instance. Freeze automatic physics processing for exact jump assertions and allow bounded physics frames for automatic ticking tests. See the [testing strategy](../development/testing-strategy.md).

| Case | Required result |
| --- | --- |
| Advancement and rate | At rate 60, a 0.5 s step adds 30 game seconds. Change the rate to 120, step 0.5 s and add 60. Rate changes emit no interval. |
| Pause and resume | A valid automatic step while clock-paused adds zero. A manual 3,600 s jump succeeds unscaled and emits one interval while pause stays active. Resume adds no immediate time. Scene-tree pause stops owner ticks as well. |
| Invalid input and re-entry | Reject negatives, NaN, infinity, out-of-range rates, elapsed overflow, and nested mutation during notification. Preserve state. An accepted zero step or jump emits nothing. |
| Boundaries | 86,399 + 1 gives day 1 at 00:00 and exactly one new hour/day boundary. The following second does not cross midnight again. A jump from day 0 23:30 to day 2 01:00 emits one interval with 26 crossed hour boundaries and two midnights. A listener reads the committed endpoint. |
| Lighting | 06:00 selects day and 18:00 selects night. A multi-day jump uses only the endpoint, including an unchanged-phase jump. The existing fire, torch and fog settings match the selected preset. |
| Debug and lifecycle | Fresh playground starts day 0 at 09:00. Two N presses reach 21:00 and then day 1 at 09:00, even if clock-paused. R and falling preserve time. Detach and reattach the same scene and environment without a duplicate listener, lost phase or reseed. A fresh scene starts independently. |
| Regression | Full GUT suite passes. Headless and editor smoke checks cover both camera modes, movement and animations, reset, HUD hidden, and standalone N preserving its visual behavior. |

## 7. Trade-offs and future persistence

A scene-owned clock gives explicit lifetime and deterministic tests. It resets on a new playground instance. If multiple playable scenes later share a timeline, move ownership to the session composition root and pass the same instance to those scenes. A global service would require its own review. Scene timers or wall-clock timestamps would complicate pause, jumps and deterministic interval semantics.

Future persistence should store the authoritative elapsed value with a versioned unit and epoch. Review whether rate and pause are session settings or saved state. Derived day, HUD text and lighting should be reconstructed. Restore a validated snapshot before subscribing consumers. Loading is a separate operation from advancing an existing clock and must not replay simulated time or imply offline progress. No save schema is approved here.

## 8. Approval and Task 10B scope

Task 10B approved the ownership, logical tick and monotonic interval contract in [ADR 0004](../decisions/0004-world-clock-ownership.md) along with the initial rate, phase boundaries, jump hours and pause controls above.

Task 10B will add the clock and unit tests, wire one instance into the playground, synchronize the two existing lighting presets, and add the N/P commands and HUD readout. It will extend integration coverage and run the full existing suite. NPC schedules, growth, calendars, seasons, save/load, global services, visual overrides and lighting interpolation remain out of scope.
