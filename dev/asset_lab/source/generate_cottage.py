"""Build the one-off cottage study with Blender 5.2's bundled Python."""

from pathlib import Path
import sys

import bmesh
import bpy
from mathutils import Vector


def build():
    scene = bpy.data.scenes.new("Cottage Study")
    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 1.0
    collection = bpy.data.collections.new("Cottage Geometry")
    scene.collection.children.link(collection)
    root = bpy.data.objects.new("Cottage", None)
    collection.objects.link(root)

    def material(name, rgb, roughness=0.9):
        mat = bpy.data.materials.new(name)
        mat.diffuse_color = (*rgb, 1)
        mat.use_nodes = True
        shader = mat.node_tree.nodes.get("Principled BSDF")
        shader.inputs["Base Color"].default_value = mat.diffuse_color
        shader.inputs["Roughness"].default_value = roughness
        return mat

    plaster = material("Lime Plaster", (0.51, 0.43, 0.32))
    timber = material("Smoked Oak", (0.125, 0.075, 0.047))
    door = material("Weathered Oak", (0.23, 0.138, 0.076))
    stone = material("Foundation Stone", (0.255, 0.247, 0.212))
    iron = material("Dark Iron", (0.055, 0.054, 0.047))
    glass = material("Dark Leaded Glass", (0.052, 0.078, 0.077), 0.42)
    slate = [
        material("Slate", (0.126, 0.141, 0.143)),
        material("Slate Weathered", (0.152, 0.161, 0.154)),
    ]

    def mesh(name, vertices, faces, mat):
        data = bpy.data.meshes.new(name)
        data.from_pydata(vertices, [], faces)
        bm = bmesh.new()
        bm.from_mesh(data)
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
        assert all(edge.is_manifold for edge in bm.edges), name
        assert all(face.calc_area() > 1e-7 for face in bm.faces), name
        assert bm.calc_volume(signed=True) > 0, name
        bm.to_mesh(data)
        bm.free()
        assert not data.validate(), name
        data.update()
        data.materials.append(mat)
        obj = bpy.data.objects.new(name, data)
        collection.objects.link(obj)
        obj.parent = root
        return obj

    def extrude(name, front, rear, mat):
        count = len(front)
        sides = [(i, (i + 1) % count, (i + 1) % count + count, i + count)
                 for i in range(count)]
        return mesh(name, front + rear, [tuple(range(count)), tuple(range(count, count * 2))]
                    + sides, mat)

    def beam(name, start, end, width, depth, mat):
        start, end = Vector(start), Vector(end)
        along = (end - start).normalized()
        across = along.cross(Vector((0, 1, 0)))
        if across.length < 0.001:
            across = along.cross(Vector((0, 0, 1)))
        across = across.normalized() * width / 2
        thick = along.cross(across).normalized() * depth / 2
        corners = [across + thick, -across + thick, -across - thick, across - thick]
        extrude(name, [start + p for p in corners], [end + p for p in corners], mat)

    def box(name, center, size, mat):
        x, y, z = center
        w, d, h = (v / 2 for v in size)
        ring = [(x - w, z - h), (x + w, z - h), (x + w, z + h), (x - w, z + h)]
        extrude(name, [(a, y - d, b) for a, b in ring], [(a, y + d, b) for a, b in ring], mat)

    box("Stone Plinth", (0, 0, 0.15), (6.04, 8.04, 0.30), stone)
    box("Plaster Walls", (0, 0, 1.75), (6, 8, 2.9), plaster)
    gable = [(-3, 3.19), (3, 3.19), (0, 6.02)]
    extrude("Plaster Gables", [(x, -3.99, z) for x, z in gable],
            [(x, 3.99, z) for x, z in gable], plaster)

    for side in (-1, 1):
        for y in (-4.025, 4.025):
            box(f"Corner Post {side} {y}", (side * 2.91, y, 1.74), (0.19, 0.17, 2.89), timber)
            beam(f"Gable Rake {side} {y}", (side * 2.97, y, 3.22), (0, y, 6.04), 0.16, 0.13, timber)
        box(f"Side Sill {side}", (side * 3.03, 0, 0.42), (0.15, 8.08, 0.19), timber)
        box(f"Side Plate {side}", (side * 3.03, 0, 3.08), (0.15, 8.08, 0.19), timber)
        for y in (-2, 0, 2):
            box(f"Side Stud {side} {y}", (side * 3.025, y, 1.74), (0.13, 0.15, 2.72), timber)
        for y in (-3.7, 3.7):
            beam(f"Side Brace {side} {y}", (side * 3.03, y, 1.80),
                 (side * 3.03, y * 0.73, 3.03), 0.14, 0.14, timber)
        roof = [(0, 6.19), (side * 3.36, 3.05), (side * 3.36, 2.92), (0, 6.04)]
        extrude(f"Slate Roof {side}", [(x, -4.31, z) for x, z in roof],
                [(x, 4.31, z) for x, z in roof], slate[0])
        for i in range(1, 9):
            x = side * i * 0.38
            z = 6.19 - abs(x) * 3.14 / 3.36
            beam(f"Slate Course {side} {i}", (x, -4.315, z), (x, 4.315, z),
                 0.065, 0.078, slate[int(i % 3 == 0)])

    box("Ridge Cap", (0, 0, 6.19), (0.19, 8.67, 0.14), slate[1])
    for y in (-4.055, 4.055):
        box(f"Gable Tie {y}", (0, y, 3.16), (6.03, 0.15, 0.20), timber)
        box(f"Gable King Post {y}", (0, y, 4.57), (0.18, 0.16, 2.68), timber)
    box("Rear Sill", (0, 4.05, 0.42), (6, 0.14, 0.19), timber)

    box("Threshold", (0, -4.16, 0.105), (1.57, 0.57, 0.21), stone)
    box("Door Backing", (0, -4.065, 1.22), (1.16, 0.12, 2.02), timber)
    for i in range(6):
        box(f"Door Plank {i + 1}", ((i - 2.5) * 0.183, -4.132, 1.22),
            (0.176, 0.055, 2.01), door)
    for x in (-0.65, 0.65):
        box(f"Door Jamb {x}", (x, -4.14, 1.22), (0.17, 0.20, 2.14), timber)
    box("Door Lintel", (0, -4.14, 2.34), (1.50, 0.21, 0.20), timber)
    for z in (0.70, 1.79):
        box(f"Strap Hinge {z}", (-0.38, -4.171, z), (0.47, 0.035, 0.066), iron)
    box("Door Latch", (0.41, -4.177, 1.13), (0.14, 0.085, 0.072), iron)

    for x in (-1.84, 1.84):
        box(f"Window Glass {x}", (x, -4.054, 1.82), (0.65, 0.09, 0.79), glass)
        for offset in (-0.37, 0.37):
            box(f"Window Jamb {x} {offset}", (x + offset, -4.105, 1.82),
                (0.12, 0.16, 0.94), timber)
        box(f"Window Head {x}", (x, -4.105, 2.25), (0.84, 0.16, 0.13), timber)
        box(f"Window Sill {x}", (x, -4.15, 1.38), (0.92, 0.25, 0.15), timber)
        box(f"Window Mullion {x}", (x, -4.119, 1.82), (0.065, 0.065, 0.79), timber)
        box(f"Window Transom {x}", (x, -4.119, 1.82), (0.65, 0.065, 0.065), timber)
        box(f"Front Sill {x}", (x, -4.05, 0.42), (2.24, 0.14, 0.19), timber)

    box("Chimney Stack", (1.59, 2.45, 5.46), (0.72, 0.86, 1.86), stone)
    box("Chimney Cap", (1.59, 2.45, 6.43), (0.89, 1.02, 0.16), stone)
    return scene, collection, root


def main():
    source = Path(__file__).resolve().parent
    standalone = bpy.app.background and "--standalone" in sys.argv
    previous_scenes = list(bpy.data.scenes)
    scene, collection, root = build()
    bpy.context.window.scene = scene
    if standalone:
        # Use only with a disposable factory-startup background process.
        for previous in previous_scenes:
            bpy.data.scenes.remove(previous)
        bpy.data.orphans_purge(do_recursive=True)
        bpy.context.preferences.filepaths.save_version = 0
        bpy.ops.wm.save_as_mainfile(filepath=str(source / "cottage.blend"))
    else:
        # Keep unrelated scenes in the interactive session out of the source file.
        bpy.data.libraries.write(str(source / "cottage.blend"), {scene}, fake_user=True)
    bpy.ops.export_scene.gltf(
        filepath=str(source.parent / "cottage.glb"),
        export_format="GLB",
        use_active_scene=True,
        export_yup=True,
        export_animations=False,
        export_cameras=False,
        export_lights=False,
    )
    vertices = [vertex.co for obj in collection.objects if obj.type == "MESH"
                for vertex in obj.data.vertices]
    return {
        "blender": bpy.app.version_string,
        "root": root.name,
        "mesh_count": len(collection.objects) - 1,
        "bounds": [[round(fn(v[i] for v in vertices), 4) for i in range(3)]
                   for fn in (min, max)],
        "triangle_count": sum(len(face.vertices) - 2 for obj in collection.objects
                              if obj.type == "MESH" for face in obj.data.polygons),
    }


if __name__ == "__main__":
    result = main()
