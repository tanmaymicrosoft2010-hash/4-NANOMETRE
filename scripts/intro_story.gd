extends Control


func _ready() -> void:
	%NextButton.grab_focus()
	var hard := GameState.selected_world == "SHENZHEN"
	%Address.text = "4 NANO METRE   /   %s" % GameState.site_name().to_upper()
	%StoryLabel.text = "GPU, there is a bomb under the wafer line at the 4 Nano Metre fab. The core door is open. Get there and cut the power.\n\nThe fuse has %s on it. Green dots add 5 seconds. Red dots take %d away. The bridge at Wet bench is out - climb the orange ladder at Etch, then take the green lift." % [
			GameState.clock_text(GameState.fuse_seconds()), int(GameState.hit_penalty())]
	%Subject.text = "Hard shift. The bomb is real." if hard else "The bomb is real."


func _dispatch() -> void:
	get_tree().change_scene_to_file(GameState.FACTORIES)


func _back() -> void:
	get_tree().change_scene_to_file(GameState.HOME)
