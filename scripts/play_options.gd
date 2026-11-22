extends HBoxContainer


func _ready() -> void:
	get_tree().root.size_changed.connect(_refresh)
	if OS.has_feature("web"):
		$Screen.visible = JavaScriptBridge.eval("!!document.fullscreenEnabled")
	_refresh()


func _refresh() -> void:
	$Sound.text = "Sound: off" if AudioServer.is_bus_mute(0) else "Sound: on"
	$Screen.text = "Windowed" if _fullscreen() else "Fullscreen"


func _fullscreen() -> bool:
	return DisplayServer.window_get_mode() in [
			DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]


func _toggle_sound() -> void:
	GameState.set_muted(not AudioServer.is_bus_mute(0))
	_refresh()


func _toggle_screen() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if _fullscreen()
			else DisplayServer.WINDOW_MODE_FULLSCREEN)
	_refresh()
