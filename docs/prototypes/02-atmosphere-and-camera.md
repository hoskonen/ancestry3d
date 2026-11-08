# 02 — Atmosphere and camera

Press F5 to open the extended camera experiment. The [Task 01 notes](01-camera-experiment.md) describe the original baseline. This page records the current settings.

## Camera settings

Select the `CameraExperiment` root in the Inspector. **Preset Angles** exposes each preset's elevation below horizontal and yaw as the X and Y components of a vector. **Shared Framing** exposes the orthographic starting size, zoom limits and target offset.

| Key | Preset | Elevation | Yaw |
| --- | --- | ---: | ---: |
| 1 | Top-down | 86° | 0° |
| 2 | Angled orthographic | 48° | 10° |
| 3 | Isometric | 35.264° | 45° |

The shared reset size is 17 units, down from 24 in Task 01. Zoom spans 7–34 units. The default target offset is `(0, 0.25, 0)` relative to the courtyard reset point `(-0.5, 0, -1)`. All presets share the same camera, pan target and current zoom. The 32-unit camera distance stays fixed for consistent fog tuning while orthographic size changes.

Use **WASD** or the **arrow keys** to pan and the **mouse wheel** to zoom. **R** restores preset 2 and the configured starting framing.

## Settlement and lighting

- The wooded rise adds twelve varied low-poly pines, including two on the opposite side of the settlement, plus shallow banks, scattered stones, worn ground and small rush clusters.
- A broken stone annex beside the storehouse creates a passage roughly 1.5 units across. Three stationary markers supplement the central reference marker. Look behind the hall, at the edge of the western trees and beside the ruined wall.
- `Sun` uses a muted warm-white key at energy 0.78, rotation `(-39°, -34°, 0°)`, angular distance 1.15°, shadow blur 1.4 and a 58-unit shadow distance. Its Inspector settings allow direct lighting and shadow comparisons.
- The `WorldEnvironment` resource uses cool ambient light at energy 0.58 and gray-blue depth fog. Fog starts at 27 units from the camera and reaches its maximum density of 0.44 at 51 units, with a depth curve of 1.25. The cottage lantern is a short-range, unshadowed warm accent. [Godot environment reference](https://docs.godotengine.org/en/4.6/classes/class_environment.html) · [Godot lighting and shadows guide](https://github.com/godotengine/godot-docs/blob/master/tutorials/3d/lights_and_shadows.rst)

## Observations

| Setup | What the rendered checks showed |
| --- | --- |
| Hall rear | Top-down exposes the marker behind the hall. The angled view hides it behind the roof at the same target and zoom. |
| Wood edge | At a close framing, the angled view shows a hood and sliver of cloak beside a pine. Isometric can hide the marker behind the canopy entirely. |
| Passage | Isometric shows the gap and the marker above the broken wall. At tighter framing the wall and storehouse interrupt the view of the ground route. |
| Fog and shadows | Turning fog off in the running scene removed the lift on the distant trees and ground. Turning shadows off made the well, trees and ruined wall easier to separate at a glance but weakened contact and depth cues. The lantern remained a local point of contrast. |

At size 34 the settlement reads as an overview, with the markers too small for fine detail. At size 7 the camera makes details legible but framing and pan matter much more. Camera-relative depth fog is weakest as a distance cue in the near-vertical view.

## Verification and performance

Godot 4.7.2 deep validation and MCP editor runtime logs reported zero errors and warnings. MCP input checks verified all three presets, screen-relative pan, zoom clamps and reset. The courtyard instance stayed the same through preset changes. Screenshots covered default framing, close occlusion views, wide framing, and live fog and shadow comparisons under Forward+. A direct headless startup also exited successfully. MCP process mode could not discover the installed executable in its environment.

The scene uses primitive meshes, one shadowed directional light, one unshadowed local light and depth fog. Volumetric fog and post-processing are disabled. A single editor runtime snapshot showed about 10,700 rendered primitives and 327 draw calls. It is a reference for this setup. GPU cost and performance on target hardware remain unmeasured.

## Manual evaluation

1. Reset, pan to the rear of the hall, and cycle **1–3** without changing zoom. Which view makes it easiest to infer where the hidden marker is?
2. Pan to the woods and zoom in a few notches. Switch between **2** and **3**. How much of a character silhouette needs to remain visible before the canopy feels obstructive?
3. Compare the storehouse passage at the default zoom and near the close limit. Does the route still read as open when the marker is partly behind the wall?
4. Toggle Sun shadows or reduce fog in the Inspector and replay the same route with the camera. Does the gained contrast improve readability enough to trade away depth?

All visibility changes come from static geometry and lighting. The markers remain stationary, and the experiment has no camera collision or occluder fading.
