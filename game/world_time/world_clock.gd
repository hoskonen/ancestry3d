extends RefCounted

## The elapsed interval includes the endpoint and excludes the start.
signal advanced(previous_seconds: float, current_seconds: float)

const SECONDS_PER_HOUR: float = 3600.0
const SECONDS_PER_DAY: float = 86400.0
const MAX_ELAPSED_SECONDS: float = 1099511627776.0
const MIN_RATE: float = 0.01
const MAX_RATE: float = 3600.0

var _elapsed: float = 0.0
var _rate: float = 1.0
var _paused: bool = false
var _notifying: bool = false


func elapsed_seconds() -> float:
	return _elapsed


func day_index() -> int:
	return floori(_elapsed / SECONDS_PER_DAY)


func seconds_of_day() -> float:
	return _elapsed - day_index() * SECONDS_PER_DAY


func rate() -> float:
	return _rate


func is_paused() -> bool:
	return _paused


func set_rate(game_seconds_per_engine_second: float) -> bool:
	if _notifying or not is_finite(game_seconds_per_engine_second) \
			or game_seconds_per_engine_second < MIN_RATE or game_seconds_per_engine_second > MAX_RATE:
		return false
	_rate = game_seconds_per_engine_second
	return true


func set_paused(paused: bool) -> bool:
	if _notifying:
		return false
	_paused = paused
	return true


func step(engine_delta_seconds: float) -> bool:
	if _notifying or not is_finite(engine_delta_seconds) or engine_delta_seconds < 0.0:
		return false
	if _paused or engine_delta_seconds == 0.0:
		return true
	var game_seconds := engine_delta_seconds * _rate
	return game_seconds > 0.0 and advance_seconds(game_seconds)


func advance_seconds(game_seconds: float) -> bool:
	if _notifying or not is_finite(game_seconds) or game_seconds < 0.0:
		return false
	if game_seconds == 0.0:
		return true
	var endpoint := _elapsed + game_seconds
	if not is_finite(endpoint) or endpoint > MAX_ELAPSED_SECONDS or endpoint <= _elapsed:
		return false

	var previous := _elapsed
	_elapsed = endpoint
	_notifying = true
	advanced.emit(previous, endpoint)
	_notifying = false
	return true
