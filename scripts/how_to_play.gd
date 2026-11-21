extends Control


func _ready() -> void:
	%PlayButton.grab_focus()


func _play() -> void:
	GameState.floor_dispatch = true
	GameState.start_level(1)


func _back() -> void:
	get_tree().change_scene_to_file(GameState.HOME)
