extends RefCounted
## Homepage composition only. All visual assets are supplied by the existing game
## or the player; this class creates layout, type and interaction surfaces.

const DISPLAY: Font = preload("res://assets/kenney_ui-pack-space-expansion/Font/Kenney Future Narrow.ttf")
const BODY: Font = preload("res://assets/kenney_ui-pack-space-expansion/Font/Kenney Future.ttf")

const WHITE := Color("#f2f3ea")
const MUTED := Color("#9aa9a6")
const GREEN := Color("#c4e9a0")
const BLUE := Color("#8cd9d4")
const AMBER := Color("#eabb83")
const PANEL := Color("#101b1d")


static func build(host: Control) -> Dictionary:
	var margin := MarginContainer.new()
	margin.name = "HomeLayout"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 60)
	margin.add_theme_constant_override("margin_top", 27)
	margin.add_theme_constant_override("margin_bottom", 22)
	host.add_child(margin)

	var shell := _box(VBoxContainer.new(), margin, 0)
	_masthead(shell)
	var hero := _box(HBoxContainer.new(), shell, 42)
	hero.custom_minimum_size.y = 284
	hero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_hero_copy(hero)
	var preview := load("res://ui/line_preview.tscn").instantiate() as Control
	preview.name = "LiveDemo"
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero.add_child(preview)

	var sites := _box(VBoxContainer.new(), shell, 9)
	var site_header := _box(HBoxContainer.new(), sites, 0)
	site_header.custom_minimum_size.y = 28
	_label(site_header, "CHOOSE YOUR SHIFT", 21, WHITE, DISPLAY).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(site_header, "01 MISSION   /   02 FACTORIES", 12, MUTED)
	var cards := _box(HBoxContainer.new(), sites, 18)
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var silicon := _site_card(cards, "SiliconButton", "01", "Silicon Valley", "STANDARD SHIFT", "04:45", "6s hit penalty", BLUE, "silicon-valley")
	var shenzhen := _site_card(cards, "ShenzhenButton", "02", "Shenzhen", "HARD SHIFT", "03:45", "8s hit penalty", AMBER, "shenzhen")

	var footer := _box(HBoxContainer.new(), shell, 16)
	footer.custom_minimum_size.y = 62
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	var how_to := _button(footer, "HowToButton", "How to play  /")
	how_to.custom_minimum_size = Vector2(148, 38)
	var story := _button(footer, "StoryButton", "Story  /")
	story.custom_minimum_size = Vector2(105, 38)
	_label(footer, "Your first step starts the clock.", 13, MUTED).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var connect_button := _button(footer, "ConnectButton", "ESP32")
	connect_button.custom_minimum_size = Vector2(88, 38)
	var options := load("res://ui/play_options.tscn").instantiate() as Control
	options.get_node("Sound").custom_minimum_size = Vector2(126, 38)
	options.get_node("Screen").custom_minimum_size = Vector2(130, 38)
	for button in [options.get_node("Sound"), options.get_node("Screen")]:
		button.add_theme_font_override("font", BODY)
		button.add_theme_font_size_override("font_size", 13)
		button.add_theme_color_override("font_color", WHITE)
		button.add_theme_color_override("font_hover_color", GREEN)
		button.add_theme_color_override("font_pressed_color", GREEN)
		button.add_theme_stylebox_override("normal", _style(Color(0, 0, 0, 0), Color("#344244"), 1, 3))
		button.add_theme_stylebox_override("hover", _style(Color("#1c2d2d"), GREEN, 1, 3))
		button.add_theme_stylebox_override("pressed", _style(Color("#273b36"), GREEN, 1, 3))
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	footer.add_child(options)
	return {"silicon": silicon, "shenzhen": shenzhen}


static func _masthead(parent: Container) -> void:
	var row := _box(HBoxContainer.new(), parent, 15)
	row.custom_minimum_size.y = 50
	var mark := PanelContainer.new()
	mark.custom_minimum_size = Vector2(42, 40)
	mark.add_theme_stylebox_override("panel", _style(Color("#172528"), GREEN, 1, 3))
	row.add_child(mark)
	var four := _label(mark, "4", 28, GREEN, DISPLAY)
	four.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var brand := _box(VBoxContainer.new(), row, 1)
	brand.alignment = BoxContainer.ALIGNMENT_CENTER
	_label(brand, "NANO METRE", 24, WHITE, DISPLAY)
	_label(brand, "FAB OPERATIONS", 10, MUTED)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	_label(row, "SYSTEM ONLINE", 12, GREEN)
	var dot := ColorRect.new()
	dot.color = GREEN
	dot.custom_minimum_size = Vector2(7, 7)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(dot)
	_label(row, "NIGHT SHIFT / 01", 12, MUTED)


static func _hero_copy(parent: Container) -> void:
	var column := _box(VBoxContainer.new(), parent, 0)
	column.custom_minimum_size.x = 488
	column.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_label(column, "EMERGENCY DISPATCH   /   CORE RUN", 12, GREEN)
	var space := Control.new()
	space.custom_minimum_size.y = 10
	column.add_child(space)
	_label(column, "4 NANO\nMETRE", 70, WHITE, DISPLAY)
	var copy := _label(column, "One bomb. Fourteen bays.\nYou're the last operator on the line.", 18, MUTED)
	copy.add_theme_constant_override("line_spacing", 7)
	space = Control.new()
	space.custom_minimum_size.y = 13
	column.add_child(space)
	_label(column, "A RACE AGAINST THE LAST SHIFT.", 11, WHITE)


static func _site_card(parent: Container, id: String, number: String, title: String,
		difficulty: String, fuse: String, penalty: String, accent: Color, image_name: String) -> Button:
	var button := Button.new()
	button.name = id
	button.unique_name_in_owner = true
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 174)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal", _style(PANEL, Color("#344244"), 1, 4))
	button.add_theme_stylebox_override("hover", _style(Color("#162629"), accent, 1, 4))
	button.add_theme_stylebox_override("pressed", _style(Color("#1d3030"), accent, 2, 4))
	var focus := _style(Color(0, 0, 0, 0), accent, 2, 4)
	focus.draw_center = false
	focus.expand_margin_left = 3
	focus.expand_margin_right = 3
	focus.expand_margin_top = 3
	focus.expand_margin_bottom = 3
	button.add_theme_stylebox_override("focus", focus)
	parent.add_child(button)
	button.owner = button.get_tree().current_scene

	var art_clip := Control.new()
	art_clip.name = "ArtClip"
	art_clip.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	art_clip.offset_right = 183
	art_clip.clip_contents = true
	art_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(art_clip)
	var base := ColorRect.new()
	base.color = Color("#1a292b")
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
	# Add the supplied images as silicon-valley.png and shenzhen.png.
	# Until those files arrive, the restrained numeric site tile is shown.
	for extension in ["png", "jpg", "jpeg", "webp"]:
		var path := "res://assets/site_cards/%s.%s" % [image_name, extension]
		if ResourceLoader.exists(path):
			art.texture = load(path)
			break
	if not art.texture:
		_label(art_clip, number, 67, Color(accent, 0.26), DISPLAY).position = Vector2(18, 31)
		_label(art_clip, "SITE / " + number, 11, accent).position = Vector2(20, 125)

	var shade := ColorRect.new()
	shade.color = Color(0.03, 0.08, 0.09, 0.20)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_clip.add_child(shade)
	var line := ColorRect.new()
	line.color = accent
	line.anchor_top = 1
	line.anchor_bottom = 1
	line.offset_top = -3
	line.offset_right = 183
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(line)

	var text := MarginContainer.new()
	text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	text.offset_left = 203
	text.offset_top = 17
	text.offset_right = -17
	text.offset_bottom = -13
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(text)
	var column := _box(VBoxContainer.new(), text, 4)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label(column, difficulty + "   /   " + number, 11, accent)
	_label(column, title, 27, WHITE, DISPLAY)
	_label(column, "FUSE  " + fuse + "    /    " + penalty, 12, MUTED, BODY)
	var action := _label(column, "Enter factory    ->", 13, accent)
	action.add_theme_constant_override("margin_top", 6)
	return button


static func _button(parent: Container, id: String, text: String) -> Button:
	var button := Button.new()
	button.name = id
	button.unique_name_in_owner = true
	button.text = text
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", BODY)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", WHITE)
	button.add_theme_color_override("font_hover_color", GREEN)
	button.add_theme_color_override("font_pressed_color", GREEN)
	button.add_theme_stylebox_override("normal", _style(Color(0, 0, 0, 0), Color.TRANSPARENT, 0, 3))
	button.add_theme_stylebox_override("hover", _style(Color("#1c2d2d"), Color("#435250"), 1, 3))
	button.add_theme_stylebox_override("pressed", _style(Color("#273b36"), GREEN, 1, 3))
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
	style.content_margin_left = 12
	style.content_margin_right = 12
	return style
