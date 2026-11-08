# 03 — Nighttime lighting and camera distance

Press F5. The settlement opens in the [Task 02](02-atmosphere-and-camera.md) daytime setup. A campsite beside the southwest boundary wall adds two canvas shelters, a stone-ring fire, three seating logs, supplies, pines and four stationary markers.

## Controls and camera

| Control | Action |
| --- | --- |
| 1 / 2 / 3 | Select top-down, angled or isometric while retaining the current target and zoom |
| 4 | Select isometric and ease between wide and close framing |
| N | Toggle day and night with the current view intact |
| F | Center the existing view on the campsite |
| WASD or arrows / mouse wheel | Pan / zoom |
| R | Reset the view to the courtyard and angled preset, keeping the lighting scenario |

Wide and close isometric use sizes **17** and **9.5** at the same 35.264° elevation, 45° yaw and target. The 0.35-second size blend retains orientation when already in isometric view. Mouse-wheel zoom interrupts the blend and is bounded to 7–34. The root Inspector exposes the close size alongside the existing preset angles and framing.

## Lighting settings

| Source | Day | Night |
| --- | --- | --- |
| Environment | Task 02 ambient energy 0.58 and depth fog density 0.44 | Cool ambient energy 0.17, blue-gray depth fog density 0.26 over 28–50 units |
| Directional light | Warm-white Sun, energy 0.78 | Cool moonlight, energy 0.15, using the same direction and shadow settings |
| Campfire | Warm point light at energy 0.58, shadows disabled | Energy 3.0, radius 6.4, attenuation 1.65, cubemap shadows enabled |
| Settlement accents | Existing cottage lantern, energy 0.66 | Cottage lantern and storehouse torch, energy 1.25 and range 3.15, both unshadowed |

The night Environment is stored in `night_environment.tres`. The root controller switches the resource and the small set of light settings explicitly. Flame meshes use steady emissive materials. The actual firelight comes from the OmniLight3D. The short-range doorway lights form distinct pools separated from the campsite by dim routes.

## Matched comparison

The four MCP captures use the same campsite target and 1836 × 1807 render dimensions. The only changes between captures are the lighting scenario and orthographic size.

| | Wide | Close |
| --- | --- | --- |
| Day | The boundary, well and route orient the viewer. The pine hides a fourth marker even in daylight. | The fire-side marker and supplies are clearer. The tent masks the lower body of the marker behind it, and the left-edge marker is close to the frame boundary. |
| Night | The fire defines a gathering point. Trees and the wall still read as silhouettes, while the route loses contrast away from the pool. | The fire-side marker, canvas and logs read clearly where lit. The foreground tent and pine still block geometry. The edge marker is dim and harder to separate from the trees. |

Disabling fire shadows made the pool more even and let light spill past the stones and props. A live trial with radius 8 and attenuation 1.1 pushed warm light farther into the trees. The saved 6.4 / 1.65 settings preserve a clearer boundary around the camp.

## Verification and rendering

Godot 4.7.2 deep validation and MCP editor runtime logs reported zero errors and warnings. MCP input checks covered all presets, day/night restoration, framing transitions, pan, both zoom clamps and reset. Screenshots verified the fire shadows, separate local pools and the four comparison views under Forward+. Direct console headless startup passed. MCP process mode could not locate the installed executable in its environment.

Only the night campfire uses positional shadows. The existing positional shadow atlas settings were retained, and volumetric fog and bloom are disabled. The cubemap shadow adds hard contact cues at the hearth. Fine shadow edges can look coarse at close zoom. In a static, vsynced night-close sample, fire shadows on and off both averaged about 16.67 ms per frame with 191 reported draw calls. That sample leaves GPU cost, shadow-update spikes and target hardware performance unmeasured. [Godot 4.7 OmniLight3D reference](https://docs.godotengine.org/en/4.7/classes/class_omnilight3d.html) · [Godot shadow atlas guide](https://docs.godotengine.org/en/latest/tutorials/3d/lights_and_shadows.html)

## Manual evaluation

1. Press **R**, **F**, then **3** to start at wide campsite framing. Press **4** and **N** to compare all four combinations without panning.
2. Find the fire-side marker, the marker behind the eastern tent, the one at the edge of the firelight and the one behind the foreground pine. Switch to day to isolate low illumination, zoom out to isolate cropping, then switch to top-down to expose geometric occlusion.
3. Return to the courtyard at night and pan from the fire toward the storehouse torch and cottage lantern. Check whether the pools are visible soon enough to navigate the dim stretches between them.
4. Repeat on a wider viewport and a dimmer display. Consider whether the extra detail at size 9.5 is worth losing the well and route context, and whether the fire-shadow quality holds up at that framing.

The scene uses fixed markers and static lights. The focus shortcut frames a fixed point. It offers no automatic following or occluder fading.
