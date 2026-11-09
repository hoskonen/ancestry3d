extends "res://addons/gut/test.gd"

const Playground = preload("res://dev/playground/playground.tscn")
const PlaygroundController = preload("res://dev/playground/playground.gd")
const WorldClock = preload("res://game/world_time/world_clock.gd")
const Lighting = preload("res://prototypes/camera_experiment/settlement_lighting.gd")

var _scene: PlaygroundController
var _clock: WorldClock
var _lighting: Lighting


func before_each() -> void:
	_scene = _add_playground()
	_clock = _scene.world_clock()
	_lighting = _scene.get_node("Environment/Settlement/WorldEnvironment")


func test_initial_time_and_paused_debug_jumps() -> void:
	assert_eq(_clock.day_index(), 0)
	assert_eq(_clock.seconds_of_day(), 32400.0)
	assert_eq(_clock.rate(), 60.0)
	assert_false(_clock.is_paused())
	assert_false(_lighting.is_night)
	_scene.toggle_clock_pause()
	assert_true(_scene.advance_to_opposite_phase())
	assert_eq(_clock.seconds_of_day(), 75600.0)
	assert_true(_lighting.is_night)
	assert_true(_scene.advance_to_opposite_phase())
	assert_eq(_clock.day_index(), 1)
	assert_eq(_clock.seconds_of_day(), 32400.0)
	assert_false(_lighting.is_night)
	assert_true(_clock.is_paused())


func test_lighting_uses_exact_boundaries_and_interval_endpoint() -> void:
	var fire := _scene.get_node("Environment/Settlement/Courtyard/Campsite/Firelight") as OmniLight3D
	var torch := _scene.get_node("Environment/Settlement/Courtyard/Storehouse/Torchlight") as OmniLight3D
	var day_environment := _lighting.environment
	assert_true(_clock.advance_seconds(32399.0))
	assert_false(_lighting.is_night)
	assert_true(_clock.advance_seconds(1.0))
	assert_true(_lighting.is_night)
	assert_eq(_lighting.environment, _lighting.night_environment)
	assert_true(fire.shadow_enabled)
	assert_true(torch.visible)
	assert_true(_clock.advance_seconds(43199.0))
	assert_true(_lighting.is_night)
	assert_true(_clock.advance_seconds(1.0))
	assert_false(_lighting.is_night)
	assert_eq(_lighting.environment, day_environment)
	assert_false(fire.shadow_enabled)
	assert_false(torch.visible)
	assert_true(_clock.advance_seconds(2.0 * WorldClock.SECONDS_PER_DAY))
	assert_eq(_clock.day_index(), 3)
	assert_false(_lighting.is_night)


func test_early_night_jumps_to_the_same_morning() -> void:
	assert_true(_clock.advance_seconds(17.0 * WorldClock.SECONDS_PER_HOUR))
	assert_true(_lighting.is_night)
	assert_true(_scene.advance_to_opposite_phase())
	assert_eq(_clock.day_index(), 1)
	assert_eq(_clock.seconds_of_day(), 32400.0)


func test_reentry_retains_clock_and_fresh_scene_has_its_own_clock() -> void:
	_clock.set_paused(true)
	_clock.set_rate(120.0)
	var parent := _scene.get_parent()
	parent.remove_child(_scene)
	assert_true(_scene.advance_to_opposite_phase())
	parent.add_child(_scene)
	var world := _scene.get_node("Environment")
	_scene.remove_child(world)
	_scene.add_child(world)
	assert_eq(_scene.world_clock(), _clock)
	assert_eq(_clock.advanced.get_connections().size(), 1)
	assert_eq(_clock.seconds_of_day(), 75600.0)
	assert_eq(_clock.rate(), 120.0)
	assert_true(_clock.is_paused())
	assert_true(_lighting.is_night)
	var fresh := _add_playground()
	assert_ne(fresh.world_clock(), _clock)
	assert_eq(fresh.world_clock().elapsed_seconds(), 32400.0)
	# Let the imported skeleton dispose of its queued simulator after re-entry.
	await get_tree().process_frame
	await get_tree().process_frame


func test_camera_and_reset_preserve_clock_and_fall_tick_advances() -> void:
	var start := _clock.elapsed_seconds()
	_scene.switch_camera()
	_scene.reset_player()
	assert_eq(_clock.elapsed_seconds(), start)
	var player := _scene.get_node("Player") as CharacterBody3D
	player.position.y = -10.0
	_scene._physics_process(0.5)
	assert_eq(_clock.elapsed_seconds(), start + 30.0)
	assert_eq(player.position, (_scene.get_node("Spawn") as Marker3D).position)


func test_clock_pause_leaves_movement_running_and_tree_pause_stops_ticks() -> void:
	var tree := get_tree()
	var start := _clock.elapsed_seconds()
	_scene.set_physics_process(true)
	for frame in range(5):
		await tree.physics_frame
	assert_gt(_clock.elapsed_seconds(), start)
	tree.paused = true
	var tree_pause_time := _clock.elapsed_seconds()
	for frame in range(3):
		await tree.physics_frame
	tree.paused = false
	assert_eq(_clock.elapsed_seconds(), tree_pause_time)

	_clock.set_paused(true)
	var player := _scene.get_node("Player") as CharacterBody3D
	var position := player.position
	Input.action_press(&"move_forward")
	for frame in range(12):
		await tree.physics_frame
	Input.action_release(&"move_forward")
	_scene.set_physics_process(false)
	assert_eq(_clock.elapsed_seconds(), tree_pause_time)
	assert_gt(player.position.distance_to(position), 0.1)


func _add_playground() -> PlaygroundController:
	var scene := Playground.instantiate() as PlaygroundController
	add_child_autofree(scene)
	scene.set_physics_process(false)
	return scene
