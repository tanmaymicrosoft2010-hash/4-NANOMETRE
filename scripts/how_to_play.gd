extends Control


func _ready() -> void:
	%PlayButton.grab_focus()
	%Jump.text = "%s or Up" % GameState.jump_key_text
	%Red.text = "-%d seconds" % int(GameState.hit_penalty())
	%Body.text = "A bomb is planted under the wafer line at the 4 Nano Metre fab. You are CEO GPU, the last operator on shift. Infiltrate 14 bays and defuse the core before the %s fuse burns out.\n\n[ LEVEL 1: CORE RUN ]\nPlatformer run across the factory bays. Collect green resistors (+5s), dodge hot plates and hazards.\n\n[ LEVEL 2: HOST BREACH ]\nGTA-style terminal IP hacking minigame! Navigate the 8x10 matrix using WASD/Arrows or Mouse, locate the 4-part target IP, and press Space/Enter/Click to inject the payload." % GameState.clock_text(GameState.fuse_seconds())
	
	for btn: Button in [%PlayButton, %BackButton]:
		btn.mouse_entered.connect(func(): SoundFX.play("ui_tick"))
		btn.focus_entered.connect(func(): SoundFX.play("ui_tick"))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_back()


func _play() -> void:
	SoundFX.play("ui_click")
	GameState.floor_dispatch = true
	GameState.start_level(1)


func _back() -> void:
	SoundFX.play("ui_click")
	get_tree().change_scene_to_file(GameState.HOME)
