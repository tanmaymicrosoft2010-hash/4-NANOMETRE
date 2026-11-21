extends Control


func _ready() -> void:
	%NextButton.grab_focus()


func _dispatch() -> void:
	get_tree().change_scene_to_file(GameState.FACTORIES)


func _back() -> void:
	get_tree().change_scene_to_file(GameState.HOME)
