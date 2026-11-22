@tool
extends Area2D

const HANDHOLD := 12.0

@export var height := 204.0:
	set(value):
		height = value
		_fit()


func _ready() -> void:
	_fit()


func _fit() -> void:
	if not is_node_ready():
		return
	$Visual.offset_top = -height - HANDHOLD
	# Keep the two rail tips; tile only the full rung between the end patches.
	var rungs: NinePatchRect = $Visual/Rungs
	rungs.offset_bottom = (height + HANDHOLD) / rungs.scale.y
	var shape := $Collider.shape as RectangleShape2D
	shape.size = Vector2(56, height - 6)
	$Collider.position = Vector2(0, -height * 0.5)


func top_y() -> float:
	return global_position.y - height


func center_x() -> float:
	return global_position.x
