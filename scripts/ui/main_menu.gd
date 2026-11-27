extends Control


func _ready() -> void:
	_build_menu()


func _build_menu() -> void:
	var background := ColorRect.new()
	background.color = Color(0.09, 0.16, 0.12)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var upper_accent := ColorRect.new()
	upper_accent.color = Color(0.16, 0.28, 0.19)
	upper_accent.anchor_left = 0.0
	upper_accent.anchor_right = 1.0
	upper_accent.anchor_bottom = 0.34
	upper_accent.offset_bottom = 0.0
	upper_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.add_child(upper_accent)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(390.0, 0.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.055, 0.095, 0.07, 0.96)
	panel_style.border_color = Color(0.38, 0.53, 0.36)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.content_margin_left = 28.0
	panel_style.content_margin_right = 28.0
	panel_style.content_margin_top = 26.0
	panel_style.content_margin_bottom = 26.0
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	panel.add_child(content)

	var eyebrow := Label.new()
	eyebrow.text = "A TOP-DOWN SANDBOX"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_font_size_override("font_size", 12)
	eyebrow.add_theme_color_override("font_color", Color(0.67, 0.79, 0.61))
	content.add_child(eyebrow)

	var title := Label.new()
	title.text = "FARMSTEAD"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.91, 0.91, 0.77))
	content.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Find a place. Gather what you need. Make it home."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color(0.73, 0.78, 0.69))
	content.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 8.0)
	content.add_child(spacer)

	var play_button := _make_menu_button("PLAY")
	play_button.pressed.connect(_start_game)
	content.add_child(play_button)

	var quit_button := _make_menu_button("QUIT")
	quit_button.pressed.connect(_quit_game)
	content.add_child(quit_button)

	var footer := Label.new()
	footer.text = "PROTOTYPE BUILD  /  MORE TO COME"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 10)
	footer.add_theme_color_override("font_color", Color(0.48, 0.59, 0.47))
	content.add_child(footer)


func _make_menu_button(button_text: String) -> Button:
	var button := Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(0.0, 46.0)
	button.add_theme_font_size_override("font_size", 14)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.20, 0.36, 0.23)
	normal.set_corner_radius_all(7)
	button.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.27, 0.45, 0.29)
	hover.set_corner_radius_all(7)
	button.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(0.14, 0.27, 0.18)
	pressed.set_corner_radius_all(7)
	button.add_theme_stylebox_override("pressed", pressed)

	button.add_theme_color_override("font_color", Color(0.96, 0.96, 0.88))
	return button


func _start_game() -> void:
	var result := get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	if result != OK:
		push_error("Could not open the world scene: %s" % error_string(result))


func _quit_game() -> void:
	get_tree().quit()
