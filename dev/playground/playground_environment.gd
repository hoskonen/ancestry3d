extends Node3D


func _enter_tree() -> void:
	var settlement := $Settlement
	# Keep the authored environment, leaving prototype input and cameras out of play.
	settlement.set_script(null)
	for path in ["Camera", "Overlay"]:
		var preview_node := settlement.get_node_or_null(path)
		if preview_node != null:
			preview_node.free()
	for path in ["Marker", "OcclusionMarkers", "Campsite/VisibilityMarkers"]:
		var markers := settlement.get_node("Courtyard/" + path) as Node3D
		markers.hide()
