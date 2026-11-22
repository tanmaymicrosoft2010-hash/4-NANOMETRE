extends Control


func _ready() -> void:
	%PlayButton.grab_focus()
	%Jump.text = "%s or Up" % GameState.jump_key_text
	%Red.text = "-%d seconds" % int(GameState.hit_penalty())
	%Body.text = "A bomb is under the wafer line. You are CEO GPU, the last operator on shift. Cross 14 bays and reach the core before the %s fuse burns out.\n\nLevel 1: factory floor.\nLevel 2: wafer-sort console." % GameState.clock_text(GameState.fuse_seconds())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_back()


func _play() -> void:
	GameState.floor_dispatch = true
	GameState.start_level(1)


func _back() -> void:
	get_tree().change_scene_to_file(GameState.HOME)
