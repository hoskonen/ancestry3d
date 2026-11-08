# 07 — Playable settlement sandbox

Open [playground.tscn](../../dev/playground/playground.tscn) in Godot and press **F6**. **F5** continues to open the standalone camera and lighting prototype.

## Scene ownership

- The playground instances the existing settlement. Its environment wrapper removes the prototype camera, overlay and input script from the playground instance before they enter the tree. It hides the prototype's stationary comparison markers. The standalone scene keeps its controls and markers.
- The original `WorldEnvironment` now owns the day/night switch through `settlement_lighting.gd`. Both scenes use the same fog, ambient and directional settings, cottage lantern, storehouse torch and campfire. Day starts by default. Night enables the fire's positional shadows and the storehouse torch.
- The playground root wires the existing player, input adapter, spawn point and orthographic follow rig. The motor still owns physics and the Wanderer visual still selects idle, walk and run from resolved speed. The movement lab continues to use the same components.
- The playground overlay displays position, actual horizontal speed, floor state, current clip, day/night, orthographic size, yaw and elevation. Its controls call the scene's reset, camera and lighting methods. Hiding or removing the overlay leaves locomotion and following operational.

## Collision and camera

One static body holds 31 manually placed collision primitives on the existing world layer. A 96 × 96 m ground box matches the visual plane. Boxes cover the three buildings, the boundary wall and pier, the ruin walls, both tents and selected props. Cylinders cover tree trunks, the well, barrel and fire ring. The storehouse–ruin passage stays open. The motor does not use the decorative meshes for collision.

The camera starts at 45° yaw, 35.264° elevation and 9.5 m orthographic size. V compares 9.5 and 17 m. The wheel is bounded to 7–24 m. Follow responsiveness defaults to 9 s⁻¹ and the target is the player's existing `FollowTarget`. Reset clears velocity, restores the open spawn and snaps to close framing while keeping day or night selected. Falling below Y −8 also resets the player.

| Control | Action |
| --- | --- |
| WASD / left stick | Camera-relative movement |
| V / top face button | Switch close and wide |
| Mouse wheel | Zoom |
| N | Toggle day/night |
| R / Back | Reset to spawn |
| H | Toggle the HUD |

## Checks

The GUT suite passed 19 tests and 76 assertions. Five playground tests check composition, grounded spawn, hall and trunk blocking, passage traversal, close follow setup, respawn, animation at a wall and matched day/night displacement. The existing movement and animation tests remain in the suite. See the [testing strategy](testing-strategy.md) for the headless command.

Godot MCP editor play confirmed keyboard and injected stick movement, framing, zoom, HUD toggle and reset. Night rendered with the fire and local lighting enabled. The original scene still switched all three camera presets and its day/night setting. The MCP process launcher could not discover the Godot executable, so headless checks used the installed console executable directly.

## Manual exploration checklist

1. Walk toward the hall and storehouse, then follow the gap beside the ruined wall. Check idle against solid walls and walk/run on open ground.
2. Walk around the wooded edge and compare close and wide framing. Tree canopies and roofs can hide the protagonist even when the route is clear. The rig currently has no obstruction or roof-fade behavior.
3. Switch to night near the cottage and then walk to the campsite. Check whether the route and character silhouette remain legible between the local light pools.
4. Try a physical controller and tune the feel only after comparing both framings. Automated and injected-input checks do not establish hardware feel.

The wooded banks, low clutter and foliage are decorative. Feet may intersect the raised bank meshes because the support surface is flat. Building proxies seal the interiors and ignore roof overhangs. Debug collision shapes help review alignment after editing the settlement. If geometry changes, update the matching named shape and extend the traversal checks for any changed route.

Add future experiments as scene-local components or child scenes with clear inputs and state ownership. Wire them at the playground root and expose their diagnostics through the overlay as needed. Keep feature behavior in its owning scene or script.
