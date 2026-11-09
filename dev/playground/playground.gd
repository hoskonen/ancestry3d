extends Node3D

const CharacterMotor = preload("res://game/characters/character_motor.gd")
const MovementInput = preload("res://game/input/player_movement_input.gd")
const FollowRig = preload("res://game/camera/orthographic_follow.gd")
const ThirdPersonRig = preload("third_person_rig.gd")
const WorldClock = preload("res://game/world_time/world_clock.gd")
const SettlementLighting = preload("res://prototypes/camera_experiment/settlement_lighting.gd")
const RESET_FLOOR: float = -8.0
const ORBIT_DEADZONE: float = 0.22
const DAWN: float = 6.0 * WorldClock.SECONDS_PER_HOUR
const DUSK: float = 18.0 * WorldClock.SECONDS_PER_HOUR
const MORNING_JUMP: float = 9.0 * WorldClock.SECONDS_PER_HOUR
const NIGHT_JUMP: float = 21.0 * WorldClock.SECONDS_PER_HOUR

@export_range(0.01, 3600.0, 0.01) var initial_clock_rate: float = 60.0

var is_third_person: bool = false
var _clock := WorldClock.new()

@onready var _player: CharacterMotor = $Player
@onready var _input: MovementInput = $MovementInput
@onready var _rig: FollowRig = $FollowRig
@onready var _isometric_camera: Camera3D = $FollowRig/Camera
@onready var _third_person: ThirdPersonRig = $ThirdPersonRig
@onready var _spawn: Marker3D = $Spawn
@onready var _lighting: SettlementLighting = $Environment/Settlement/WorldEnvironment


func _ready() -> void:
	if not _clock.advanced.is_connected(_on_clock_advanced):
		if not _clock.set_rate(initial_clock_rate):
			push_error("Invalid playground clock rate.")
		_clock.advance_seconds(MORNING_JUMP)
		_clock.advanced.connect(_on_clock_advanced)
	_sync_lighting(_clock.elapsed_seconds())
	_rig.target = $Player/FollowTarget
	_third_person.bind_target(_rig.target, _player)
	_third_person.set_active(false)
	reset_player()


func _physics_process(delta: float) -> void:
	_clock.step(delta)
	if _player.global_position.y < RESET_FLOOR:
		reset_player()
		return
	if is_third_person:
		var orbit_input := Input.get_vector(
			&"playground_look_left", &"playground_look_right",
			&"playground_look_up", &"playground_look_down", ORBIT_DEADZONE
		)
		if not orbit_input.is_zero_approx():
			_third_person.orbit(orbit_input * _third_person.stick_sensitivity * delta)
	_player.step(_input.sample_intent(camera_heading()), delta)
	if is_third_person:
		_third_person.follow_target()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"playground_camera_mode") and not event.is_echo():
		switch_camera()
	elif is_third_person and event is InputEventMouseMotion \
			and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		_third_person.orbit(event.screen_relative * _third_person.mouse_sensitivity)
	else:
		return
	get_viewport().set_input_as_handled()


func switch_camera() -> void:
	is_third_person = not is_third_person
	_third_person.set_active(is_third_person)
	if not is_third_person:
		_isometric_camera.make_current()


func camera_heading() -> float:
	return _third_person.heading() if is_third_person else _rig.heading()


func zoom_camera(steps: float) -> void:
	if is_third_person:
		_third_person.zoom_steps(steps)
	else:
		_rig.zoom_steps(steps)


func reset_player() -> void:
	_player.respawn(_spawn.global_position)
	_rig.reset_view()
	_rig.toggle_framing()
	_third_person.reset_view()


func world_clock() -> WorldClock:
	return _clock


func toggle_clock_pause() -> void:
	_clock.set_paused(not _clock.is_paused())


func advance_to_opposite_phase() -> bool:
	var local_seconds := _clock.seconds_of_day()
	if local_seconds >= DAWN and local_seconds < DUSK:
		return _clock.advance_seconds(NIGHT_JUMP - local_seconds)
	var seconds_to_morning := MORNING_JUMP - local_seconds
	if seconds_to_morning <= 0.0:
		seconds_to_morning += WorldClock.SECONDS_PER_DAY
	return _clock.advance_seconds(seconds_to_morning)


func _on_clock_advanced(_previous_seconds: float, current_seconds: float) -> void:
	_sync_lighting(current_seconds)


func _sync_lighting(elapsed_seconds: float) -> void:
	var local_seconds := fposmod(elapsed_seconds, WorldClock.SECONDS_PER_DAY)
	var night := local_seconds < DAWN or local_seconds >= DUSK
	if _lighting.is_night != night:
		_lighting.set_night(night)
