extends Node3D

const COTTAGE = preload("res://dev/asset_lab/cottage.glb")
const EXPECTED_SIZE := Vector3(6.72, 6.51, 8.78)
const EXPECTED_MATERIAL_COUNT: int = 8


func _ready() -> void:
	var cottage := COTTAGE.instantiate() as Node3D
	add_child(cottage)
	var bounds := AABB()
	var materials: Dictionary[String, bool] = {}
	var mesh_count: int = 0
	var front_door_found: bool = false
	for node in cottage.find_children("*", "MeshInstance3D", true, false):
		var part := node as MeshInstance3D
		var part_bounds := part.global_transform * part.get_aabb()
		bounds = part_bounds if mesh_count == 0 else bounds.merge(part_bounds)
		mesh_count += 1
		var part_name := String(part.name).to_lower().replace("_", " ")
		if part_name.begins_with("door backing"):
			front_door_found = part_bounds.get_center().z > 4.0
		for index in range(part.mesh.get_surface_count()):
			var material := part.mesh.surface_get_material(index)
			if material != null:
				materials[material.resource_name] = true
	if mesh_count != 81 or not bounds.size.is_equal_approx(EXPECTED_SIZE):
		push_error("Unexpected cottage geometry: %s meshes, %s bounds" % [mesh_count, bounds])
	if not is_zero_approx(bounds.position.y) or not front_door_found:
		push_error("Cottage must sit on Y=0 with its door facing +Z.")
	if materials.size() != EXPECTED_MATERIAL_COUNT:
		push_error("Unexpected cottage material count: %s" % materials.size())
	print("Cottage inspection: %s meshes, bounds %s, +Z door %s, materials %s" % [
		mesh_count, bounds, front_door_found, materials.keys(),
	])
