extends Control

const TERMINAL := preload("res://assets/kenney_platformer-pack-industrial/PNG/Default size/platformIndustrial_045.png")
const GRID_SIGN := preload("res://assets/kenney_pixel-platformer-industrial-expansion/Tiles/tile_0042.png")


func _ready() -> void:
	if GameState.floor_dispatch:
		%Kicker.text = "CORE RUN   /   DISPATCH"
		%Terminal.hide()
		%GridSign.hide()
		%WestPaint.show()
		%EastPaint.show()
		%WestNote.text = "Blue steel rail. Cold inspection light.\n" + _floor_record("USA")
		%EastNote.text = "Brown steel rail. Amber work light.\n" + _floor_record("INDIA")
	else:
		%Terminal.texture = TERMINAL
		%GridSign.texture = GRID_SIGN
	var previous: Button = %IndiaButton if GameState.selected_world == "INDIA" else %USAButton
	previous.grab_focus()


func _floor_record(site: String) -> String:
	var best := GameState.best_seconds(1, site)
	return "Best fuse reserve: %.1f s." % best if best >= 0 else "No floor run signed off yet."


func _choose(site: String) -> void:
	GameState.selected_world = site
	if GameState.floor_dispatch:
		GameState.start_level(1)
	else:
		get_tree().change_scene_to_file(GameState.ORDERS)
