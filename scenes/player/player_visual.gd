class_name PlayerVisual
extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	sprite.play(&"idle")


func update_motion(movement_direction: Vector2, facing_direction: Vector2) -> void:
	var next_animation: StringName

	if movement_direction.is_zero_approx():
		next_animation = &"idle_back" if facing_direction.y < 0.0 else &"idle"
	else:
		var direction := _get_cardinal_direction(movement_direction)

		if direction.y < 0.0:
			next_animation = &"run_back"
		elif direction.x < 0.0:
			next_animation = &"run_left"
		elif direction.x > 0.0:
			next_animation = &"run_right"
		else:
			# The supplied sprite pack has no down-facing run cycle yet.
			next_animation = &"idle"

	if sprite.animation != next_animation:
		sprite.play(next_animation)


func _get_cardinal_direction(direction: Vector2) -> Vector2:
	if absf(direction.x) > absf(direction.y):
		return Vector2(signf(direction.x), 0.0)

	return Vector2(0.0, signf(direction.y))
