extends CharacterBody3D

@export_range(0.1, 20.0, 0.1) var max_speed: float = 4.2
@export_range(0.1, 80.0, 0.1) var acceleration: float = 18.0
@export_range(0.1, 80.0, 0.1) var braking: float = 24.0
@export_range(0.1, 40.0, 0.1) var gravity: float = 19.0
@export_range(0.1, 40.0, 0.1) var turn_speed: float = 12.0

var requested_speed: float = 0.0
var actual_horizontal_speed: float = 0.0

@onready var _visual: Node3D = $Visual


## Called once per physics tick by the owning scene. Intent is a world-space XZ vector.
func step(intent: Vector3, delta: float) -> void:
	var planar_intent := Vector3(intent.x, 0.0, intent.z).limit_length()
	var target_velocity := planar_intent * max_speed
	requested_speed = target_velocity.length()
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	horizontal = approach_velocity(horizontal, target_velocity, acceleration, braking, delta)
	velocity = Vector3(horizontal.x, velocity.y - gravity * delta, horizontal.z)
	move_and_slide()

	var resolved := get_real_velocity()
	actual_horizontal_speed = Vector2(resolved.x, resolved.z).length()
	if not planar_intent.is_zero_approx():
		_visual.global_rotation.y = next_facing(
			_visual.global_rotation.y, planar_intent, turn_speed * delta
		)


func respawn(at: Vector3) -> void:
	global_position = at
	velocity = Vector3.ZERO
	requested_speed = 0.0
	actual_horizontal_speed = 0.0
	_visual.rotation.y = 0.0
	reset_physics_interpolation()


static func approach_velocity(
	current: Vector3, desired: Vector3, drive: float, brake: float, delta: float
) -> Vector3:
	var rate := brake if desired.is_zero_approx() else drive
	return current.move_toward(desired, rate * delta)


static func next_facing(current_yaw: float, intent: Vector3, max_turn: float) -> float:
	if intent.is_zero_approx():
		return current_yaw
	return rotate_toward(current_yaw, atan2(-intent.x, -intent.z), max_turn)
