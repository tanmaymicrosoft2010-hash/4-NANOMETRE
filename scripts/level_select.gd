extends Control

const ACCESS_KEY := preload("res://assets/kenney_simplified-platformer-pack/PNG/Items/platformPack_item014.png")


func _ready() -> void:
	%WorldLabel.text = GameState.site_name()
	%Hazard.text = ("Shenzhen Hard Shift: Tighter lockout timer, high security firewall (-8s penalty)." if GameState.selected_world == "SHENZHEN"
			else "Silicon Valley: Standard shift. Find and inject target host IP in matrix.")
	%AccessKey.texture = ACCESS_KEY
	var buttons: Array[Button] = [%L1Button, %L2Button, %L3Button]
	var records: Array[Label] = [%RunRecord, %SortRecord, %TestRecord]
	for i in buttons.size():
		var level := i + 1
		var best := GameState.best_seconds(level)
		records[i].text = "Best reserve: %.1f s" % best if best >= 0.0 else "No record on file"
		var btn: Button = buttons[i]
		btn.mouse_entered.connect(func(): SoundFX.play("ui_tick"))
		btn.focus_entered.connect(func(): SoundFX.play("ui_tick"))
		btn.pressed.connect(func():
			SoundFX.play("ui_click")
			GameState.start_level(level)
		)
	
	%BackButton.mouse_entered.connect(func(): SoundFX.play("ui_tick"))
	%BackButton.pressed.connect(_back)
	buttons[GameState.selected_level - 1].grab_focus()


func _back() -> void:
	SoundFX.play("ui_click")
	get_tree().change_scene_to_file(GameState.FACTORIES)
