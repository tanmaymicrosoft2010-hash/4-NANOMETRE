extends Control

@export var passed_sound: AudioStream
@export var failed_sound: AudioStream


func _ready() -> void:
	var saved := GameState.last_result == "SAVED"
	if saved:
		SoundFX.play("win")
	else:
		SoundFX.play("fail")
	
	%Order.text = "LEVEL %02d   /   %s" % [GameState.selected_level, GameState.JOBS[GameState.selected_level - 1].to_upper()]
	%ResultLabel.text = "OPERATION CLEARED" if saved else "OPERATION FAILED"
	%ResultLabel.modulate = Color("#00ff88") if saved else Color("#ff3355")
	%DetailLabel.text = GameState.last_note
	%Reserve.text = _clock(GameState.last_seconds)
	%GreenCount.text = "+5s  x %d" % GameState.green_dots
	%RedCount.text = "-%ds  x %d" % [int(GameState.hit_penalty()), GameState.red_dots]
	%NextPanel.visible = saved and GameState.selected_level == 1
	%NextLevelButton.visible = saved and GameState.selected_level == 1
	%PrimaryButton.text = "Play again" if saved else "Restart job"
	
	for btn: Button in [%PrimaryButton, %HomeButton, %NextLevelButton]:
		btn.mouse_entered.connect(func(): SoundFX.play("ui_tick"))
		btn.focus_entered.connect(func(): SoundFX.play("ui_tick"))
	
	%PrimaryButton.grab_focus()


func _clock(seconds: float) -> String:
	var whole := ceili(maxf(0.0, seconds))
	return "%02d:%02d" % [floori(whole / 60.0), whole % 60]


func _continue_shift() -> void:
	SoundFX.play("ui_click")
	GameState.start_level(GameState.selected_level)


func _start_level_two() -> void:
	SoundFX.play("ui_click")
	GameState.start_level(2)


func _home() -> void:
	SoundFX.play("ui_click")
	get_tree().change_scene_to_file(GameState.HOME)
