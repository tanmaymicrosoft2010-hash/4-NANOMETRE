extends Control


func _ready() -> void:
	%NextButton.grab_focus()
	var hard := GameState.selected_world == "SHENZHEN"
	%Address.text = "4 NANO METRE   /   %s" % GameState.site_name().to_upper()
	%StoryLabel.text = "CEO GPU, an explosive device is armed under the wafer fabrication line at the 4 Nano Metre fab. The cleanroom core airlock is compromised.\n\nThe emergency fuse is burning: %s remaining. Core resistors add 5 seconds; thermal hazards and falls penalize %d seconds. Once you breach the core bay, access the host terminal and brute-force the encryption IP to initiate remote override." % [
			GameState.clock_text(GameState.fuse_seconds()), int(GameState.hit_penalty())]
	%Subject.text = "CRITICAL ALERT: INTRUSION ACTIVE" if hard else "CRITICAL ALERT: DEFUSE PROTOCOL"
	
	for btn: Button in [%NextButton, %BackButton]:
		btn.mouse_entered.connect(func(): SoundFX.play("ui_tick"))
		btn.focus_entered.connect(func(): SoundFX.play("ui_tick"))


func _dispatch() -> void:
	SoundFX.play("ui_click")
	get_tree().change_scene_to_file(GameState.FACTORIES)


func _back() -> void:
	SoundFX.play("ui_click")
	get_tree().change_scene_to_file(GameState.HOME)
