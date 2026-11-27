extends CanvasLayer

signal restart_requested
signal menu_requested

var _health_bar: ProgressBar
var _hunger_bar: ProgressBar
var _inventory_label: Label
var _clock_label: Label
var _message_label: Label
var _game_over_overlay: ColorRect


func _ready() -> void:
	_build_interface()


func update_stats(health: float, hunger: float, inventory_data: Dictionary) -> void:
	if not is_instance_valid(_health_bar):
		return

	_health_bar.value = health
	_hunger_bar.value = hunger
	_inventory_label.text = "WOOD  %02d     STONE  %02d     BERRIES  %02d" % [
		int(inventory_data.get("wood", 0)),
		int(inventory_data.get("stone", 0)),
		int(inventory_data.get("berries", 0)),
	]


func update_clock(day_number: int, phase: String) -> void:
	if is_instance_valid(_clock_label):
		_clock_label.text = "DAY %02d   /   %s" % [day_number, phase.to_upper()]


func show_message(message: String) -> void:
	if not is_instance_valid(_message_label):
		return

	_message_label.text = message
	get_tree().create_timer(2.4).timeout.connect(_clear_message.bind(message))


func show_game_over() -> void:
	_game_over_overlay.visible = true


func _clear_message(expected_message: String) -> void:
	if is_instance_valid(_message_label) and _message_label.text == expected_message:
		_message_label.text = ""


func _build_interface() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var stats_panel := _make_panel()
	stats_panel.position = Vector2(18.0, 18.0)
	stats_panel.size = Vector2(330.0, 132.0)
	stats_panel.custom_minimum_size = Vector2(330.0, 132.0)
	root.add_child(stats_panel)

	var stats_box := VBoxContainer.new()
	stats_box.add_theme_constant_override("separation", 7)
	stats_panel.add_child(stats_box)

	var heading := Label.new()
	heading.text = "SURVIVAL"
	heading.add_theme_font_size_override("font_size", 13)
	heading.add_theme_color_override("font_color", Color(0.76, 0.86, 0.70))
	stats_box.add_child(heading)

	_health_bar = _add_stat_row(stats_box, "HEALTH", Color(0.75, 0.30, 0.28))
	_hunger_bar = _add_stat_row(stats_box, "HUNGER", Color(0.85, 0.63, 0.28))

	var separator := HSeparator.new()
	stats_box.add_child(separator)

	_inventory_label = Label.new()
	_inventory_label.text = "WOOD  00     STONE  00     BERRIES  00"
	_inventory_label.add_theme_font_size_override("font_size", 12)
	_inventory_label.add_theme_color_override("font_color", Color(0.91, 0.91, 0.81))
	stats_box.add_child(_inventory_label)

	var clock_panel := _make_panel()
	clock_panel.anchor_left = 1.0
	clock_panel.anchor_right = 1.0
	clock_panel.offset_left = -218.0
	clock_panel.offset_right = -18.0
	clock_panel.offset_top = 18.0
	clock_panel.offset_bottom = 62.0
	root.add_child(clock_panel)

	_clock_label = Label.new()
	_clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_clock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_clock_label.add_theme_font_size_override("font_size", 13)
	_clock_label.add_theme_color_override("font_color", Color(0.91, 0.91, 0.81))
	clock_panel.add_child(_clock_label)

	_message_label = Label.new()
	_message_label.anchor_left = 0.5
	_message_label.anchor_right = 0.5
	_message_label.anchor_top = 1.0
	_message_label.anchor_bottom = 1.0
	_message_label.offset_left = -230.0
	_message_label.offset_right = 230.0
	_message_label.offset_top = -88.0
	_message_label.offset_bottom = -60.0
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_font_size_override("font_size", 15)
	_message_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.75))
	root.add_child(_message_label)

	var controls_label := Label.new()
	controls_label.anchor_left = 0.5
	controls_label.anchor_right = 0.5
	controls_label.anchor_top = 1.0
	controls_label.anchor_bottom = 1.0
	controls_label.offset_left = -300.0
	controls_label.offset_right = 300.0
	controls_label.offset_top = -42.0
	controls_label.offset_bottom = -14.0
	controls_label.text = "WASD MOVE   E GATHER   F EAT   C CAMPFIRE"
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_label.add_theme_font_size_override("font_size", 12)
	controls_label.add_theme_color_override("font_color", Color(0.84, 0.88, 0.78))
	root.add_child(controls_label)

	if OS.has_feature("mobile") or OS.has_feature("android"):
		_build_touch_controls(root)

	_build_game_over_overlay(root)


func _add_stat_row(parent: VBoxContainer, title: String, fill_color: Color) -> ProgressBar:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)

	var label := Label.new()
	label.text = title
	label.custom_minimum_size = Vector2(60.0, 0.0)
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(0.88, 0.89, 0.81))
	row.add_child(label)

	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size = Vector2(150.0, 16.0)
	bar.add_theme_stylebox_override("fill", _make_bar_style(fill_color))
	row.add_child(bar)
	return bar


func _make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.12, 0.09, 0.91)
	style.border_color = Color(0.35, 0.49, 0.34, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 13.0
	style.content_margin_right = 13.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _make_bar_style(fill_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.set_corner_radius_all(3)
	return style


func _build_touch_controls(root: Control) -> void:
	_add_touch_button(root, "↑", "move_up", Rect2(72.0, -184.0, 54.0, 54.0))
	_add_touch_button(root, "←", "move_left", Rect2(16.0, -128.0, 54.0, 54.0))
	_add_touch_button(root, "↓", "move_down", Rect2(72.0, -128.0, 54.0, 54.0))
	_add_touch_button(root, "→", "move_right", Rect2(128.0, -128.0, 54.0, 54.0))
	_add_touch_button(root, "E", "interact", Rect2(-132.0, -126.0, 54.0, 54.0), true)
	_add_touch_button(root, "F", "eat", Rect2(-72.0, -72.0, 54.0, 54.0), true)
	_add_touch_button(root, "C", "craft", Rect2(-132.0, -66.0, 54.0, 54.0), true)


func _add_touch_button(
	parent: Control,
	text_value: String,
	action: StringName,
	bottom_rect: Rect2,
	press_only: bool = false
) -> void:
	var button := Button.new()
	button.text = text_value
	button.anchor_left = 0.0 if bottom_rect.position.x >= 0.0 else 1.0
	button.anchor_right = button.anchor_left
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = bottom_rect.position.x
	button.offset_top = bottom_rect.position.y
	button.offset_right = bottom_rect.position.x + bottom_rect.size.x
	button.offset_bottom = bottom_rect.position.y + bottom_rect.size.y
	button.add_theme_font_size_override("font_size", 21)
	button.add_theme_color_override("font_color", Color(0.94, 0.95, 0.88))
	parent.add_child(button)

	if press_only:
		button.pressed.connect(_press_action_once.bind(action))
	else:
		button.button_down.connect(_press_action.bind(action))
		button.button_up.connect(_release_action.bind(action))


func _press_action(action: StringName) -> void:
	Input.action_press(action)


func _release_action(action: StringName) -> void:
	Input.action_release(action)


func _press_action_once(action: StringName) -> void:
	Input.action_press(action)
	get_tree().create_timer(0.08).timeout.connect(_release_action.bind(action))


func _build_game_over_overlay(root: Control) -> void:
	_game_over_overlay = ColorRect.new()
	_game_over_overlay.color = Color(0.02, 0.04, 0.03, 0.82)
	_game_over_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_game_over_overlay.visible = false
	_game_over_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(_game_over_overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_game_over_overlay.add_child(center)

	var panel := _make_panel()
	panel.custom_minimum_size = Vector2(330.0, 0.0)
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	var title := Label.new()
	title.text = "THE WILD GOT THE BETTER OF YOU"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.91, 0.72, 0.55))
	box.add_child(title)

	var detail := Label.new()
	detail.text = "You ran out of health. Give it another go."
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.add_theme_font_size_override("font_size", 13)
	box.add_child(detail)

	var retry_button := Button.new()
	retry_button.text = "TRY AGAIN"
	retry_button.custom_minimum_size = Vector2(0.0, 42.0)
	retry_button.pressed.connect(func() -> void: restart_requested.emit())
	box.add_child(retry_button)

	var menu_button := Button.new()
	menu_button.text = "MAIN MENU"
	menu_button.custom_minimum_size = Vector2(0.0, 38.0)
	menu_button.pressed.connect(func() -> void: menu_requested.emit())
	box.add_child(menu_button)
