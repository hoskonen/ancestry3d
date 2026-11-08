# 06A — Blender-to-Godot asset pipeline

This experiment uses one exterior cottage with a 6 × 8 m wall footprint. It has lime plaster, smoked-oak framing, a steep slate gable, a plank door with ironwork, two small leaded windows and a stone chimney. The editable parts remain separate in Blender. Open the Godot inspection scene and press F6 to review the import.

## Files and reproducibility

- [Editable Blender source](../../dev/asset_lab/source/cottage.blend) and [one-off generator](../../dev/asset_lab/source/generate_cottage.py) live under a `.gdignore` boundary. Godot imports the neighboring GLB without requiring Blender on the Godot machine.
- [GLB](../../dev/asset_lab/cottage.glb) and its `.import` sidecar are the runtime asset and import settings. Keep them together. Godot can regenerate its imported cache.
- [Inspection scene](../../dev/asset_lab/cottage_inspection.tscn) loads the GLB and checks its geometry, orientation and material count at startup. A small scene-local script does the instancing because the current Godot MCP instance tool accepts only `.tscn` and `.scn` paths.

The first build used Blender MCP Python execution. The generator builds one isolated scene from native meshes and Principled materials, checks each mesh, writes a Blender source and exports the GLB. To reproduce the deliverables with Blender 5.2.2, copy the generator to a clean scratch folder named `source` and run this from its parent. Use a disposable factory-startup session because standalone mode removes the startup scenes and unused data from that process. The command writes `source/cottage.blend` and `cottage.glb` in the scratch tree.

~~~powershell
blender --background --factory-startup --python-exit-code 1 --python source/generate_cottage.py -- --standalone
~~~

The clean rebuild produced an identical GLB SHA-256, `1d69ffd7d72b53fef1fb4d5154e5b43c362cf9b5f4899943145d44f3e7dddfbc`. The final editable source was reopened separately and contained only the cottage scene and its local dependencies. For hand-edited variants, treat the saved Blender file as the source of truth and export from it. The generator reproduces the experimental baseline.

## Export and import conventions

Use meters with unit scale 1, identity transforms and a ground-centered root. Model Z-up with the front toward Blender −Y. Export binary glTF with Y-up conversion, the active scene only, and animation, cameras and lights disabled. This maps the cottage's front to Godot +Z. Simple Principled base colors and roughness carry through without external textures. Keep preview lighting in the Godot inspection scene. [Godot 3D import guide](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_3d_scenes/index.html)

The GLB is a visual asset. When collision becomes necessary, begin with simple Godot box or convex shapes in the owning scene. Godot's import options and collision suffixes can generate convex or static concave collision from authored meshes, but those paths were only researched here. Favor a small collision proxy over the decorative geometry. [Godot collision import options](https://docs.godotengine.org/en/4.6/tutorials/assets_pipeline/importing_3d_scenes/node_type_customization.html)

## Validation

| Check | Result |
| --- | --- |
| Blender mesh integrity | 81 named meshes, 968 triangles and eight materials. BMesh checks passed for manifold edges, positive signed volume and nondegenerate faces. Blender mesh validation needed no repairs. |
| Saved source | Reopened the standalone file in Blender. One scene, 82 objects including the origin root, identity local transforms, zero linked libraries and zero saved actions. |
| Godot import and runtime | Godot 4.7.2 imported the GLB as a PackedScene. Runtime checks found 81 mesh instances, eight named materials and bounds of 6.72 × 6.51 × 8.78 m in Godot X/Y/Z order. The base is at Y=0 and the door faces +Z. |
| Visual review | A Godot MCP screenshot confirmed the timber, plaster, roof courses, door and windows under Forward+ lighting. The scene ran with no errors or warnings. |

Blender MCP scene inspection, Python mesh creation and GLB export were exercised live. Dedicated Blender viewport/thumbnail rendering is exposed by the tool set and was not exercised. Blender MCP's background helper could not discover the executable, so the standalone source and rebuild checks used the installed Blender executable directly. Godot MCP process mode also could not discover its executable, so visual verification used the connected editor run.

## Animation findings

In a disposable background copy of the Blender session, inserting rotation keys on the door at frames 1 and 12 created an Action with that range. This verified the Blender Python object-animation path without saving animation into the source. Blender's Python API also exposes armature and pose-bone editing, Action management and NLA. Those capabilities and their transfer to Godot were researched only. No skeleton, skin weights, humanoid clip or animation GLB was created.

A future transfer test should use one small armature, an explicitly named Action and a skinned mesh. Verify the imported skeleton, clip names, frame range, playback and facing in Godot before adopting humanoid retargeting. Keep the rig and clips in the replaceable visual scene. [Godot AnimationTree guide](https://docs.godotengine.org/en/4.7/tutorials/animation/animation_tree.html) · [Godot skeleton retargeting guide](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/retargeting_3d_skeletons.html)

The cottage is an exterior study with solid walls and applied window and door details. It has no interior, operable door or collision. The many separate parts favor editability. Measure draw calls in a representative scene before deciding whether a future export should merge static parts by material. Review scale and silhouette beside the existing placeholder character before creating another building.
