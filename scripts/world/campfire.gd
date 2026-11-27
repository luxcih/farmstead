extends StaticBody2D


func _ready() -> void:
	add_to_group("campfires")
	collision_layer = 4
	collision_mask = 0
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2(0.0, 2.0), 18.0, Color(0.06, 0.08, 0.05, 0.30))
	draw_rect(Rect2(-13.0, -2.0, 26.0, 5.0), Color(0.30, 0.17, 0.10))
	draw_rect(Rect2(-10.0, -6.0, 20.0, 5.0), Color(0.42, 0.24, 0.13))
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-7.0, -4.0),
			Vector2(-4.0, -17.0),
			Vector2(0.0, -10.0),
			Vector2(5.0, -19.0),
			Vector2(8.0, -4.0),
			Vector2(4.0, 2.0),
			Vector2(-4.0, 2.0),
		]),
		Color(0.91, 0.38, 0.13)
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-3.0, -3.0),
			Vector2(0.0, -12.0),
			Vector2(4.0, -3.0),
			Vector2(2.0, 1.0),
			Vector2(-2.0, 1.0),
		]),
		Color(1.0, 0.75, 0.29)
	)
	draw_rect(Rect2(-15.0, -1.0, 4.0, 4.0), Color(0.48, 0.50, 0.44))
	draw_rect(Rect2(11.0, -1.0, 4.0, 4.0), Color(0.48, 0.50, 0.44))
