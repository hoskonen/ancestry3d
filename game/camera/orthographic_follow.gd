extends Node3D

const DISTANCE: float = 28.0
const ZOOM_FACTOR: float = 1.15

@export_range(-180.0, 180.0, 0.1) var yaw_degrees: float = 45.0
@export_range(1.0, 89.0, 0.001) var elevation_degrees: float = 35.264
@export_range(0.1, 30.0, 0.1) var responsiveness: float = 9.0
@export_range(1.0, 64.0, 0.1) var wide_size: float = 17.0
@export_range(1.0, 64.0, 0.1) var close_size: float = 9.5
@export_range(1.0, 64.0, 0.1) var min_size: float = 7.0
@export_range(1.0, 64.0, 0.1) var max_size: float = 24.0

var target: Node3D

@onready var _camera: Camera3D = $Camera


func _ready() -> void:
	_camera.rotation_degrees = Vector3(-elevation_degrees, yaw_degrees, 0.0)
	_camera.position = _camera.basis.z * DISTANCE
	reset_view()


func _process(delta: float) -> void:
	if is_instance_valid(target):
		var weight := 1.0 - exp(-responsiveness * delta)
		global_position = global_position.lerp(target.global_position, weight)


func heading() -> float:
	return deg_to_rad(yaw_degrees)


func framing_size() -> float:
	return _camera.size


func zoom_steps(steps: float) -> void:
	_set_size(_camera.size * pow(ZOOM_FACTOR, steps))


func toggle_framing() -> void:
	var wide := _bounded_size(wide_size)
	var close := _bounded_size(minf(close_size, wide))
	var midpoint := (wide + close) * 0.5
	_set_size(close if _camera.size > midpoint else wide)


func reset_view() -> void:
	_set_size(wide_size)
	if is_instance_valid(target):
		global_position = target.global_position
		reset_physics_interpolation()


func _set_size(value: float) -> void:
	_camera.size = _bounded_size(value)


func _bounded_size(value: float) -> float:
	return clampf(value, min_size, maxf(min_size, max_size))
