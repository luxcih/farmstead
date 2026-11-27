extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const RESOURCE_SCENE: PackedScene = preload("res://scenes/world/resource_node.tscn")

const TILE_SIZE: int = 32
const WORLD_HALF_SIZE: Vector2 = Vector2(768.0, 576.0)
const DAY_LENGTH: float = 240.0

@onready var hud: CanvasLayer = $HUD
@onready var canvas_modulate: CanvasModulate = $CanvasModulate

var _player: CharacterBody2D
var _elapsed_time: float = 0.0
var _last_displayed_day: int = 1
var _last_displayed_phase: String = "Morning"


func _ready() -> void:
	y_sort_enabled = true
	_spawn_resources()
	_create_world_boundary()
	_spawn_player()
	hud.connect("restart_requested", _restart_world)
	hud.connect("menu_requested", _return_to_menu)
	hud.call("update_clock", 1, "Morning")


func _process(delta: float) -> void:
	_elapsed_time += delta

	var day_progress: float = fposmod(_elapsed_time, DAY_LENGTH) / DAY_LENGTH
	var day_number: int = int(_elapsed_time / DAY_LENGTH) + 1
	var daylight: float = 0.5 + 0.5 * sin(day_progress * TAU - PI * 0.5)
	canvas_modulate.color = Color(
		1.0,
		lerpf(0.78, 1.0, daylight),
		lerpf(0.72, 1.0, daylight),
		1.0
	)

	var phase := "Morning"
	if day_progress >= 0.25 and day_progress < 0.5:
		phase = "Afternoon"
	elif day_progress >= 0.5 and day_progress < 0.75:
		phase = "Evening"
	elif day_progress >= 0.75:
		phase = "Night"

	if day_number != _last_displayed_day or phase != _last_displayed_phase:
		_last_displayed_day = day_number
		_last_displayed_phase = phase
		hud.call("update_clock", day_number, phase)


func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 73021

	var grass_colors: Array[Color] = [
		Color(0.25, 0.43, 0.27),
		Color(0.27, 0.46, 0.29),
		Color(0.23, 0.40, 0.25),
		Color(0.29, 0.45, 0.28),
	]
	var path_colors: Array[Color] = [
		Color(0.43, 0.34, 0.23),
		Color(0.46, 0.37, 0.25),
		Color(0.40, 0.32, 0.22),
	]

	for y in range(-int(WORLD_HALF_SIZE.y), int(WORLD_HALF_SIZE.y), TILE_SIZE):
		for x in range(-int(WORLD_HALF_SIZE.x), int(WORLD_HALF_SIZE.x), TILE_SIZE):
			var on_path := absf(float(y) + 16.0 - (sin(float(x) / 170.0) * 24.0 + 112.0)) < 17.0
			var tile_color: Color
			if on_path:
				tile_color = path_colors[rng.randi_range(0, path_colors.size() - 1)]
			else:
				tile_color = grass_colors[rng.randi_range(0, grass_colors.size() - 1)]

			draw_rect(Rect2(Vector2(x, y), Vector2(TILE_SIZE, TILE_SIZE)), tile_color)

			if not on_path and rng.randf() < 0.14:
				var detail_position := Vector2(
					float(x + rng.randi_range(5, 26)),
					float(y + rng.randi_range(5, 26))
				)
				draw_rect(Rect2(detail_position, Vector2(2.0, 2.0)), Color(0.35, 0.52, 0.30))

	draw_rect(
		Rect2(-WORLD_HALF_SIZE, WORLD_HALF_SIZE * 2.0),
		Color(0.12, 0.22, 0.14),
		false,
		10.0
	)


func _spawn_player() -> void:
	_player = PLAYER_SCENE.instantiate() as CharacterBody2D
	_player.position = Vector2.ZERO
	add_child(_player)

	_player.connect("stats_changed", Callable(hud, "update_stats"))
	_player.connect("message_changed", Callable(hud, "show_message"))
	_player.connect("player_died", Callable(hud, "show_game_over"))
	hud.call("update_stats", 100.0, 82.0, {"wood": 0, "stone": 0, "berries": 0})
	_player.call("publish_stats")


func _spawn_resources() -> void:
	var placements: Array[Dictionary] = [
		{"kind": "tree", "position": Vector2(-116, -82)},
		{"kind": "tree", "position": Vector2(145, -175)},
		{"kind": "tree", "position": Vector2(300, 42)},
		{"kind": "tree", "position": Vector2(-310, 205)},
		{"kind": "tree", "position": Vector2(430, 275)},
		{"kind": "tree", "position": Vector2(-430, -260)},
		{"kind": "rock", "position": Vector2(230, -28)},
		{"kind": "rock", "position": Vector2(-245, -185)},
		{"kind": "rock", "position": Vector2(390, -215)},
		{"kind": "rock", "position": Vector2(-440, 120)},
		{"kind": "berry_bush", "position": Vector2(-72, 105)},
		{"kind": "berry_bush", "position": Vector2(78, 124)},
		{"kind": "berry_bush", "position": Vector2(190, 260)},
		{"kind": "berry_bush", "position": Vector2(-345, -25)},
	]

	for placement in placements:
		var resource := RESOURCE_SCENE.instantiate() as StaticBody2D
		resource.set("resource_kind", placement["kind"])
		resource.position = placement["position"]
		add_child(resource)


func _create_world_boundary() -> void:
	_add_wall(Vector2(0.0, -WORLD_HALF_SIZE.y - 16.0), Vector2(WORLD_HALF_SIZE.x * 2.0 + 64.0, 32.0))
	_add_wall(Vector2(0.0, WORLD_HALF_SIZE.y + 16.0), Vector2(WORLD_HALF_SIZE.x * 2.0 + 64.0, 32.0))
	_add_wall(Vector2(-WORLD_HALF_SIZE.x - 16.0, 0.0), Vector2(32.0, WORLD_HALF_SIZE.y * 2.0 + 64.0))
	_add_wall(Vector2(WORLD_HALF_SIZE.x + 16.0, 0.0), Vector2(32.0, WORLD_HALF_SIZE.y * 2.0 + 64.0))


func _add_wall(wall_position: Vector2, wall_size: Vector2) -> void:
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	wall.collision_mask = 0
	wall.position = wall_position

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = wall_size
	collision.shape = shape
	wall.add_child(collision)
	add_child(wall)


func _restart_world() -> void:
	get_tree().reload_current_scene()


func _return_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
