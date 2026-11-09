extends CanvasLayer

const Playground = preload("playground.gd")
const CharacterMotor = preload("res://game/characters/character_motor.gd")
const FollowRig = preload("res://game/camera/orthographic_follow.gd")
const ThirdPersonRig = preload("third_person_rig.gd")
const SettlementLighting = preload("res://prototypes/camera_experiment/settlement_lighting.gd")

var _clock_notice: String = ""

@onready var _playground := get_parent() as Playground
@onready var _player: CharacterMotor = $"../Player"
@onready var _rig: FollowRig = $"../FollowRig"
@onready var _third_person: ThirdPersonRig = $"../ThirdPersonRig"
@onready var _lighting: SettlementLighting = $"../Environment/Settlement/WorldEnvironment"
@onready var _readout: Label = $Panel/Readout/Diagnostics
@onready var _animation := _player.get_node_or_null("Visual/WandererModel/AnimationPlayer") as AnimationPlayer


func _process(_delta: float) -> void:
	if not visible:
		return
	var position := _player.global_position.snapped(Vector3.ONE * 0.01)
	var state := "Grounded" if _player.is_on_floor() else "Airborne"
	var clip := String(_animation.current_animation) if is_instance_valid(_animation) else "Placeholder"
	var light := "Night" if _lighting.is_night else "Day"
	_readout.text = "%s   Position %s   Speed %.2f m/s   %s\n%s   %s\n%s" % [
		light, position, _player.actual_horizontal_speed, state, clip, _camera_readout(), _clock_readout(),
	]


func _clock_readout() -> String:
	var clock := _playground.world_clock()
	var seconds := clock.seconds_of_day()
	var status := "Paused" if clock.is_paused() else "Running"
	return "Day %d   %02d:%02d   Rate %.2f   %s%s" % [
		clock.day_index(), floori(seconds / 3600.0), floori(seconds / 60.0) % 60,
		clock.rate(), status, _clock_notice,
	]


func _camera_readout() -> String:
	if _playground.is_third_person:
		return "Third person   Arm %.1f / %.1f m   Yaw %.1f°   Elevation %.1f°" % [
			_third_person.obstruction_distance(), _third_person.requested_distance(),
			_third_person.yaw_degrees, _third_person.elevation_degrees,
		]
	return "Isometric   Size %.1f m   Yaw %.1f°   Elevation %.1f°" % [
		_rig.framing_size(), _rig.yaw_degrees, _rig.elevation_degrees,
	]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed(&"lab_reset"):
		_playground.reset_player()
	elif not _playground.is_third_person and event.is_action_pressed(&"lab_framing"):
		_rig.toggle_framing()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_N:
		_clock_notice = "" if _playground.advance_to_opposite_phase() else "   Jump rejected"
	elif event is InputEventKey and event.pressed and event.keycode == KEY_P:
		_playground.toggle_clock_pause()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_H:
		visible = not visible
	elif event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_playground.zoom_camera(-1.0)
			MOUSE_BUTTON_WHEEL_DOWN:
				_playground.zoom_camera(1.0)
			_:
				return
	else:
		return
	get_viewport().set_input_as_handled()
