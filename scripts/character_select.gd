extends Control

const HomeLayout := preload("res://scripts/home_layout.gd")

var _site_buttons: Array[Button] = []
var _card_tweens: Dictionary = {}


func _ready() -> void:
	# Keep the original desk backdrop; the foreground is a separate dispatch UI.
	for node in ["Masthead", "TopRule", "BottomRule", "Footer"]:
		$Desk.get_node(node).hide()
	var veil := ColorRect.new()
	veil.name = "HomeVeil"
	veil.color = Color(0.025, 0.065, 0.07, 0.76)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(veil)
	var cards := HomeLayout.build(self)
	_site_buttons.assign([cards.silicon, cards.shenzhen])
	%SiliconButton.pressed.connect(_play.bind("USA"))
	%ShenzhenButton.pressed.connect(_play.bind("SHENZHEN"))
	for button in _site_buttons:
		button.mouse_entered.connect(_animate_card.bind(button, true))
		button.mouse_exited.connect(_animate_card.bind(button, false))
		button.focus_entered.connect(_animate_card.bind(button, true))
		button.focus_exited.connect(_animate_card.bind(button, false))
	%HowToButton.pressed.connect(_how_to)
	%StoryButton.pressed.connect(_clock_in)
	%ConnectButton.pressed.connect(_connect_hardware)
	%ConnectButton.visible = OS.has_feature("web") and JavaScriptBridge.eval(
			"typeof window.connectArduino === 'function'")
	%SiliconButton.grab_focus()
	var layout := $HomeLayout
	layout.modulate.a = 0.0
	create_tween().tween_property(layout, "modulate:a", 1.0, 0.42).set_trans(Tween.TRANS_SINE)


func _animate_card(button: Button, active: bool) -> void:
	if _card_tweens.has(button):
		(_card_tweens[button] as Tween).kill()
	var tween := create_tween()
	_card_tweens[button] = tween
	var art := button.get_node("ArtClip/Art") as TextureRect
	tween.tween_property(art, "modulate", Color.WHITE if active else Color(0.82, 0.86, 0.85), 0.22)


func _play(site: String) -> void:
	GameState.selected_world = site
	GameState.floor_dispatch = true
	GameState.start_level(1)


func _how_to() -> void:
	get_tree().change_scene_to_file(GameState.HOW_TO)


func _clock_in() -> void:
	GameState.floor_dispatch = true
	get_tree().change_scene_to_file(GameState.BRIEFING)


func _connect_hardware() -> void:
	if not OS.has_feature("web"):
		return
	var available = JavaScriptBridge.eval("typeof window.connectArduino === 'function'")
	if available:
		JavaScriptBridge.eval("window.connectArduino();")
