extends Node3D

const CharacterMotor = preload("res://game/characters/character_motor.gd")
const MovementInput = preload("res://game/input/player_movement_input.gd")
const FollowRig = preload("res://game/camera/orthographic_follow.gd")
const RESET_FLOOR: float = -8.0

@onready var _player: CharacterMotor = $Player
@onready var _input: MovementInput = $MovementInput
@onready var _rig: FollowRig = $FollowRig
@onready var _spawn: Marker3D = $Spawn


func _ready() -> void:
	_rig.target = $Player/FollowTarget
	_reset_course()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&"lab_reset") or _player.global_position.y < RESET_FLOOR:
		_reset_course()
		return
	_player.step(_input.sample_intent(_rig.heading()), delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"lab_framing") and not event.is_echo():
		_rig.toggle_framing()
	elif event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_rig.zoom_steps(-1.0)
			MOUSE_BUTTON_WHEEL_DOWN:
				_rig.zoom_steps(1.0)
			_:
				return
	else:
		return
	get_viewport().set_input_as_handled()


func _reset_course() -> void:
	_player.respawn(_spawn.global_position)
	_rig.reset_view()
