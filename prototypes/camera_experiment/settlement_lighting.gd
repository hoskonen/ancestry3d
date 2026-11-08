extends WorldEnvironment

@export var night_environment: Environment = preload("night_environment.tres")
@export var moon_color := Color("#aabbdc")
@export var moon_energy: float = 0.15
@export var night_fire_energy: float = 3.0

var is_night: bool = false

@onready var _sun: DirectionalLight3D = $"../Sun"
@onready var _fire: OmniLight3D = $"../Courtyard/Campsite/Firelight"
@onready var _torch: OmniLight3D = $"../Courtyard/Storehouse/Torchlight"
@onready var _day_environment: Environment = environment
@onready var _day_sun_color: Color = _sun.light_color
@onready var _day_sun_energy: float = _sun.light_energy
@onready var _day_fire_energy: float = _fire.light_energy


func set_night(enabled: bool) -> void:
	if night_environment == null:
		push_error("Settlement lighting is missing its night Environment.")
		return
	is_night = enabled
	environment = night_environment if is_night else _day_environment
	_sun.light_color = moon_color if is_night else _day_sun_color
	_sun.light_energy = moon_energy if is_night else _day_sun_energy
	_fire.light_energy = night_fire_energy if is_night else _day_fire_energy
	_fire.shadow_enabled = is_night
	_torch.visible = is_night
