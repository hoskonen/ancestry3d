# 10B — World clock and lighting

Open [playground.tscn](../../dev/playground/playground.tscn) and press F6. The HUD shows the zero-based day, 24-hour time, rate and pause state. The playground starts at day 0, 09:00 with a rate of 60 game seconds per engine second. Set **Initial Clock Rate** on the playground root to change the starting rate.

| Control | Playground behavior |
| --- | --- |
| N | Jump from daylight to 21:00, or from night to the next 09:00. Works while clock-paused. |
| P | Pause or resume automatic world time. Movement, camera and animation continue. |
| R / Back | Reset player and camera without resetting time. |
| H | Toggle the HUD. The clock keeps running when hidden. |

F5 still opens the standalone visual prototype. Its N shortcut still switches lighting directly.

## Ownership and contract

[WorldClock](../../game/world_time/world_clock.gd) is a scene-independent `RefCounted` with no automatic processing. One playground instance owns it and steps it before movement or fall recovery on each physics tick. The same playground retains its clock and one lighting listener across tree re-entry. A fresh playground starts an independent clock. A paused SceneTree or a detached playground supplies no automatic steps, and there is no catch-up for time spent outside the tree.

| API | Behavior |
| --- | --- |
| `elapsed_seconds()`, `day_index()`, `seconds_of_day()` | Read the monotonic elapsed value and its derived day and local time. |
| `rate()`, `is_paused()` | Read the rate and clock-specific pause state. |
| `set_rate(value)`, `set_paused(value)` | Set rate or pause. Rate accepts 0.01–3600 game seconds per engine second. |
| `step(delta)` | Advance by logical physics delta times rate while unpaused. |
| `advance_seconds(seconds)` | Advance explicitly by an unscaled, nonnegative number of game seconds, even while clock-paused. |
| `advanced(previous_seconds, current_seconds)` | Emitted synchronously after each positive change, once for the whole interval. |

Elapsed time is a 64-bit float capped at 2⁴⁰ game seconds. Each day lasts 86,400 seconds. Invalid values, overflow, advances lost to rounding and mutations during notification return false without changing state. Accepted zero updates emit no signal. An interval covers `(previous, current]`. Consumers can derive every hour or midnight crossed from the endpoints. The clock does not replay intermediate ticks, and the playground does not change `Engine.time_scale`.

## Lighting

The playground uses the interval endpoint to select day from 06:00 inclusive to 18:00 exclusive and night otherwise. It applies the existing preset only when the phase changes. Fog, fire, torch and shadows remain owned by the existing lighting scene. A large jump applies its final phase without replaying intervening lighting changes.

## Verification

GUT 9.7.1 on Godot 4.7.2 passed **35 tests and 222 assertions**. Seven clock unit tests and six playground integration tests cover the approved contract, including invalid inputs, notification re-entry, exact dawn and dusk, midnight and multi-day jumps, scene lifecycle, and player reset and camera invariance. Run the suite with the [existing headless command](testing-strategy.md).

Deep project validation reported zero errors and warnings. Direct headless startup passed for the playground, movement lab and standalone prototype. MCP editor play verified automatic advancement, both jump destinations, paused movement and jumps, resume, camera switching and the standalone prototype's original camera presets and N toggle. MCP process mode could not find the Godot executable. The installed console executable supplied headless verification.

Time currently belongs to the playground session. Save/load, shared time across scenes, offline progression and time-driven gameplay are future work. The first consumer should use the elapsed interval and define its own policy for skipped boundaries. [Approved design](../architecture/10-world-time-design.md) · [ADR 0004](../decisions/0004-world-clock-ownership.md)
