extends "res://addons/gut/test.gd"

const WorldClock = preload("res://game/world_time/world_clock.gd")

var _clock: WorldClock
var _intervals: Array[Vector2]


func before_each() -> void:
	_clock = WorldClock.new()
	_intervals = []
	_clock.advanced.connect(func(start: float, endpoint: float) -> void:
		_intervals.append(Vector2(start, endpoint))
	)


func test_step_applies_rate_and_reports_interval() -> void:
	assert_eq(_clock.elapsed_seconds(), 0.0)
	assert_eq(_clock.rate(), 1.0)
	assert_false(_clock.is_paused())
	assert_true(_clock.set_rate(60.0))
	assert_true(_clock.step(0.5))
	assert_true(_clock.set_rate(120.0))
	assert_true(_clock.step(0.5))
	assert_eq(_clock.elapsed_seconds(), 90.0)
	assert_eq(_intervals, [Vector2(0, 30), Vector2(30, 90)])


func test_manual_advance_ignores_pause_and_rate() -> void:
	assert_true(_clock.set_rate(60.0))
	assert_true(_clock.set_paused(true))
	assert_true(_clock.step(1.0))
	assert_eq(_clock.elapsed_seconds(), 0.0)
	assert_true(_clock.advance_seconds(3600.0))
	assert_true(_clock.is_paused())
	assert_true(_clock.set_paused(false))
	assert_eq(_clock.elapsed_seconds(), 3600.0)
	assert_true(_clock.step(0.5))
	assert_eq(_intervals, [Vector2(0, 3600), Vector2(3600, 3630)])


func test_invalid_and_zero_updates_leave_clock_unchanged() -> void:
	for invalid: float in [-1.0, INF, NAN]:
		assert_false(_clock.step(invalid))
		assert_false(_clock.advance_seconds(invalid))
		assert_false(_clock.set_rate(invalid))
	assert_false(_clock.set_rate(0.009))
	assert_false(_clock.set_rate(3600.01))
	assert_true(_clock.set_rate(0.01))
	assert_true(_clock.set_rate(3600.0))
	assert_false(_clock.step(1.0e308))
	assert_true(_clock.step(0.0))
	assert_true(_clock.advance_seconds(0.0))
	assert_eq(_clock.elapsed_seconds(), 0.0)
	assert_eq(_clock.rate(), 3600.0)
	assert_true(_intervals.is_empty())


func test_maximum_and_rounding_rejection_are_atomic() -> void:
	assert_true(_clock.advance_seconds(WorldClock.MAX_ELAPSED_SECONDS))
	assert_false(_clock.advance_seconds(1.0))
	assert_false(_clock.advance_seconds(1.0e-6))
	assert_eq(_clock.elapsed_seconds(), WorldClock.MAX_ELAPSED_SECONDS)
	assert_eq(_intervals.size(), 1)


func test_exact_midnight_is_the_start_of_the_next_day() -> void:
	assert_true(_clock.advance_seconds(86399.0))
	assert_eq(_clock.day_index(), 0)
	assert_eq(_clock.seconds_of_day(), 86399.0)
	assert_true(_clock.advance_seconds(1.0))
	assert_eq(_clock.day_index(), 1)
	assert_eq(_clock.seconds_of_day(), 0.0)
	assert_eq(_intervals.back(), Vector2(86399, 86400))
	assert_true(_clock.advance_seconds(1.0))
	assert_eq(_clock.day_index(), 1)
	assert_eq(_clock.seconds_of_day(), 1.0)


func test_multi_day_jump_notifies_once_after_commit() -> void:
	assert_true(_clock.advance_seconds(84600.0))
	_intervals.clear()
	_clock.advanced.connect(func(start: float, endpoint: float) -> void:
		assert_eq(_clock.elapsed_seconds(), endpoint)
		assert_eq(floori(endpoint / 3600.0) - floori(start / 3600.0), 26)
		assert_eq(floori(endpoint / 86400.0) - floori(start / 86400.0), 2)
	)
	assert_true(_clock.advance_seconds(91800.0))
	assert_eq(_clock.day_index(), 2)
	assert_eq(_clock.seconds_of_day(), 3600.0)
	assert_eq(_intervals, [Vector2(84600, 176400)])


func test_listener_cannot_mutate_time_rate_or_pause() -> void:
	_clock.advanced.connect(func(_start: float, _endpoint: float) -> void:
		assert_false(_clock.advance_seconds(1.0))
		assert_false(_clock.step(1.0))
		assert_false(_clock.set_rate(2.0))
		assert_false(_clock.set_paused(true))
	)
	assert_true(_clock.advance_seconds(7.0))
	assert_eq(_clock.elapsed_seconds(), 7.0)
	assert_eq(_clock.rate(), 1.0)
	assert_false(_clock.is_paused())
	assert_eq(_intervals, [Vector2(0, 7)])
