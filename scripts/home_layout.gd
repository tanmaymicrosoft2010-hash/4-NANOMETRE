extends RefCounted
## Aesthetic, responsive homepage composition.
## Scaled cleanly to prevent any elements from clipping or excluding from screen.

const DISPLAY: Font = preload("res://assets/kenney_ui-pack-space-expansion/Font/Kenney Future Narrow.ttf")
const BODY: Font = preload("res://assets/kenney_ui-pack-space-expansion/Font/Kenney Future.ttf")

const WHITE := Color("#f8fafc")
const MUTED := Color("#8fa6b8")
const GREEN := Color("#00ff88")
const BLUE := Color("#00e5ff")
const AMBER := Color("#f59e0b")
const PANEL := Color("#081220")


static func build(host: Control) -> Dictionary:
	var margin := MarginContainer.new()
	margin.name = "HomeLayout"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	host.add_child(margin)

	var shell := _box(VBoxContainer.new(), margin, 10)
	shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_masthead(shell)
	
	var hero := _box(HBoxContainer.new(), shell, 32)
	hero.custom_minimum_size.y = 210
	hero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_hero_copy(hero)
	
	var preview := load("res://ui/line_preview.tscn").instantiate() as Control
	preview.name = "LiveDemo"
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero.add_child(preview)

	var sites := _box(VBoxContainer.new(), shell, 6)
	var site_header := _box(HBoxContainer.new(), sites, 0)
	site_header.custom_minimum_size.y = 22
	_label(site_header, "CHOOSE YOUR SHIFT", 17, WHITE, DISPLAY).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(site_header, "01 MISSION   /   02 FACTORIES", 10, MUTED)
	
	var cards := _box(HBoxContainer.new(), sites, 14)
	var silicon := _site_card(cards, "SiliconButton", "01", "Silicon Valley", "STANDARD SHIFT", "04:45", "6s hit penalty", BLUE, "silicon-valley")
	var shenzhen := _site_card(cards, "ShenzhenButton", "02", "Shenzhen", "HARD SHIFT", "03:45", "8s hit penalty", AMBER, "shenzhen")

	var footer := _box(HBoxContainer.new(), shell, 12)
	footer.custom_minimum_size.y = 44
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	var how_to := _button(footer, "HowToButton", "How to play  /")
	how_to.custom_minimum_size = Vector2(130, 34)
	var story := _button(footer, "StoryButton", "Mission Story  /")
	story.custom_minimum_size = Vector2(122, 34)
	_label(footer, "First movement clocks you in. Defuse before burnout.", 11, MUTED).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var connect_button := _button(footer, "ConnectButton", "ESP32")
	connect_button.custom_minimum_size = Vector2(74, 34)
	
	var options := load("res://ui/play_options.tscn").instantiate() as Control
	options.get_node("Sound").custom_minimum_size = Vector2(104, 34)
	options.get_node("Screen").custom_minimum_size = Vector2(108, 34)
	for button in [options.get_node("Sound"), options.get_node("Screen")]:
		button.add_theme_font_override("font", BODY)
		button.add_theme_font_size_override("font_size", 12)
		button.add_theme_color_override("font_color", WHITE)
		button.add_theme_color_override("font_hover_color", GREEN)
		button.add_theme_color_override("font_pressed_color", GREEN)
		button.add_theme_stylebox_override("normal", _style(Color("#091422"), Color("#1a304d"), 1, 4))
		button.add_theme_stylebox_override("hover", _style(Color("#11243a"), GREEN, 1, 4))
		button.add_theme_stylebox_override("pressed", _style(Color("#183250"), GREEN, 1, 4))
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	footer.add_child(options)
	return {"silicon": silicon, "shenzhen": shenzhen}


static func _masthead(parent: Container) -> void:
	var row := _box(HBoxContainer.new(), parent, 12)
	row.custom_minimum_size.y = 38
	var mark := PanelContainer.new()
	mark.custom_minimum_size = Vector2(34, 32)
	mark.add_theme_stylebox_override("panel", _style(Color("#0d1e33"), BLUE, 1, 4))
	row.add_child(mark)
	var four := _label(mark, "4", 22, BLUE, DISPLAY)
	four.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var brand := _box(VBoxContainer.new(), row, 0)
	brand.alignment = BoxContainer.ALIGNMENT_CENTER
	_label(brand, "NANO METRE", 19, WHITE, DISPLAY)
	_label(brand, "FAB OPERATIONS", 9, MUTED)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	_label(row, "DEFENSE SYSTEM", 10, GREEN)
	var dot := ColorRect.new()
	dot.color = GREEN
	dot.custom_minimum_size = Vector2(6, 6)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(dot)
	_label(row, "CEO GPU ONLINE", 10, MUTED)


static func _hero_copy(parent: Container) -> void:
	var column := _box(VBoxContainer.new(), parent, 0)
	column.custom_minimum_size.x = 420
	column.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_label(column, "EMERGENCY DISPATCH   /   OPERATION DEFUSE", 10, GREEN)
	var space := Control.new()
	space.custom_minimum_size.y = 6
	column.add_child(space)
	_label(column, "4 NANO\nMETRE", 52, WHITE, DISPLAY)
	var copy := _label(column, "One armed bomb. 14 cleanroom bays.\nInfiltrate the floor, brute-force the host, defuse the core.", 14, MUTED)
	copy.add_theme_constant_override("line_spacing", 5)
	space = Control.new()
	space.custom_minimum_size.y = 8
	column.add_child(space)
	_label(column, "LEVEL 1: CORE RUN   //   LEVEL 2: GTA HOST HACK", 10, BLUE)


static func _site_card(parent: Container, id: String, number: String, title: String,
		difficulty: String, fuse: String, penalty: String, accent: Color, image_name: String) -> Button:
	var button := Button.new()
	button.name = id
	button.unique_name_in_owner = true
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 138)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal", _style(PANEL, Color("#182b42"), 1, 4))
	button.add_theme_stylebox_override("hover", _style(Color("#112036"), accent, 1, 4))
	button.add_theme_stylebox_override("pressed", _style(Color("#1a304f"), accent, 2, 4))
	var focus := _style(Color(0, 0, 0, 0), accent, 2, 4)
	focus.draw_center = false
	focus.expand_margin_left = 2
	focus.expand_margin_right = 2
	focus.expand_margin_top = 2
	focus.expand_margin_bottom = 2
	button.add_theme_stylebox_override("focus", focus)
	parent.add_child(button)
	button.owner = button.get_tree().current_scene

	var art_clip := Control.new()
	art_clip.name = "ArtClip"
	art_clip.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	art_clip.offset_right = 145
	art_clip.clip_contents = true
	art_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(art_clip)
	var base := ColorRect.new()
	base.color = Color("#0b1626")
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_clip.add_child(base)
	var art := TextureRect.new()
	art.name = "Art"
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.modulate = Color(0.82, 0.86, 0.85)
	art_clip.add_child(art)
	for extension in ["png", "jpg", "jpeg", "webp"]:
		var path := "res://assets/site_cards/%s.%s" % [image_name, extension]
		if ResourceLoader.exists(path):
			art.texture = load(path)
			break
	if not art.texture:
		_label(art_clip, number, 52, Color(accent, 0.28), DISPLAY).position = Vector2(16, 24)
		_label(art_clip, "SITE / " + number, 10, accent).position = Vector2(16, 100)

	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.05, 0.10, 0.25)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_clip.add_child(shade)
	var line := ColorRect.new()
	line.color = accent
	line.anchor_top = 1
	line.anchor_bottom = 1
	line.offset_top = -3
	line.offset_right = 145
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(line)

	var text := MarginContainer.new()
	text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	text.offset_left = 160
	text.offset_top = 12
	text.offset_right = -14
	text.offset_bottom = -10
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(text)
	var column := _box(VBoxContainer.new(), text, 3)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label(column, difficulty + "   /   " + number, 10, accent)
	_label(column, title, 22, WHITE, DISPLAY)
	_label(column, "FUSE  " + fuse + "    /    " + penalty, 11, MUTED, BODY)
	var action := _label(column, "Enter factory    ->", 11, accent)
	action.add_theme_constant_override("margin_top", 4)
	return button


static func _button(parent: Container, id: String, text: String) -> Button:
	var button := Button.new()
	button.name = id
	button.unique_name_in_owner = true
	button.text = text
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", BODY)
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", WHITE)
	button.add_theme_color_override("font_hover_color", GREEN)
	button.add_theme_color_override("font_pressed_color", GREEN)
	button.add_theme_stylebox_override("normal", _style(Color("#091422"), Color("#182b42"), 1, 4))
	button.add_theme_stylebox_override("hover", _style(Color("#11243a"), BLUE, 1, 4))
	button.add_theme_stylebox_override("pressed", _style(Color("#183250"), GREEN, 1, 4))
	parent.add_child(button)
	button.owner = button.get_tree().current_scene
	return button


static func _label(parent: Node, text: String, font_size: int, color: Color, font: Font = BODY) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


static func _box(container: Container, parent: Node, separation: int) -> Container:
	container.add_theme_constant_override("separation", separation)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(container)
	return container


static func _style(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 10
	style.content_margin_right = 10
	return style
