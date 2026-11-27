extends Node2D

@export var world_size := Vector2(640.0, 480.0)
@export_range(8, 64, 8) var ground_cell_size: int = 32


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var top_left := -world_size * 0.5
	draw_rect(Rect2(top_left, world_size), Color("#263b2b"))

	var random := RandomNumberGenerator.new()
	random.seed = 421337

	var columns := ceili(world_size.x / float(ground_cell_size))
	var rows := ceili(world_size.y / float(ground_cell_size))

	for y in range(rows):
		for x in range(columns):
			if random.randf() < 0.22:
				var cell_position := top_left + Vector2(
					x * ground_cell_size,
					y * ground_cell_size
				)
				var alpha := random.randf_range(0.035, 0.085)
				var patch_color := Color(0.48, 0.60, 0.38, alpha)
				draw_rect(
					Rect2(cell_position, Vector2.ONE * ground_cell_size),
					patch_color
				)

	draw_rect(Rect2(top_left, world_size), Color("#17271b"), false, 3.0)
