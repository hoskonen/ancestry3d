# 01 — Camera experiment

Open `res://prototypes/camera_experiment/camera_experiment.tscn` or press F5. It is the project's current main scene.

## Scene and camera

`CameraExperiment` owns a static `Courtyard`, a single orthographic `Camera`, lighting and a `CanvasLayer` HUD. The courtyard uses Godot primitive meshes and matte materials for the ground, track, three buildings, boundary wall, well, props and a stationary character marker.

`camera_controller.gd` controls the camera and HUD within the scene. All three presets share one ground target and orthographic size. Switching changes the view angles and label while retaining the target, zoom and courtyard instances.

| Key | Preset | Pitch below horizontal | Yaw |
| --- | --- | ---: | ---: |
| 1 | A · Top-down | 86° | 0° |
| 2 | B · Angled orthographic | 48° | 0° |
| 3 | C · Isometric | 35.264° | 45° |

Use **WASD** or the **arrow keys** to pan relative to the screen, the **mouse wheel** to zoom, and **R** to restore preset B, its initial target and its default zoom.

The controller constants define preset angles, the starting target `(-0.5, 0, -1)`, the 32-unit camera distance and the orthographic size range of 9–34 units, starting at 24. A wheel notch changes the size by a factor of 1.15. Pan speed scales with the orthographic size and the target is bounded to ±15 units on each ground axis.

## Verification

- Godot 4.7.2 MCP deep project validation, including addons, reported zero errors and warnings.
- MCP editor play verified startup, the active label and camera angles, pan and zoom in each preset, preservation of courtyard and marker instance IDs across switches, and reset. Runtime log inspection reported zero errors and warnings. MCP screenshots were inspected for all three presets at 1152 × 648.
- A direct Godot console headless launch ran the main scene. A temporary headless check exercised the presets, courtyard identity, zoom clamps and reset, and verified that the HUD and controls fit 1152 × 648, 640 × 480 and 480 × 720 subviewports.
- MCP process mode could not discover the Godot executable through its current environment. A shell-side editor import also encountered sandbox errors writing the user profile. Headless startup and deterministic checks used the installed console executable, while live visual and input checks used the existing editor bridge.

## Manual comparison

1. Start at the default zoom and cycle **1**, **2**, **3**. Compare the track, well, wall, roofs and marker from the same target.
2. Pan behind a building and zoom in. Switch presets without resetting. Compare what each view conceals and how easily you can orient yourself. Press **R** between passes for the same starting position.
3. Resize the game window to wide, narrow and portrait proportions. Check HUD legibility and how much of the courtyard stays in view. Rendered screenshots were checked at the default viewport, and alternate sizes were checked headlessly for layout.

For A, judge footprint and marker readability and whether the limited height cues would support grid movement or stacked spaces. For B, judge facade detail, route recognition and atmosphere during exploration. For C, judge tactical spacing and whether roofs or foreground walls would obscure a party.

The prototype uses a fixed marker and static geometry. It provides no movement rules, camera collision, occlusion handling or tracking. This scene supports a comparison of views before choosing a presentation approach.
