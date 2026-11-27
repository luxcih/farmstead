extends CharacterBody2D

const CAMPFIRE_SCENE: PackedScene = preload("res://scenes/world/campfire.tscn")

signal stats_changed(health: float, hunger: float, inventory_data: Dictionary)
signal message_changed(message: String)
signal player_died

@export_range(1.0, 500.0, 1.0) var move_speed: float = 120.0
@export_range(0.0, 5.0, 0.05) var hunger_loss_per_second: float = 0.45
@export_range(0.0, 30.0, 0.5) var starvation_damage_per_second: float = 8.0

var health: float = 100.0
var hunger: float = 82.0
var inventory: Dictionary = {
	"wood": 0,
	"stone": 0,
	"berries": 0,
}

var nearby_resources: Array[Node2D] = []
var nearby_campfires: Array[Node2D] = []
var facing_direction: Vector2 = Vector2.DOWN
var _ui_refresh_timer: float = 0.0
var _is_dead: bool = false

@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	interaction_area.body_entered.connect(_on_interaction_body_entered)
	interaction_area.body_exited.connect(_on_interaction_body_exited)
	publish_stats()


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length_squared() > 0.001:
		facing_direction = direction
	velocity = direction * move_speed
	move_and_slide()

	if Input.is_action_just_pressed("interact"):
		_harvest_nearest_resource()
	elif Input.is_action_just_pressed("eat"):
		_eat_berries()
	elif Input.is_action_just_pressed("craft"):
		_craft_campfire()

	_apply_campfire_rest(delta)

	if hunger > 0.0:
		hunger = maxf(0.0, hunger - hunger_loss_per_second * delta)
	else:
		health = maxf(0.0, health - starvation_damage_per_second * delta)
		if health <= 0.0:
			_die()

	_ui_refresh_timer += delta
	if _ui_refresh_timer >= 0.25:
		_ui_refresh_timer = 0.0
		publish_stats()


func _on_interaction_body_entered(body: Node2D) -> void:
	if body.is_in_group("harvestable") and not nearby_resources.has(body):
		nearby_resources.append(body)
	elif body.is_in_group("campfires") and not nearby_campfires.has(body):
		nearby_campfires.append(body)


func _on_interaction_body_exited(body: Node2D) -> void:
	nearby_resources.erase(body)
	nearby_campfires.erase(body)


func _harvest_nearest_resource() -> void:
	var target: Node2D = null
	var closest_distance: float = INF

	for resource in nearby_resources:
		if not is_instance_valid(resource):
			continue

		var distance := global_position.distance_squared_to(resource.global_position)
		if distance < closest_distance:
			closest_distance = distance
			target = resource

	if target == null:
		message_changed.emit("Nothing close enough to gather.")
		return

	var drops: Dictionary = target.call("harvest")
	if drops.is_empty():
		return

	for item in drops:
		var amount: int = int(drops[item])
		inventory[item] = int(inventory.get(item, 0)) + amount
		message_changed.emit("Gathered %s x%d" % [str(item), amount])

	publish_stats()


func _eat_berries() -> void:
	var berries: int = int(inventory.get("berries", 0))
	if berries <= 0:
		message_changed.emit("No berries. Find a berry bush first.")
		return

	inventory["berries"] = berries - 1
	hunger = minf(100.0, hunger + 30.0)
	message_changed.emit("Ate berries. Hunger restored.")
	publish_stats()


func _craft_campfire() -> void:
	if int(inventory.get("wood", 0)) < 3 or int(inventory.get("stone", 0)) < 2:
		message_changed.emit("Campfire needs 3 wood and 2 stone.")
		return

	inventory["wood"] = int(inventory["wood"]) - 3
	inventory["stone"] = int(inventory["stone"]) - 2

	var campfire := CAMPFIRE_SCENE.instantiate() as Node2D
	if campfire == null:
		message_changed.emit("Could not place a campfire.")
		return

	get_parent().add_child(campfire)
	campfire.global_position = global_position + facing_direction * 28.0
	message_changed.emit("Campfire placed. Rest nearby to recover health.")
	publish_stats()


func _apply_campfire_rest(delta: float) -> void:
	for campfire in nearby_campfires:
		if is_instance_valid(campfire):
			health = minf(100.0, health + 2.5 * delta)
			hunger = minf(100.0, hunger + 0.7 * delta)
			return


func publish_stats() -> void:
	stats_changed.emit(health, hunger, inventory.duplicate())


func _die() -> void:
	if _is_dead:
		return

	_is_dead = true
	velocity = Vector2.ZERO
	player_died.emit()
