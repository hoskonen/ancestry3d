extends Node3D

const CharacterMotor = preload("res://game/characters/character_motor.gd")
const MODEL = preload("res://assets/characters/weary_wanderer/weary_wanderer_animated.glb")
const IDLE: StringName = &"Idle_02"
const WALK: StringName = &"Walking"
const RUN: StringName = &"Running"
const REST_SPEED: float = 0.12
const RUN_ENTER_SPEED: float = 3.4
const RUN_EXIT_SPEED: float = 3.15
const WALK_REFERENCE_SPEED: float = 2.0
const RUN_REFERENCE_SPEED: float = 4.2
const BLEND_SECONDS: float = 0.16

@export var use_placeholder: bool = false

var _animation: AnimationPlayer
var _current_clip: StringName

@onready var _motor := get_parent() as CharacterMotor


func _ready() -> void:
	if use_placeholder:
		set_process(false)
		return

	var model := MODEL.instantiate() as Node3D
	var players := model.find_children("*", "AnimationPlayer", true, false)
	if not players.is_empty():
		_animation = players[0] as AnimationPlayer
	if _animation == null or not _animation.has_animation(IDLE) \
			or not _animation.has_animation(WALK) or not _animation.has_animation(RUN):
		push_error("Weary Wanderer import is missing Idle_02, Walking, or Running.")
		model.free()
		set_process(false)
		return

	for child in get_children():
		if child is MeshInstance3D:
			child.hide()
	model.name = "WandererModel"
	# The imported model faces +Z. The motor turns the visual pivot toward -Z.
	model.rotation.y = PI
	add_child(model)
	_play_clip(IDLE, 1.0)
	set_process(_motor != null)


func _process(_delta: float) -> void:
	var speed := _motor.actual_horizontal_speed
	if speed < REST_SPEED or not _motor.is_on_floor():
		_play_clip(IDLE, 1.0)
		return

	var run_threshold := RUN_EXIT_SPEED if _current_clip == RUN else RUN_ENTER_SPEED
	var next_clip := RUN if speed >= run_threshold else WALK
	var reference := RUN_REFERENCE_SPEED if next_clip == RUN else WALK_REFERENCE_SPEED
	_play_clip(next_clip, clampf(speed / reference, 0.45, 1.65))


func _play_clip(clip: StringName, playback_rate: float) -> void:
	_animation.speed_scale = playback_rate
	if clip != _current_clip:
		_animation.play(clip, BLEND_SECONDS)
		_current_clip = clip
