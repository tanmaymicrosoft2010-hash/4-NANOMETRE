extends ColorRect


func _ready() -> void:
	# Apply the shared backdrop's anchors after it is instanced into its menu.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
