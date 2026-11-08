extends "res://addons/gut/test.gd"

const Playground = preload("res://dev/playground/playground.tscn")
const SettlementLighting = preload("res://prototypes/camera_experiment/settlement_lighting.gd")


func test_environment_can_reenter_tree_without_restoring_preview_nodes() -> void:
	var playground := Playground.instantiate()
	add_child_autofree(playground)
	playground.set_physics_process(false)
	var environment := playground.get_node("Environment")
	var settlement := environment.get_node("Settlement")
	var lighting := settlement.get_node("WorldEnvironment") as SettlementLighting
	var camera := playground.get_viewport().get_camera_3d()
	lighting.set_night(true)

	playground.remove_child(environment)
	playground.add_child(environment)

	assert_true(settlement.is_inside_tree())
	assert_null(settlement.get_node_or_null("Camera"))
	assert_null(settlement.get_node_or_null("Overlay"))
	assert_null(settlement.get_script())
	assert_true(lighting.is_night)
	assert_eq(playground.get_viewport().get_camera_3d(), camera)
