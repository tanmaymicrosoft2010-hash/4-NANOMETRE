@tool
extends StaticBody2D

# The collision, painted edge and checkpoint all use the left edge as their origin.
@export_range(100, 1000) var width := 640:
	set(value):
		width = value
		if is_node_ready():
			_fit_deck()
@export var station := "01  Intake":
	set(value):
		station = value
		if is_node_ready():
			$Bay.text = station
@export var label_indent := 20.0:
	set(value):
		label_indent = value
		if is_node_ready():
			$Bay.offset_left = label_indent


func _ready() -> void:
	_fit_deck()
	$Bay.text = station
	$Bay.offset_left = label_indent


func paint(warm: bool) -> void:
	$Deck.modulate = Color("#ffe7cb") if warm else Color.WHITE
	$Rim.color = Color("#eab586") if warm else Color("#dc9c72")


func _fit_deck() -> void:
	var shape: RectangleShape2D = $Collider.shape
	shape.size = Vector2(width, 52)
	$Collider.position = shape.size * 0.5
	$Deck.size.x = width
	$Rim.size.x = width
	$FarSupport.position.x = width - 44
