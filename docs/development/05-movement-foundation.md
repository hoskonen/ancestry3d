# 05 — Movement foundation

Open `dev/movement_lab/movement_lab.tscn` in Godot and press **F6**. **F5** still opens the visual camera and lighting prototype.

## Controls

| Action | Keyboard and mouse | Controller |
| --- | --- | --- |
| `move_forward`, `move_backward`, `move_left`, `move_right` | Physical WASD | Left stick |
| `lab_reset` | R | Back / Select |
| `lab_framing` | V | Top face button, such as Xbox Y |
| Zoom | Mouse wheel | Use the framing button to switch between the two set sizes |
| Show or hide diagnostics | H | |

## Scene responsibilities

- `movement_lab.gd` wires the player, input adapter and follow target. It samples intent and steps the character once per physics tick. Reset restores the spawn, clears momentum and snaps the camera. The lab also respawns the player below world Y −8.
- `player_movement_input.gd` reads the four actions using a 0.20 circular deadzone. It retains analog magnitude, bounds diagonal length and rotates the input into world space using the rig's heading. Disabling the adapter supplies zero intent.
- `player.tscn` owns the capsule, replaceable `Visual` subtree, facing badge and follow marker. `character_motor.gd` accepts world-space intent through `step(intent, delta)`. It discards vertical input, caps XZ length at one, owns velocity and calls `move_and_slide()`. The motor exposes requested and resolved horizontal speed. A caller can supply intent without a camera, keyboard or controller.
- `orthographic_follow.gd` reads an assigned target and eases toward it. It owns its camera heading, framing and limits. It never moves the character.
- `movement_readout.gd` observes the input vector, requested and actual speed, grounded state, position and framing. H only changes the overlay's visibility.

The course contains flat ground, a solid wall, a 1.43-unit passage, a 20° ramp, a 60° slope and a 1.63-unit ledge with a landing on the ground below.

## Default tuning

| Setting | Value |
| --- | --- |
| Top speed | 4.2 units/s |
| Acceleration / braking | 18 / 24 units/s² |
| Gravity / maximum visual turn rate | 19 units/s² / 12 rad/s |
| Capsule radius / height | 0.34 / 1.70 units |
| Floor limit / snap | 45° / 0.25 units |
| Camera yaw / elevation | 45° / 35.264° |
| Wide / close / zoom bounds | 17 / 9.5 / 7–24 orthographic units |
| Follow response | 9 s⁻¹ exponential response |

The body remains upright. The visual turns toward requested travel and retains its facing on release. Actual speed reflects the physics result, including when a wall blocks movement.

## Verification

From the project root, run the following with the Godot 4.7.2 console executable. See the [testing strategy](testing-strategy.md) for runner setup and filtering.

~~~powershell
godot --headless --path . --import
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gexit
~~~

The suite covers runner discovery, cardinal and diagonal intent, analog magnitude, heading conversion, disabled and zero input, acceleration, braking and facing. Integration tests load the real lab under Jolt and exercise stopping, wall blocking and sliding, walkable and steep slopes, ledge departure and landing, and camera target, follow, framing, zoom bounds and reset.

On Godot 4.7.2, GUT 9.7.1 passed 13 tests and 38 assertions. Deep project validation, including both addons, reported zero errors and warnings. Editor play through Godot MCP exercised the keyboard, overlay toggle and an injected left-stick axis. A raw axis of 0.60 produced a movement magnitude of 0.50 and a requested speed of 2.10. Direct headless startup covered both scenes. Editor regression checks confirmed the prototype's three camera presets and both campfire lighting states. MCP process mode could not discover the Godot executable, so the console executable was called directly.

## Manual checklist

1. Try the left stick just inside and just outside the deadzone. Compare partial stick tilt with a full tilt. Release and reverse direction at speed, and check for drift and abrupt turning.
2. Drive diagonally into the wall, thread the passage and climb the green 20° ramp. The brown 60° slope should block ascent. Walk off the marked ledge and verify the airborne readout returns to grounded on landing.
3. Compare wide and close views while passing the wall. Verify camera tracking, wheel bounds and reset. Hide the overlay and repeat a movement check.
4. Open the visual prototype with F5 and check its three views, day/night toggle and campfire.

The slice uses a static primitive visual. Follow framing has no obstruction handling. Real controller hardware and its mappings still need a manual pass. The next useful extension is to tune stick response and follow feel on that hardware before evaluating a rigged visual or additional camera behavior.
