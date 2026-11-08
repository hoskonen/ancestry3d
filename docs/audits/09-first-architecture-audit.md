# 09 — First architecture and code-quality audit

## Scope and baseline

Reviewed the playable playground, movement lab, character visual and motor, camera rigs, standalone prototype, asset inspection scenes, project settings, test suite, development policies and accepted ADRs. The audit started on `main` at `a984b5e` with Tasks 07 and 08 unstaged, including the playground, shared lighting, camera experiment, Input Map additions and their tests and notes. Earlier commits cover the repository baseline, movement lab, cottage and character integration. The index was empty.

`.gitignore` keeps the Godot cache, local Codex config, overrides, build output and logs out of Git. No tracked files matched ignore rules. The character and cottage retain source/runtime boundaries and import metadata. Active dependencies are Godot 4.7.2, Godot MCP 0.1.2 and GUT 9.7.1. Blender 5.2.2 and Blender Lab MCP 1.0.3 are authoring tools. No terrain plugin or autoload is enabled.

Review and commit Tasks 07 and 08 separately from this audit when authorized. The audit fix touches their untracked environment wrapper. Separating those two revisions of the wrapper requires staging the pre-audit content explicitly or including the small lifecycle fix with the feature baseline. The audit report and new test can be reviewed separately. This audit made no Git history or index changes.

## Must resolve before the next feature

### A01 — Medium — Decide who owns time before implementing it

- **Evidence and impact.** [Settlement lighting](../../prototypes/camera_experiment/settlement_lighting.gd) owns the binary `is_night` flag and directly assigns the environment, directional light, campfire and torch settings. The [standalone controller](../../prototypes/camera_experiment/camera_controller.gd) and [playground HUD](../../dev/playground/playground_debug.gd) both write the flag through `set_night()`. This works for a visual comparison. Letting simulation systems read or change that presentation flag would make prototype input and scene load order affect authoritative state.
- **Correction and timing.** Before Task 10 implementation, review who owns and advances the clock, its units and wrap behavior, whether paused or scaled time affects it, and the contract for a debug override. Keep dependencies one-way. The authoritative state drives the lighting adapter, which continues to apply visual settings. Decide whether N requests a sandbox clock adjustment or remains an explicitly visual comparison. Keep the standalone prototype independently usable. No clock design is accepted by this audit.
- **Regression risk and verification.** Switching ownership can change startup lighting, restore the wrong visual preset after a reset, or accidentally advance time on a view toggle. Test deterministic time boundaries and pause behavior once the contract is approved. Preserve existing day/night and campfire regression checks and test both entry scenes.

## Worth resolving soon

### A02 — Medium — Playground environment setup was unsafe on tree re-entry

- **Evidence and impact.** [Environment wrapper](../../dev/playground/playground_environment.gd) strips the prototype controller and frees its camera and overlay in `_enter_tree()`. Removing and re-adding the same environment reproduced both “Node not found: Camera” and a null `free()` call. Initial startup worked, so the existing suite missed this case. Reattaching the settlement could interrupt its lifecycle with an error.
- **Correction and timing.** Fixed in Task 09. Removal of the two preview-only nodes now checks whether they still exist. Authored world and lighting paths remain explicit.
- **Regression risk and verification.** Verify that preview camera/input are still absent after initial entry and re-entry, the actual gameplay camera remains current and the environment instance keeps its lighting selection. A focused GUT test exercises this lifecycle.

### A03 — Medium — Live MCP works, but standalone process discovery is incomplete

- **Evidence and impact.** Godot status found the connected editor but returned no standalone executable. Process mode returned `GODOT_NOT_FOUND`, and no process output was available. Direct Godot console startup and GUT worked. The ignored Codex config registers the Godot package and a local Blender server command. Live Blender MCP successfully inspected the Cottage Study. Prior Blender background helper failure is documented in Task 06A and was not rerun here.
- **Correction and timing.** Set Godot's executable location in the local server environment, restart Codex, and run a bounded MCP process smoke test followed by log retrieval. Record portable Blender prerequisites and confirm its background helper if future asset verification depends on it. Keep local paths and credentials out of tracked examples. Address before relying on MCP process profiling or breakpoints.
- **Regression risk and verification.** A bad executable or project path could target the wrong version or disconnect the live bridge. Verify both live editor status and process startup against this checkout. Machine-local config was left intact.

### A04 — Medium — Preserve a reviewable feature baseline

- **Evidence and impact.** The Task 07 and 08 feature work is still partly untracked. A plain `git diff` omits those files. Reviewing or bisecting later clock behavior against the current HEAD would omit the playground and its tests.
- **Correction and timing.** Review the complete staged file list and record a feature baseline before beginning clock implementation. Preserve local files and resolve review scope with the user before committing.
- **Regression risk and verification.** A broad stage can capture generated files or merge audit changes with unrelated work. Use `git status --short --ignored` and review the index, including Godot sidecars and the untracked source files.

### A05 — Medium — Character asset redistribution status is unverified

- **Evidence and impact.** The [character asset notes](../development/06b-character-animation.md) record a user-supplied GLB, two original exports and no asset-specific license evidence. Imported clips and textures share that provenance gap. The active GLB is used by the player and is already in the local feature history.
- **Correction and timing.** Record the actual Meshy export and animation usage terms before public distribution or external sharing. Preserve the source hashes and import settings. This is a distribution review item, independent of the local world-clock experiment.
- **Regression risk and verification.** Replacing the asset or moving it out of an export can break the visual's preload or named clips. Re-run character inspection and walk/idle tests for any substitute.

## Safe to defer

| Severity and system | Evidence and impact | Correction, risk and timing |
| --- | --- | --- |
| Medium — Settlement composition and collision | [Wrapper](../../dev/playground/playground_environment.gd) and lighting use authored node paths. The playground instances the whole visual prototype and strips preview nodes at runtime. Its collision proxies are maintained separately. Visual edits can drift from collision or break path lookups. | Keep current composition until a second playable environment or meaningful terrain edit requires a dedicated environment scene. If extracting, preserve light references, visibility markers and both entry points. Re-run the passage and wall tests after geometry changes. |
| Low — Overlay and hot-path formatting | [Playground HUD](../../dev/playground/playground_debug.gd) reads an imported AnimationPlayer path and builds its text every visible frame. It also routes a handful of development commands. The lab has a separate, similarly sized readout. | Add clock display as a small read-only section that consumes an explicit clock reference. If diagnostics grow, group rows by owner and update slow-changing values at a lower rate. Verify hidden HUD and controller shortcuts. Profile before changing update frequency or consolidating the two overlays. |
| Low — Camera timing and lifecycle assumptions | [Third-person rig](../../dev/playground/third_person_rig.gd) expects a bound target and follows in the playground physics tick. [Isometric rig](../../game/camera/orthographic_follow.gd) eases in render processing. SpringArm tests gameplay collision proxies rather than roof and foliage silhouettes. | Keep the approaches mode-specific. Test near-wall transitions and controller feel on hardware before changing update order or adding obstruction behavior. If actors can be replaced at runtime later, test rebinding and exclusion cleanup with that feature. |
| Low — Tests depend on fixture geometry and frame rate | [Integration suites](../../tests/integration/test_playground.gd) drive the real motor at 1/60 s and assert against known wall and passage positions. Camera and animation tests allow render/physics frames to advance. Some tests inspect authored paths and clip names. | Keep geometry contracts where traversal is the subject. Centralize the test step against engine tick rate if that rate becomes configurable. Add input event and airborne/landing coverage only when a regression or changed behavior warrants it. Validate the GUT summary as well as exit code. |
| Low — Reusable visual has a concrete art contract | [Wanderer visual](../../game/characters/weary_wanderer_visual.gd) preloads one GLB, requires three named clips and reads its parent motor. The HUD reaches into the imported hierarchy. This is a deliberate one-character adapter. | If another rig or HUD needs the same data, expose a small visual readout instead of assuming imported node names. Test placeholder selection and clip fallback when swapping rigs. Leave the current clip thresholds and in-place playback intact. |

## No action required

- **Motor and intent ownership.** [Input](../../game/input/player_movement_input.gd) handles device actions and camera heading. [Motor](../../game/characters/character_motor.gd) owns velocity, facing and physics. Animation reads resolved speed and the rigs read the follow marker. This matches the accepted intent and CharacterBody3D ADRs. Preserve these boundaries when adding simulation.
- **Scene-local wiring.** The playground root chooses the active heading and calls the motor once per physics tick. The standalone prototype and movement lab remain useful independent entry points. Small repeated wiring between test scenes is cheaper to review than a shared controller at the current scale.
- **Performance.** No optimization is justified by the current static samples. Rendering cost should be evaluated on traversal and target hardware before tuning fog, lights, foliage or shadow settings.

## Performance baseline

AMD Ryzen 7 5800X and AMD Radeon RX 7900 XTX, Windows, Godot 4.7.2, Forward+ with D3D12, VSync enabled and 60 Hz physics. Both samples were at the daylight spawn `(0, 0, 2.2)` with the character grounded and `Idle_02` playing. The game reported a logical viewport of 1152 × 898 and a capture size of 1836 × 1432. Waited 0.7 s after reset or mode change, then sampled 1.25 s with the same HUD state.

| View | Frames / avg FPS | Frame avg / p95 / max ms | Physics avg / max ms | Draw calls | Rendered objects / primitives |
| --- | ---: | ---: | ---: | ---: | ---: |
| Isometric, 9.5 m, 45° / 35.264° | 76 / 60 | 16.67 / 17.12 / 17.63 | 0.458 / 0.698 | 203 | 418 / 26,888 |
| Third person, 4.6 m, 45° / 16° | 75 / 60 | 16.68 / 17.04 / 17.13 | 0.406 / 0.422 | 215 | 435 / 37,758 |

A scene inventory found 199 mesh nodes, 172 visible in the tree with 172 surfaces and 172 distinct active material resource instances. Those counts are before frustum culling. The renderer totals can include shadow passes. Physics has one static body with 31 shapes and the player capsule, with the SpringArm active in third person. One AnimationPlayer was active. Its per-player CPU/GPU cost was not isolated. The FPS cap and short sampling window cannot distinguish GPU headroom or sustained traversal spikes. Task 08's matched night samples give additional workload context. [Camera performance notes](../prototypes/08-third-person-camera.md)

## Verification and remaining gaps

Baseline GUT 9.7.1 ran 21 tests and 95 assertions with zero failures using the Godot console executable and the existing [test command](../development/testing-strategy.md). Tests already cover input translation, braking, wall sliding, slopes, ledge landing, animation speed/idle, camera follow and boom retraction, and day/night movement invariance. No coverage percentage is imposed. Physical controller feel, isolated animation cost, uncapped GPU timings and a clean export on another machine remain unverified.

After the lifecycle fix, GUT passed **22 tests and 101 assertions**, including the [re-entry regression](../../tests/integration/test_playground_environment_lifecycle.gd). Godot deep validation with addons reported zero errors and warnings. Direct headless startup passed for the playground, movement lab, visual prototype and both asset inspection scenes. MCP editor play verified both gameplay camera modes, injected left-stick movement with walking animation, night fire energy and shadows, and all three standalone camera presets with the night toggle. Editor runtime logs were clean. MCP process mode and Blender background helper remain open as noted in A03.
