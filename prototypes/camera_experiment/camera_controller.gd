extends Node3D

const PRESET_NAMES: Array[String] = [
	"A  Top-down", "B  Angled orthographic", "C  Isometric",
]
const DEFAULT_PRESET: int = 1
const ISOMETRIC_PRESET: int = 2
const DEFAULT_TARGET := Vector3(-0.5, 0.0, -1.0)
const CAMERA_DISTANCE: float = 32.0
const ZOOM_STEP: float = 1.15
const PAN_FRACTION_PER_SECOND: float = 0.55
const PAN_LIMIT: float = 15.0
const FRAMING_BLEND_SECONDS: float = 0.35

@export_group("Preset Angles")
## Elevation below horizontal (X) and horizontal rotation (Y), in degrees.
@export var top_down_angles := Vector2(86.0, 0.0)
@export var angled_angles := Vector2(48.0, 10.0)
@export var isometric_angles := Vector2(35.264, 45.0)

@export_group("Shared Framing")
@export_range(1.0, 64.0, 0.1) var default_size: float = 17.0
@export_range(1.0, 64.0, 0.1) var min_zoom_size: float = 7.0
@export_range(1.0, 64.0, 0.1) var max_zoom_size: float = 34.0
## Added to the reset target for all three presets.
@export var target_offset := Vector3(0.0, 0.25, 0.0)
@export_range(1.0, 64.0, 0.1) var close_isometric_size: float = 9.5

@export_group("Lighting Comparison")
@export var night_environment: Environment = preload("night_environment.tres")
@export var moon_color := Color("#aabbdc")
@export var moon_energy: float = 0.15
@export var night_fire_energy: float = 3.0

var _target: Vector3 = DEFAULT_TARGET
var _preset: int = DEFAULT_PRESET
var _night: bool = false
var _framing_tween: Tween
var _framing_goal: float

@onready var _camera: Camera3D = $Camera
@onready var _preset_label: Label = $Overlay/Panel/Readout/Preset
@onready var _camp_focus: Marker3D = $Courtyard/Campsite/CameraFocus
@onready var _world: WorldEnvironment = $WorldEnvironment
@onready var _sun: DirectionalLight3D = $Sun
@onready var _fire: OmniLight3D = $Courtyard/Campsite/Firelight
@onready var _torch: OmniLight3D = $Courtyard/Storehouse/Torchlight
@onready var _day_environment: Environment = _world.environment
@onready var _day_sun_color: Color = _sun.light_color
@onready var _day_sun_energy: float = _sun.light_energy
@onready var _day_fire_energy: float = _fire.light_energy


func _ready() -> void:
	_reset_view()


func _process(delta: float) -> void:
	var direction := Vector2(
		float(_pan_key(KEY_D, KEY_RIGHT)) - float(_pan_key(KEY_A, KEY_LEFT)),
		float(_pan_key(KEY_S, KEY_DOWN)) - float(_pan_key(KEY_W, KEY_UP))
	)
	if direction.is_zero_approx():
		return

	# Rotate screen-relative motion onto the ground without shortening it at shallow pitches.
	direction = direction.normalized()
	var ground_motion := Vector3(direction.x, 0.0, direction.y)
	var yaw := _camera.rotation.y
	_target += ground_motion.rotated(Vector3.UP, yaw) * _camera.size * PAN_FRACTION_PER_SECOND * delta
	_target.x = clampf(_target.x, -PAN_LIMIT, PAN_LIMIT)
	_target.z = clampf(_target.z, -PAN_LIMIT, PAN_LIMIT)
	_update_camera()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_select_preset(0)
			KEY_2:
				_select_preset(1)
			KEY_3:
				_select_preset(ISOMETRIC_PRESET)
			KEY_4:
				_toggle_isometric_framing()
			KEY_F:
				_target = to_local(_camp_focus.global_position)
				_update_camera()
			KEY_N:
				_set_night(not _night)
			KEY_R:
				_reset_view()
			_:
				return
	elif event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_zoom(1.0 / ZOOM_STEP)
			MOUSE_BUTTON_WHEEL_DOWN:
				_zoom(ZOOM_STEP)
			_:
				return
	else:
		return
	get_viewport().set_input_as_handled()


func _pan_key(letter: Key, arrow: Key) -> bool:
	return Input.is_key_pressed(letter) or Input.is_key_pressed(arrow)


func _select_preset(index: int) -> void:
	_preset = index
	_update_readout()
	var angles: Vector2 = [top_down_angles, angled_angles, isometric_angles][index]
	_camera.rotation_degrees = Vector3(-angles.x, angles.y, 0.0)
	_update_camera()


func _reset_view() -> void:
	_target = DEFAULT_TARGET
	_stop_framing_blend()
	_camera.size = _bounded_size(default_size)
	_select_preset(DEFAULT_PRESET)


func _zoom(factor: float) -> void:
	_stop_framing_blend()
	_camera.size = _bounded_size(_camera.size * factor)


func _toggle_isometric_framing() -> void:
	_select_preset(ISOMETRIC_PRESET)
	var wide := _bounded_size(default_size)
	var close := _bounded_size(minf(close_isometric_size, wide))
	var reference := _camera.size
	if _framing_tween != null and _framing_tween.is_running():
		reference = _framing_goal
	_stop_framing_blend()
	_framing_goal = close if reference > (wide + close) * 0.5 else wide
	_framing_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_framing_tween.tween_property(_camera, "size", _framing_goal, FRAMING_BLEND_SECONDS)


func _stop_framing_blend() -> void:
	if _framing_tween != null:
		_framing_tween.kill()
		_framing_tween = null


func _set_night(enabled: bool) -> void:
	if night_environment == null:
		push_error("Camera experiment is missing its night Environment.")
		return
	_night = enabled
	_world.environment = night_environment if _night else _day_environment
	_sun.light_color = moon_color if _night else _day_sun_color
	_sun.light_energy = moon_energy if _night else _day_sun_energy
	_fire.light_energy = night_fire_energy if _night else _day_fire_energy
	_fire.shadow_enabled = _night
	_torch.visible = _night
	_update_readout()


func _update_readout() -> void:
	_preset_label.text = "%s  |  %s" % [PRESET_NAMES[_preset], "Night" if _night else "Day"]


func _bounded_size(size: float) -> float:
	return clampf(size, min_zoom_size, maxf(min_zoom_size, max_zoom_size))


func _update_camera() -> void:
	_camera.position = _target + target_offset + _camera.basis.z * CAMERA_DISTANCE
