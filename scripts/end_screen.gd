extends Control


func _ready() -> void:
	var saved := GameState.last_result == "SAVED"
	%Order.text = "LEVEL %02d   /   %s" % [GameState.selected_level, GameState.JOBS[GameState.selected_level - 1].to_upper()]
	%ResultLabel.text = "CLEARED" if saved else "FAILED"
	%ResultLabel.modulate = Color("#24664d") if saved else Color("#a63626")
	%DetailLabel.text = GameState.last_note
	%Reserve.text = _clock(GameState.last_seconds)
	%GreenCount.text = "+5s  x %d" % GameState.green_dots
	%RedCount.text = "-5s  x %d" % GameState.red_dots
	%NextPanel.visible = saved and GameState.selected_level == 1
	%PrimaryButton.text = "Play again" if saved else "Restart job"
	%PrimaryButton.grab_focus()


func _clock(seconds: float) -> String:
	var whole := ceili(maxf(0.0, seconds))
	return "%02d:%02d" % [floori(whole / 60.0), whole % 60]


func _continue_shift() -> void:
	GameState.start_level(GameState.selected_level)


func _home() -> void:
	get_tree().change_scene_to_file(GameState.HOME)
