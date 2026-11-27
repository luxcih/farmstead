extends CharacterBody2D

@export_range(1.0, 500.0, 1.0) var move_speed: float = 120.0

@onready var visual: PlayerVisual = $Visual

var facing_direction := Vector2.DOWN


func _physics_process(_delta: float) -> void:
	var move_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	if not move_direction.is_zero_approx():
		facing_direction = _get_cardinal_direction(move_direction)

	velocity = move_direction * move_speed
	move_and_slide()

	visual.update_motion(move_direction, facing_direction)


func _get_cardinal_direction(direction: Vector2) -> Vector2:
	if absf(direction.x) > absf(direction.y):
		return Vector2(signf(direction.x), 0.0)

	return Vector2(0.0, signf(direction.y))
