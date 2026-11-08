# 06B — Character asset and locomotion

## Source and organization

The supplied file was `Meshy_AI_Weary_Wanderer_20261108_animated_mixamo_All_animation.glb`. The project context identifies it as a Meshy-generated protagonist study. The filename and Mixamo-style joint names suggest the rig's lineage, and the GLB identifies Khronos glTF Blender I/O 4.5.51 as the exporter. The delivery included no license, source project, separate clips or texture files. Asset-specific redistribution terms are unverified. Confirm the Meshy export and animation rights before publishing or redistributing it.

The [active GLB](../../assets/characters/weary_wanderer/weary_wanderer_animated.glb) is the newer 20.08 MB delivery, renamed without rewriting it. Its SHA-256 is `7c275227ebee468e7924ee3017dfd1cc5b8ce07acc767be60eb5a411696ae692`. The [earlier export](../../assets/characters/weary_wanderer/source/weary_wanderer.glb) is preserved byte-for-byte under `.gdignore` because it contains clips absent from the newer delivery. Godot imports only the active export. No Git LFS was introduced.

- `assets/characters/weary_wanderer/` holds reusable art. Textures and animation stay bundled with the GLB while the source delivers them that way.
- `game/characters/` holds the player scene, unchanged movement motor and the character-specific visual adapter.
- [Wanderer inspection](../../dev/asset_lab/wanderer_inspection.tscn) is a separately runnable scene for scale and material inspection.

## Model, rig and import

The glTF 2.0 binary contains one skinned triangle primitive, 16,340 exported vertices and 10,380 triangles. Its `BakedMaterial` uses embedded PNG base color, normal and metallic/roughness maps. `SmartRigArmature` contains a 72-joint skin rooted at `mixamorig:Hips`, with spine, head, arm, finger and leg chains and several auxiliary head joints. The newer export has the same joint names, mesh counts and bounds as the earlier one, and supplies 18 clips, including 11 idles. No retargeting was required.

The mesh bounds are approximately 0.76 m wide, 1.70 m tall and 0.41 m deep, with the source base at Y=0. This matches the 1.70 m capsule height without rescaling. The imported asset faces +Z. The visual adapter turns its local model 180° so it follows the motor's −Z facing convention. The motor still controls the visual pivot, and the collider retains its original transform.

Godot imports the GLB at root scale 1 with animation enabled. The import sidecar sets linear looping on `Idle_02`, `Walking` and `Running` and embeds the textures losslessly in the imported scene. This keeps the three original PNGs recoverable in the GLB and avoids separate texture copies in Git. [Godot glTF import settings](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_3d_scenes/import_configuration.html)

## Animation selection

| Supplied clip | Use |
| --- | --- |
| `Idle_02` (1.87 s) | Used at rest. Its hips return to their starting position, with less than 1 cm of excursion on each axis. |
| `Walking` (1.03 s), `Running` (0.63 s) | Used. The hips return to their starting positions and retain only small local stride motion. |
| `walking_2` | Excluded. The hip track advances about 1.14 m along +Z. |
| `Idle_03`, `Idle_10`, `Idle_11`, `Idle_3` through `Idle_9` | Available for future visual evaluation. |
| `Arise`, `Boxing_Guard_Prep_Straight_Punch`, `Double_Combo_Attack`, `Stand_Dodge` | Preserved in the active export and unused by the lab. |

The adapter uses `Idle_02` at rest, when blocked, or in the air until an airborne clip is selected in a separate task. The imported `AnimationPlayer` blends clip changes over 0.16 s and scales locomotion playback from **resolved horizontal speed**. Idle starts below 0.12 m/s. Run starts at 3.4 m/s and returns to walk below 3.15 m/s. The visual consumes motion data without writing to the body. Set **Use Placeholder** on the player's `Visual` node before launch to use the original debug mesh.

## Verification and manual checks

The movement lab integration tests cover the skeleton, loop flags, idle playback, walk/run playback, playback-rate response, facing and the return to idle at a wall. Existing collision, braking, slope, ledge and follow-camera tests remain in the same suite. MCP process mode could not locate the installed executable, so headless verification used the console executable directly.

1. Open the inspection scene and press F6. Look at the material, face direction and contact with the floor.
2. Open the movement lab and press F6. Use a partial left-stick tilt to walk, full tilt or WASD to run, and V for a closer camera. Turn while moving, then release input.
3. Push squarely against a wall. Confirm the diagnostics show near-zero actual speed and the legs stop cycling. Move along the wall to verify that real sideways travel resumes locomotion.
4. Enable **Use Placeholder** on `Visual` for a side-by-side physics comparison. Review foot contact, stride rate and transitions on a physical controller.

Evaluate the idle-to-walk blend and foot sliding at the lab's existing speed before changing playback tuning or adding more clips.
