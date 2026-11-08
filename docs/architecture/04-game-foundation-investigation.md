# 04 — Game foundation and movement architecture investigation

**Status: proposal for review.** Start with one controller-first movement test scene, a capsule-shaped character and one following orthographic camera. Prove analog movement, turning, stopping, walls and slopes before adding animation, navigation or a second gameplay camera.

## 1. Existing project assessment

Godot MCP reports Godot 4.7.2 connected to the running camera experiment. The project uses Forward+ with D3D12 on Windows and Jolt Physics. The visual experiment is the main scene. The project has no custom Input Map actions, autoloads, test framework or gameplay scenes.

| Existing component | Evidence and recommendation |
| --- | --- |
| Courtyard scene | One scene contains the settlement, wooded rise, campsite, props, lights and fixed marker meshes. The saved scene has no physics bodies, collision shapes, navigation regions or animation nodes. Keep it runnable as a visual baseline. Reuse proportions, individual meshes and lighting references when useful. Build the first movement course independently so its surfaces, openings and slope angles are deliberate and measurable. |
| Camera and input | The root [camera controller](../../prototypes/camera_experiment/camera_controller.gd) polls WASD/arrows to pan and handles wheel and hard-coded shortcuts for framing, focus and lighting. It holds the current target, preset and zoom tween and writes directly to the camera. Reuse the tested angles and framing values as starting parameters for a separate follow rig. Isolate the free-pan controls and campsite focus in the sandbox. |
| Lighting | The scene owns the daytime Environment, Sun, fire, lantern and torch. The controller caches day settings and swaps in the [night Environment](../../prototypes/camera_experiment/night_environment.tres) while changing individual lights through fixed scene paths. Keep both looks as references. A future level should own its environment and lights, and any comparison controls should call into that scene locally. |
| Development overlay | A `CanvasLayer` contains a panel, a preset/day-night label and a controls label. The root script writes the readout directly. Reuse that modest layout when diagnostics become useful in the new scene. The original overlay remains the visual sandbox's controls. |
| Dependencies | The only enabled addon is the Godot MCP bridge. The scene loads one project script and that script preloads the night Environment. Preserve the addon, current renderer and physics settings. |

The main risk is extending the prototype root into a game coordinator. Its fixed paths couple camera, campsite, lighting and HUD, and its camera pan already occupies the keyboard keys proposed for movement. This is reasonable inside one visual sandbox. Composing a separate course avoids untangling those paths or adding colliders to the full settlement just to test movement. [Task 01 camera baseline](../prototypes/01-camera-experiment.md) · [Task 02 atmosphere and occlusion](../prototypes/02-atmosphere-and-camera.md) · [Task 03 night and framing comparison](../prototypes/03-nighttime-lighting.md)

## 2. Proposed organization

Create folders as their first files land. Scenes wire collaborators through explicit node references. Feature folders own their scenes, scripts and assets.

| Path | Role |
| --- | --- |
| `game/levels/` | Future playable areas and their composition roots. Add a game entry scene when there is a playable flow to launch. |
| `game/characters/` | The first character scene, its motor and replaceable visual child. Keep character-specific rigs, clips and tuning nearby when they exist. |
| `game/camera/` | The gameplay follow rig and its framing settings. Add other rigs only after a concrete comparison calls for them. |
| `game/input/` | Scene-local player input translation. Bind actions in Godot's Input Map. |
| `dev/movement_lab/` | Launchable movement course with a spawn point, flat ground, wall, passage, ramps and a ledge. Run it directly with F6 while the visual sandbox remains the main scene. |
| `dev/overlay/` | Optional development controls and readouts. Start with scene-local labels and extract a shared panel once two scenes need it. |
| `tests/unit/`, `tests/integration/`, `tests/fixtures/` | Tests grouped by feature. Keep automated fixtures smaller than the interactive course. |
| `prototypes/camera_experiment/` | Existing visual sandbox, independently runnable as a scene if the main scene later changes. |

Keep shared resources with their owner until multiple independent features consume them. Add future feature folders as concrete systems arrive. A second camera mode, AI or a shared resource library can wait for its first use case.

## 3. Movement architecture

~~~mermaid
flowchart LR
    A["Input Map actions"] --> B["Local player input"]
    C["Camera heading"] --> B
    B -->|"World-space planar intent"| D["CharacterBody3D motor"]
    D -->|"Resolved position"| E["Camera follow target"]
    D -->|"Actual velocity and floor state"| F["Character visuals"]
    D -.->|"Read-only values"| G["Development overlay"]
~~~

**Input.** Bind the left stick and physical WASD to four movement actions. Read them through `Input.get_vector()` in the local player input node, with one tunable radial deadzone and analog magnitude retained. Treat diagonal keyboard speed, drift and mixed input as explicit tests. For this one-player slice, an explicit input-enabled flag can deliver zero intent when a menu takes focus. Godot's global input polling continues even when a Control consumes the event. Later rebinding can replace Input Map events in the input/settings layer. Defer a remap UI and binding persistence until their scope and storage format are approved. [Godot Input reference](https://docs.godotengine.org/en/4.7/classes/class_input.html) · [Controller input guide](https://docs.godotengine.org/en/4.7/tutorials/inputs/controllers_gamepads_joysticks.html)

**Intent.** Translate the 2D vector using the rig's horizontal heading. Use orthonormal ground-plane right and forward vectors, with screen up mapped to forward. Use yaw rather than normalizing the camera's pitched forward projection near vertical. Pass a world-space planar vector with length at most one to the character. The motor needs no camera, input device or action names. The course root wires the local input node, character and rig. Sample intent before the motor advances each physics tick, with one explicit call path that can also accept injected intent in tests.

**Motor.** Use a grounded `CharacterBody3D` with a capsule shape, `Vector3.UP` and a defined static-world collision mask. On each physics tick, approach desired horizontal velocity using acceleration or braking in units per second squared, apply gravity to vertical velocity, and call `move_and_slide()` once. Supply velocity in units per second and let the engine apply the timestep to motion. Use the resolved floor status and velocity after the move for presentation and diagnostics. Tune `floor_max_angle` and `floor_snap_length` against the course's climbable and steep ramps. Test slope descent, wall sliding, a ledge and recovery by lab reset. Steps, jumping, moving platforms and traversal need separate acceptance criteria. [CharacterBody3D reference](https://docs.godotengine.org/en/4.7/classes/class_characterbody3d.html)

**Facing and state.** Turn the visual pivot toward nonzero desired direction at a bounded angular rate. Keep the last facing at idle. Start with grounded/airborne facts and a speed threshold for idle/moving presentation. A character pushing into a wall may face the input direction while its actual locomotion speed stays near zero. Start with these derived facts and add explicit movement states when behavior diverges, such as climbing or knockback.

| Control source | Recommendation and trade-off |
| --- | --- |
| Direct movement | First slice. The player chooses speed and direction each tick, so stick response and physical collision can be evaluated without a navigation mesh. |
| Point-and-click | Defer until click destinations, route selection and interruptions matter. A future adapter can project the click onto a walkable surface, follow waypoints and translate steering into the same planar intent. It needs navigation data, unreachable-target handling and a policy for whether direct input cancels a route. |
| AI steering | A future AI can supply the same world-space intent, from simple steering or a navigation path. Keep body movement and floor handling in the character so navigation and AI never compete with physics for its transform. |

Godot's `NavigationAgent3D` can supply a next path position once navigation data is available. Its path update runs on physics ticks after a target is set. It does not drive the character body, and its avoidance output is distinct from physical collision. Keep the agent behind a future scene-local adapter. [NavigationAgent3D reference](https://docs.godotengine.org/en/4.7/classes/class_navigationagent3d.html)

## 4. Camera options

| Mode | Scope and ownership |
| --- | --- |
| Orthographic exploration | First follow rig. The camera reads a character-owned target point and follows from a fixed yaw and pitch. Begin with Task 03's 35.264° pitch and 45° yaw and compare sizes 17 and 9.5 while traversing the course. |
| Closer isometric | Same projection and rig. Reuse bounded orthographic size and a short blend. Judge route visibility and character scale before deciding whether both framings belong in gameplay. |
| Orbit and zoom | Add independent look/zoom actions once needed. The rig owns limits, yaw and the target offset. The input adapter should read a consistent yaw for the current physics tick. Reset or teleport must snap follow state so smoothing does not drag the camera across the map. |
| Third person | Separate perspective rig if playtesting justifies it. `SpringArm3D` can retract the camera when a shape cast hits level geometry. Test tight corners, exclude the actor collider and choose a camera-specific obstruction mask. |
| Isometric obstructions | Walls or roofs can hide the subject without crossing the camera boom. Reproduce a visibility problem first. Evaluate authored sightlines or an occluder treatment as an orthographic-specific design. |
| Free camera | Keep the current mode in the prototype. A future dev free camera may take control explicitly while player input is disabled, and return control with a defined snap or blend. |

The rigs can share an explicit target point, a ground heading convention and bound/reset behavior when their implementation truly matches. Projection, orbit behavior and obstruction policy belong to each mode. A mode framework can wait until two rigs are in active use. [Godot third-person spring arm guide](https://docs.godotengine.org/en/4.7/tutorials/3d/spring_arm.html)

## 5. Animation integration

Keep a replaceable `Visual` subtree below the body and capsule. The first slice needs a visible facing marker. When assets are approved, instance an imported glTF/GLB rig under that subtree and correct import-specific scale, rest pose and forward axis there. Keep physics tuning independent of clip names and skeleton paths. If a second humanoid needs shared clips, evaluate `BoneMap` with `SkeletonProfileHumanoid` and verify rest poses and representative clips on both rigs. [Godot skeleton retargeting guide](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/retargeting_3d_skeletons.html)

`AnimationPlayer` owns the imported clips and is sufficient to preview idle and one locomotion loop. Add an `AnimationTree` when the first rig needs reliable idle/locomotion transitions or speed blending. Drive a one-dimensional blend from resolved horizontal speed, with a small idle threshold to avoid chatter. Use the visual pivot for turning. Consider a two-dimensional blend in local space if authored strafe/backpedal clips and gameplay later require it. Inspect acceleration, abrupt reversals and blocked movement for foot sliding.

Start with in-place clips and code-driven movement so analog intent and collision remain authoritative. Root motion can later supply proposed displacement for a specific authored action if its visual benefit justifies reconciling it with collision, turn rate and interruption. Keep that experiment local to the action. [Godot AnimationTree and root motion guide](https://docs.godotengine.org/en/4.7/tutorials/animation/animation_tree.html)

## 6. Development tools

Extend the existing panel pattern in small steps. Add read-only values for action vector, desired and resolved speed, grounded status and camera framing. Use the Godot collision-shape display and Remote scene tree to inspect shape placement, floor behavior and collision masks. Add scene-local reset, camera or lighting controls only where they shorten a specific experiment. Keep their bindings separate from locomotion. Use the Godot profiler and MCP performance monitors first, then add a small frame-time readout if repeated manual checks need it. Future gameplay inspection should read state from the owning feature, with explicit test actions going through that feature's normal commands. Turning off or removing the overlay should leave movement, camera and level behavior intact.

## 7. Testing strategy

| Level | Checks |
| --- | --- |
| Deterministic unit | Inject action vectors and headings to check cardinal and diagonal mapping, yaw rotations, analog magnitude and disabled input. Exercise velocity targets, acceleration, braking, facing wraparound and any derived state thresholds with known timestep values. Keep Godot input binding checks separate from pure translation. |
| Godot headless integration | Instantiate a minimal course under Jolt. Use fixed input for a bounded number of physics frames and tolerances for distance, collision and settling. Cover stopping, a wall slide, climbable/steep ramps, descent, leaving a ledge and landing. Check follow target assignment, zoom bounds and reset. When animation exists, check idle-to-locomotion transitions, reversal and blocked movement using a real graph. |
| MCP runtime and manual | Inspect scene startup, collision shapes and camera framing in a rendered run. Use real controllers to assess deadzone, drift, unplug/reconnect and stick response, and keyboard to check diagonals and simultaneous devices. Synthetic action events establish behavior above the hardware layer. Use manual viewing for follow lag, tight-passage readability and animation blend quality. |

Task 04 has no movement implementation to exercise. The first movement slice is a reasonable approval point for **GUT** because it introduces repeatable logic and real scene integration cases. Evaluate the 9.7 series, with 9.7.1 as a candidate, against the actual Godot 4.7.2 build before pinning. Confirm discovery, a passing run and a deliberate failing run with a nonzero exit, then remove the deliberate failure. If dependency approval is deferred, run a small, focused Godot headless smoke test and retain the same manual criteria. Keep deterministic tests independent of physical hardware and record test counts, skips and runtime limitations. [Project testing strategy](../development/testing-strategy.md) · [GUT 9.7.1 release](https://github.com/bitwes/Gut/releases/tag/v9.7.1) · [GUT CLI](https://gut.readthedocs.io/en/latest/Command-Line.html)

## 8. Risks and trade-offs

| Risk | Mitigation and trigger |
| --- | --- |
| Prototype coupling and input overlap | Use a distinct lab scene and player action names before adding movement. A regression check should still open the visual sandbox and exercise its original controls. |
| Good flat-ground behavior masking collision problems | Include ramps, ledge and passage from the first slice. Tune shape, floor snap and layers against Godot runtime results. |
| Camera feel driving premature abstractions | Hold projection fixed initially and test wide/close at the same target. Add a second rig only if it answers a specific traversal question. |
| Animation or AI acquiring movement authority | Keep the capsule motor as the sole transform writer for locomotion. Add a new intent source or replace the visual scene through explicit wiring. |
| Weak rollback and incomplete test evidence | Git currently has no `HEAD` revision and the files are untracked. Establish a reviewable baseline before a larger change, with separate authorization for a commit. Prior tasks also found that MCP process mode did not discover Godot. Use the direct console executable and editor bridge for independent checks while that setup issue is open. |

## 9. Proposed implementation milestones

1. **First approval and movement lab.** Add one character, an input adapter, a collision course and one orthographic follow rig. Accept when stick and keyboard start, turn and stop predictably, diagonals respect the speed limit, the character slides along walls and handles the test ramps and ledge, and the camera follows and resets. Include a small diagnostic readout and verify the existing sandbox still launches.
2. **Framing and feel.** Compare wide and close while moving through the passage and around an obstacle. Tune acceleration, braking and follow responsiveness. Add orbit or test a third-person rig only if the first comparison identifies a question it can answer.
3. **First replaceable character visual.** After asset approval, integrate idle and locomotion clips. Verify the visual swap and transitions while leaving the movement contract and collision tests intact.

Navigation, AI steering, input profile persistence, combat and world simulation remain separately scoped work.

## 10. Decisions requiring approval

- Approve the first slice's scope and ownership boundaries, including controller-first direct input, a world-space intent boundary, a capsule motor and a fixed-yaw orthographic follow rig for the lab. The initial view is an experiment.
- Decide whether to approve GUT as a test dependency for that slice or proceed with focused headless checks first.
- Review future scope separately before adopting binding persistence, navigation or a second camera mode. Record durable decisions through the [ADR process](../decisions/README.md) after review.

**Investigation verification.** MCP confirmed the live editor and deep project validation reported zero errors and warnings. These checks establish the prototype baseline. Movement, controller hardware behavior and animation remain unverified proposals.
