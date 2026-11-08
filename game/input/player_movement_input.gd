extends Node

@export_range(0.0, 0.95, 0.01) var deadzone: float = 0.2
@export var enabled: bool = true

var move_vector: Vector2 = Vector2.ZERO


func sample_intent(heading: float) -> Vector3:
	move_vector = Vector2.ZERO
	if enabled:
		move_vector = Input.get_vector(
			&"move_left", &"move_right", &"move_forward", &"move_backward", deadzone
		)
	return to_world(move_vector, heading)


static func to_world(input_vector: Vector2, heading: float) -> Vector3:
	var bounded := input_vector.limit_length()
	return Vector3(bounded.x, 0.0, bounded.y).rotated(Vector3.UP, heading)
