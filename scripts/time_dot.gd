@tool
extends Area2D

const GREEN := Color("#6cc36d")
const RED := Color("#d4564a")

@export_enum("Green", "Red") var kind := "Green":
	set(value):
		kind = value
		queue_redraw()


func _ready() -> void:
	queue_redraw()
	$Label.text = "+5" if kind == "Green" else "-5"
	if Engine.is_editor_hint():
		return
	var pulse := create_tween().set_loops()
	pulse.tween_property(self, "scale", Vector2(1.08, 1.08), 0.7).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(self, "scale", Vector2.ONE, 0.7).set_trans(Tween.TRANS_SINE)


func _draw() -> void:
	var color := GREEN if kind == "Green" else RED
	draw_circle(Vector2.ZERO, 18.0, color.darkened(0.48))
	draw_circle(Vector2.ZERO, 15.0, color)
	draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 28, color.lightened(0.4), 2.0)
