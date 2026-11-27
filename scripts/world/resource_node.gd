extends StaticBody2D

@export_enum("tree", "rock", "berry_bush") var resource_kind: String = "tree"

var _harvested: bool = false


func _ready() -> void:
	add_to_group("harvestable")
	collision_layer = 2
	collision_mask = 0
	queue_redraw()


func harvest() -> Dictionary:
	if _harvested:
		return {}

	_harvested = true
	queue_free()

	match resource_kind:
		"tree":
			return {"wood": randi_range(2, 4)}
		"rock":
			return {"stone": randi_range(1, 3)}
		_:
			return {"berries": randi_range(2, 3)}


func _draw() -> void:
	match resource_kind:
		"tree":
			draw_rect(Rect2(-4.0, 0.0, 8.0, 13.0), Color(0.38, 0.23, 0.13))
			draw_rect(Rect2(-12.0, -14.0, 24.0, 21.0), Color(0.13, 0.36, 0.19))
			draw_rect(Rect2(-8.0, -20.0, 16.0, 9.0), Color(0.19, 0.46, 0.23))
			draw_rect(Rect2(-8.0, -10.0, 5.0, 4.0), Color(0.27, 0.55, 0.27))
		"rock":
			var rock_points := PackedVector2Array([
				Vector2(-11.0, 5.0),
				Vector2(-8.0, -7.0),
				Vector2(1.0, -12.0),
				Vector2(10.0, -5.0),
				Vector2(12.0, 5.0),
				Vector2(4.0, 10.0),
				Vector2(-7.0, 10.0),
			])
			draw_colored_polygon(rock_points, Color(0.43, 0.47, 0.43))
			draw_rect(Rect2(-5.0, -5.0, 5.0, 3.0), Color(0.64, 0.68, 0.62))
		"berry_bush":
			draw_circle(Vector2(-5.0, 1.0), 8.0, Color(0.20, 0.40, 0.20))
			draw_circle(Vector2(5.0, 0.0), 8.0, Color(0.25, 0.48, 0.22))
			draw_circle(Vector2(0.0, -5.0), 8.0, Color(0.29, 0.52, 0.24))
			draw_rect(Rect2(-6.0, -5.0, 3.0, 3.0), Color(0.78, 0.22, 0.30))
			draw_rect(Rect2(3.0, -1.0, 3.0, 3.0), Color(0.78, 0.22, 0.30))
			draw_rect(Rect2(0.0, 3.0, 3.0, 3.0), Color(0.78, 0.22, 0.30))
