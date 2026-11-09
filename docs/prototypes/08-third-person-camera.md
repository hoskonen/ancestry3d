# 08 — Third-person camera experiment

Open [playground.tscn](../../dev/playground/playground.tscn) and press F6. The scene starts in the original close isometric view.

| Input | Action |
| --- | --- |
| C / R3 | Switch isometric and third person |
| Right stick / hold right mouse and drag | Orbit in third person |
| WASD / left stick | Move relative to the active camera heading |
| Mouse wheel | Zoom the current view |
| V / top face button | Switch close and wide in isometric |
| R / Back | Reset player and both camera settings, keeping the active mode and lighting |
| N / H | Toggle lighting / HUD |

The new [rig](../../dev/playground/third_person_rig.gd) is a playground sibling of the unchanged isometric rig. It uses a perspective camera directly below a `SpringArm3D`. The boom tests world layer 1 and excludes the player capsule. Both rigs use the existing follow marker. The playground selects the heading before sampling movement intent, so the motor, collider, and animation remain independent of the camera mode. [Godot spring arm guide](https://docs.godotengine.org/en/4.7/tutorials/3d/spring_arm.html)

The Inspector exposes the initial 4.0 m distance, 16° elevation, 45° yaw, 0.65 m height offset, 130°/s full-stick sensitivity and 0.18°/pixel mouse sensitivity. The camera uses a 65° field of view. Orbit elevation is limited to −15° through 65°, the stick uses a 0.22 deadzone, and wheel distance is limited to 2–8 m. The HUD displays requested and unobstructed arm lengths as well as yaw and elevation.

Switching is immediate and retains the settings for each view until reset. Near walls, the arm retracts and may bring the camera close to the player. The world collision proxies leave eaves and canopies outside the cast, so visual overlap remains possible. The mouse remains uncaptured, which limits a drag at the viewport edge.

## Verification

GUT passed 21 tests and 95 assertions. The new tests cover the default camera, a switch with nonzero velocity, the new camera-relative direction through the actual input adapter, return to isometric, boom retraction behind the hall, zoom bounds and reset. MCP editor play covered C while idle, R3 while moving, injected right-stick orbit, right-mouse dragging and reset. The final runtime log reported zero errors or warnings. A physical controller pass remains open.

For manual evaluation, orbit behind the hall and pass between the storehouse and ruin. Compare the pop-in at the wall, visibility near eaves and the direction of travel when switching while holding movement. Check a long mouse drag and a physical right stick.

## Performance baseline

Godot 4.7.2 on Windows, Forward+ with D3D12, VSync enabled and physics at 60 Hz. MCP reports 1152 × 898 logical game pixels and a 1836 × 1432 capture. Both views were stationary, grounded and playing the same idle loop at each site. Reset to the default angles and distances, settle for at least 0.6 s, then sample 1.25 s. The daytime sample used spawn `(0, 0, 2.2)`. The night sample used `(-3.8, 0, 10.75)` near the campfire. Compare the two views within each site. Lighting and location both differ between sites.

| Site | View | Average / p95 / max frame ms | Draw calls | Rendered objects / primitives |
| --- | --- | ---: | ---: | ---: |
| Day spawn | Isometric, 9.5 m | 16.67 / 17.19 / 17.53 | 203 | 418 / 26,888 |
| Day spawn | Third person, 4.6 m | 16.67 / 17.19 / 17.24 | 215 | 435 / 37,758 |
| Night campsite | Isometric, 9.5 m | 16.67 / 17.00 / 17.34 | 263 | 483 / 71,084 |
| Night campsite | Third person, 4.6 m | 16.67 / 17.08 / 17.17 | 391 | 616 / 84,654 |

Each sample contains 75–76 frames. Max is the largest observed frame in that short window. The counters are renderer totals and may include shadow passes, so they cannot be read as unique visible scene meshes. VSync capped these samples near 60 fps. They show a larger render workload in the perspective view, especially at the night campsite, while GPU headroom and traversal spikes remain unmeasured.

The scene already uses primitive collision proxies, automatic frustum culling, imported mesh LOD and shadow meshes on the Wanderer, and only one shadowed positional light at night. Fog is non-volumetric. For larger scenes, profile shadow cost, foliage batching, visibility ranges and occlusion culling on the target hardware before changing settings. [Godot rendering architecture](https://docs.godotengine.org/en/4.7/engine_details/architecture/internal_rendering_architecture.html) · [Godot visibility ranges](https://docs.godotengine.org/en/stable/tutorials/3d/visibility_ranges.html)
