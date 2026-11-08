extends "res://addons/gut/test.gd"


func test_runner_discovers_project_tests() -> void:
	assert_true(ResourceLoader.exists("res://prototypes/camera_experiment/camera_experiment.tscn"))
