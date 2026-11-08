extends "res://addons/gut/test.gd"

const MovementInput = preload("res://game/input/player_movement_input.gd")
const Motor = preload("res://game/characters/character_motor.gd")


func test_cardinal_input_maps_to_world_axes_at_zero_heading() -> void:
	assert_eq(MovementInput.to_world(Vector2.UP, 0.0), Vector3.FORWARD)
	assert_eq(MovementInput.to_world(Vector2.RIGHT, 0.0), Vector3.RIGHT)
	assert_eq(MovementInput.to_world(Vector2.DOWN, 0.0), Vector3.BACK)
	assert_eq(MovementInput.to_world(Vector2.LEFT, 0.0), Vector3.LEFT)


func test_diagonal_input_has_unit_length() -> void:
	assert_almost_eq(MovementInput.to_world(Vector2(1, -1), 0.0).length(), 1.0, 0.001)


func test_camera_relative_input_preserves_analog_magnitude() -> void:
	var intent := MovementInput.to_world(Vector2(0.0, -0.4), PI / 4.0)
	assert_almost_eq(intent, Vector3(-1, 0, -1).normalized() * 0.4, Vector3.ONE * 0.001)


func test_zero_input_stays_zero() -> void:
	assert_eq(MovementInput.to_world(Vector2.ZERO, PI / 4.0), Vector3.ZERO)


func test_disabled_input_ignores_a_pressed_action() -> void:
	var adapter := MovementInput.new()
	autofree(adapter)
	Input.action_press(&"move_right")
	var active := adapter.sample_intent(0.0)
	adapter.enabled = false
	var disabled := adapter.sample_intent(0.0)
	Input.action_release(&"move_right")
	assert_eq(active, Vector3.RIGHT)
	assert_eq(disabled, Vector3.ZERO)
	assert_eq(adapter.move_vector, Vector2.ZERO)


func test_velocity_uses_distinct_acceleration_and_braking_rates() -> void:
	var desired := Vector3(4, 0, 0)
	assert_eq(Motor.approach_velocity(Vector3.ZERO, desired, 10, 20, 0.1), Vector3.RIGHT)
	assert_eq(Motor.approach_velocity(desired, Vector3.ZERO, 10, 20, 0.1), Vector3(2, 0, 0))
	assert_eq(Motor.approach_velocity(Vector3.RIGHT, Vector3.ZERO, 10, 20, 0.1), Vector3.ZERO)


func test_facing_turns_by_at_most_the_step_and_holds_at_idle() -> void:
	assert_almost_eq(Motor.next_facing(0.0, Vector3.RIGHT, 0.2), -0.2, 0.001)
	assert_almost_eq(Motor.next_facing(0.0, Vector3.RIGHT, PI), -PI / 2.0, 0.001)
	assert_eq(Motor.next_facing(0.6, Vector3.ZERO, 0.2), 0.6)
