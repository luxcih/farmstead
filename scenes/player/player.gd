extends CharacterBody2D

@export_range(1.0, 500.0, 1.0) var move_speed: float = 100.0


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * move_speed
	move_and_slide()
