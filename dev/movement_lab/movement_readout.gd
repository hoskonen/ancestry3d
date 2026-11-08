extends CanvasLayer

const CharacterMotor = preload("res://game/characters/character_motor.gd")
const MovementInput = preload("res://game/input/player_movement_input.gd")
const FollowRig = preload("res://game/camera/orthographic_follow.gd")

@onready var _player: CharacterMotor = $"../Player"
@onready var _input: MovementInput = $"../MovementInput"
@onready var _rig: FollowRig = $"../FollowRig"
@onready var _readout: Label = $Panel/Readout/Diagnostics


func _process(_delta: float) -> void:
	if not visible:
		return
	_readout.text = "Stick %s   Requested %.2f   Actual %.2f   %s\nPosition %s   Camera %.1f" % [
		_input.move_vector.snapped(Vector2(0.01, 0.01)),
		_player.requested_speed,
		_player.actual_horizontal_speed,
		"Grounded" if _player.is_on_floor() else "Airborne",
		_player.global_position.snapped(Vector3(0.01, 0.01, 0.01)),
		_rig.framing_size(),
	]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.physical_keycode == KEY_H and event.pressed and not event.echo:
		visible = not visible
		get_viewport().set_input_as_handled()
