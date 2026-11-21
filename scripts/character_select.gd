extends Control

@onready var connect_button: Button = %ConnectButton


func _ready() -> void:
	%StartButton.grab_focus()
	connect_button.visible = OS.has_feature("web")


func _play() -> void:
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
	else:
		%HardwareNote.text = "No hardware bridge on this page. You can still play."
