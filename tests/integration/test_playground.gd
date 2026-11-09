extends "res://addons/gut/test.gd"

const Playground = preload("res://dev/playground/playground.tscn")
const CharacterMotor = preload("res://game/characters/character_motor.gd")
const FollowRig = preload("res://game/camera/orthographic_follow.gd")
const SettlementLighting = preload("res://prototypes/camera_experiment/settlement_lighting.gd")
const ThirdPersonRig = preload("res://dev/playground/third_person_rig.gd")
const STEP: float = 1.0 / 60.0

var _scene: Node3D
var _player: CharacterMotor


func before_each() -> void:
	_scene = Playground.instantiate()
	add_child_autofree(_scene)
	_scene.set_physics_process(false)
	_player = _scene.get_node("Player")


func test_spawn_grounds_player_and_uses_close_follow_camera() -> void:
	var rig := _scene.get_node("FollowRig") as FollowRig
	assert_eq(rig.target, _player.get_node("FollowTarget"))
	assert_eq(rig.framing_size(), 9.5)
	assert_null(_scene.get_node_or_null("Environment/Settlement/Camera"))
	assert_null(_scene.get_node_or_null("Environment/Settlement/Overlay"))
	assert_null(_scene.get_node("Environment/Settlement").get_script())
	await _drive(Vector3.ZERO, 10)
	assert_true(_player.is_on_floor())
	assert_almost_eq(_player.position.y, 0.0, 0.02)


func test_hall_blocks_player_and_locomotion_returns_to_idle() -> void:
	_player.respawn(Vector3(-1, 0.035, -3.7))
	await _drive(Vector3.LEFT, 50)
	await get_tree().process_frame
	assert_between(_player.position.x, -2.45, -2.36)
	assert_lt(_player.actual_horizontal_speed, 0.1)
	assert_eq(_animation().current_animation, "Idle_02")


func test_player_can_traverse_passage_between_storehouse_and_ruin() -> void:
	_player.respawn(Vector3(7.8, 0.035, 7.3))
	await _drive(Vector3.FORWARD, 64)
	assert_lt(_player.position.z, 3.7)
	assert_almost_eq(_player.position.x, 7.8, 0.03)
	assert_true(_player.is_on_floor())


func test_tree_trunk_blocks_player_without_canopy_collision() -> void:
	_player.respawn(Vector3(-7, 0.035, 4.2))
	await _drive(Vector3.LEFT, 48)
	assert_between(_player.position.x, -8.62, -8.5)
	assert_true(_player.is_on_floor())


func test_night_preserves_movement_and_reset_keeps_lighting() -> void:
	var lighting := _scene.get_node("Environment/Settlement/WorldEnvironment") as SettlementLighting
	var fire := _scene.get_node("Environment/Settlement/Courtyard/Campsite/Firelight") as OmniLight3D
	var day_fire := fire.light_energy
	await _drive(Vector3.FORWARD, 30)
	var daylight_position := _player.position
	lighting.set_night(true)
	_scene.reset_player()
	assert_true(lighting.is_night)
	assert_true(fire.shadow_enabled)
	assert_gt(fire.light_energy, day_fire)
	assert_eq(_player.position, (_scene.get_node("Spawn") as Marker3D).position)
	assert_eq(_player.velocity, Vector3.ZERO)
	await _drive(Vector3.FORWARD, 30)
	await get_tree().process_frame
	assert_almost_eq(_player.position, daylight_position, Vector3.ONE * 0.025)
	assert_eq(_animation().current_animation, "Running")
	lighting.set_night(false)
	assert_false(fire.shadow_enabled)
	assert_eq(fire.light_energy, day_fire)


func test_camera_switch_preserves_player_and_uses_active_heading() -> void:
	var rig := _scene.get_node("ThirdPersonRig") as ThirdPersonRig
	var iso_camera := _scene.get_node("FollowRig/Camera") as Camera3D
	var third_camera := rig.get_node("SpringArm/Camera") as Camera3D
	assert_eq(_scene.get_viewport().get_camera_3d(), iso_camera)
	await _drive(Vector3.FORWARD, 14)
	var position := _player.position
	var velocity := _player.velocity
	_scene.switch_camera()
	assert_eq(_scene.get_viewport().get_camera_3d(), third_camera)
	assert_eq(_player.position, position)
	assert_eq(_player.velocity, velocity)
	rig.orbit(Vector2(135.0, 0.0))
	assert_almost_eq(_scene.camera_heading(), -PI / 2.0, 0.001)
	_scene.reset_player()
	rig.orbit(Vector2(135.0, 0.0))
	Input.action_press(&"move_forward")
	_scene.set_physics_process(true)
	for frame in range(20):
		await get_tree().physics_frame
	Input.action_release(&"move_forward")
	_scene.set_physics_process(false)
	assert_gt(_player.position.x, 0.65)
	assert_almost_eq(_player.position.z, 2.2, 0.03)
	_scene.switch_camera()
	assert_eq(_scene.get_viewport().get_camera_3d(), iso_camera)
	assert_almost_eq(_scene.camera_heading(), PI / 4.0, 0.001)
	assert_eq(iso_camera.size, 9.5)


func test_spring_arm_retracts_at_hall_and_reset_restores_clear_boom() -> void:
	var rig := _scene.get_node("ThirdPersonRig") as ThirdPersonRig
	_player.respawn(Vector3(-5.6, 0.035, -6.6))
	_scene.switch_camera()
	rig.orbit(Vector2(45.0, -16.0))
	await _drive(Vector3.ZERO, 8)
	assert_gt(rig.obstruction_distance(), 0.2)
	assert_lt(rig.obstruction_distance(), 1.4)
	_scene.zoom_camera(100.0)
	assert_eq(rig.requested_distance(), 8.0)
	_scene.zoom_camera(-100.0)
	assert_eq(rig.requested_distance(), 2.0)
	_scene.reset_player()
	await _drive(Vector3.ZERO, 8)
	assert_true(_scene.is_third_person)
	assert_almost_eq(rig.yaw_degrees, 45.0, 0.01)
	assert_almost_eq(rig.elevation_degrees, 16.0, 0.01)
	assert_almost_eq(rig.requested_distance(), 4.0, 0.01)
	assert_almost_eq(rig.obstruction_distance(), 4.0, 0.04)


func _animation() -> AnimationPlayer:
	return _player.get_node("Visual/WandererModel/AnimationPlayer") as AnimationPlayer


func _drive(intent: Vector3, frames: int) -> void:
	for index in range(frames):
		await get_tree().physics_frame
		_player.step(intent, STEP)
