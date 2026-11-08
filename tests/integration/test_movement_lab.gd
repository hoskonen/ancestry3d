extends "res://addons/gut/test.gd"

const Lab = preload("res://dev/movement_lab/movement_lab.tscn")
const Motor = preload("res://game/characters/character_motor.gd")
const FollowRig = preload("res://game/camera/orthographic_follow.gd")
const STEP: float = 1.0 / 60.0

var _lab: Node3D
var _player: Motor


func before_each() -> void:
	_lab = Lab.instantiate()
	add_child_autofree(_lab)
	_lab.set_physics_process(false)
	_player = _lab.get_node("Player")


func test_stops_after_input_release() -> void:
	await _place(Vector3(0, 0.03, 4.5))
	await _drive(Vector3.FORWARD, 30)
	assert_gt(_player.actual_horizontal_speed, 3.0)
	await _drive(Vector3.ZERO, 24)
	var stopped := _player.global_position
	await _drive(Vector3.ZERO, 12)
	assert_lt(_player.actual_horizontal_speed, 0.02)
	assert_lt(_player.global_position.distance_to(stopped), 0.02)


func test_wall_blocks_forward_motion_and_allows_tangent_motion() -> void:
	await _place(Vector3(1, 0.03, 1))
	await _drive(Vector3.RIGHT, 40)
	assert_between(_player.position.x, 2.35, 2.49)
	assert_lt(_player.actual_horizontal_speed, 0.05)
	var wall_contact_z := _player.position.z
	await _drive(Vector3(1, 0, -1).normalized(), 32)
	assert_between(_player.position.x, 2.35, 2.49)
	assert_lt(_player.position.z, wall_contact_z - 0.8)


func test_walkable_ramp_and_ledge_landing() -> void:
	await _place(Vector3(-4.5, 0.03, -2.55))
	await _drive(Vector3.FORWARD, 64)
	assert_gt(_player.position.y, 0.95)
	assert_true(_player.is_on_floor())
	var left_ledge := false
	for index in range(100):
		await _drive(Vector3.FORWARD, 1)
		left_ledge = left_ledge or not _player.is_on_floor()
		if left_ledge and _player.is_on_floor():
			break
	assert_true(left_ledge)
	assert_true(_player.is_on_floor())
	assert_between(_player.position.y, -0.04, 0.07)


func test_steep_ramp_does_not_behave_as_walkable_floor() -> void:
	await _place(Vector3(0.8, 0.03, -3.95))
	await _drive(Vector3.FORWARD, 65)
	assert_lt(_player.position.y, 0.25)
	assert_gt(_player.position.z, -5.0)


func test_camera_follows_player_and_reset_restores_zoom() -> void:
	var rig: FollowRig = _lab.get_node("FollowRig")
	assert_eq(rig.target, _player.get_node("FollowTarget"))
	rig.toggle_framing()
	assert_almost_eq(rig.framing_size(), 9.5, 0.01)
	rig.zoom_steps(100)
	assert_almost_eq(rig.framing_size(), rig.max_size, 0.01)
	rig.zoom_steps(-100)
	assert_almost_eq(rig.framing_size(), rig.min_size, 0.01)
	await _drive(Vector3.FORWARD, 25)
	await _drive(Vector3.ZERO, 55)
	assert_lt(rig.global_position.distance_to(rig.target.global_position), 0.05)
	rig.reset_view()
	assert_eq(rig.global_position, rig.target.global_position)
	assert_almost_eq(rig.framing_size(), rig.wide_size, 0.01)


func _place(at: Vector3) -> void:
	_player.respawn(at)
	await _drive(Vector3.ZERO, 10)


func _drive(intent: Vector3, frames: int) -> void:
	for index in range(frames):
		await get_tree().physics_frame
		_player.step(intent, STEP)
