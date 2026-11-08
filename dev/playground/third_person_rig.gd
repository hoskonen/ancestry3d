extends Node3D

const MIN_ELEVATION: float = -15.0
const MAX_ELEVATION: float = 65.0
const MIN_DISTANCE: float = 2.0
const MAX_DISTANCE: float = 8.0

@export_range(-180.0, 180.0, 1.0) var start_yaw: float = 45.0
@export_range(-15.0, 65.0, 1.0) var start_elevation: float = 16.0
@export_range(2.0, 8.0, 0.1) var start_distance: float = 4.6
@export_range(15.0, 360.0, 1.0) var stick_sensitivity: float = 130.0
@export_range(0.01, 1.0, 0.01) var mouse_sensitivity: float = 0.18
@export_range(0.0, 2.0, 0.05) var height_offset: float = 0.65

var yaw_degrees: float
var elevation_degrees: float
var _target: Node3D

@onready var _arm: SpringArm3D = $SpringArm
@onready var _camera: Camera3D = $SpringArm/Camera


func bind_target(target: Node3D, actor: CollisionObject3D) -> void:
	_target = target
	_arm.clear_excluded_objects()
	_arm.add_excluded_object(actor.get_rid())
	reset_view()


func set_active(enabled: bool) -> void:
	_arm.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	if enabled:
		follow_target()
		_camera.make_current()


func follow_target() -> void:
	global_position = _target.global_position + Vector3.UP * height_offset


func heading() -> float:
	return deg_to_rad(yaw_degrees)


func orbit(delta_degrees: Vector2) -> void:
	yaw_degrees = wrapf(yaw_degrees - delta_degrees.x, -180.0, 180.0)
	elevation_degrees = clampf(elevation_degrees + delta_degrees.y, MIN_ELEVATION, MAX_ELEVATION)
	_arm.rotation_degrees = Vector3(-elevation_degrees, yaw_degrees, 0.0)


func zoom_steps(steps: float) -> void:
	_arm.spring_length = clampf(_arm.spring_length + steps * 0.5, MIN_DISTANCE, MAX_DISTANCE)


func reset_view() -> void:
	yaw_degrees = start_yaw
	elevation_degrees = start_elevation
	orbit(Vector2.ZERO)
	_arm.spring_length = clampf(start_distance, MIN_DISTANCE, MAX_DISTANCE)
	follow_target()
	reset_physics_interpolation()


func requested_distance() -> float:
	return _arm.spring_length


func obstruction_distance() -> float:
	return _arm.get_hit_length()
