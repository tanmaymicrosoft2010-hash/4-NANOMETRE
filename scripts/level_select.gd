extends Control

const ACCESS_KEY := preload("res://assets/kenney_simplified-platformer-pack/PNG/Items/platformPack_item014.png")


func _ready() -> void:
	%WorldLabel.text = GameState.site_name()
	%Hazard.text = ("The console dims during a power dip." if GameState.selected_world == "INDIA"
			else "Investor mail interrupts the console.")
	%AccessKey.texture = ACCESS_KEY
	var buttons: Array[Button] = [%L1Button, %L2Button, %L3Button]
	var records: Array[Label] = [%RunRecord, %SortRecord, %TestRecord]
	for i in buttons.size():
		var level := i + 1
		var best := GameState.best_seconds(level)
		records[i].text = "Best reserve: %.1f s" % best if best >= 0.0 else "No time on file"
		buttons[i].pressed.connect(GameState.start_level.bind(level))
	buttons[GameState.selected_level - 1].grab_focus()


func _back() -> void:
	get_tree().change_scene_to_file(GameState.FACTORIES)
