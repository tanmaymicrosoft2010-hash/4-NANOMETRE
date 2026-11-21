@tool
extends Node2D

@export var sheet: Texture2D:
	set(value):
		sheet = value
		queue_redraw()

# Source rectangles from Kenney's platformIndustrial_sheet.xml.
const TOP := Rect2(140, 260, 70, 70)
const WALL := Rect2(70, 117, 70, 70)
const ARROW := Rect2(490, 0, 58, 50)
const BLUE_BIN := Rect2(490, 290, 50, 70)
const GRATE := Rect2(0, 0, 70, 70)
const STRIPE := Rect2(210, 517, 70, 18)

func _piece(tile: Rect2, x: float, y: float, w: float, h: float) -> void:
	draw_texture_rect_region(sheet, Rect2(x, y, w, h), tile)

func _bank(x: float, y: float, columns: int, rows: int) -> void:
	for col in columns:
		for row in rows:
			_piece(TOP if row == 0 else WALL, x + col * 80, y + row * 80, 80, 80)

func _draw() -> void:
	if not sheet:
		return
	# A ladder up to the console, then bins and a striped maintenance trolley.
	_bank(0, 482, 5, 3)
	_bank(400, 343, 3, 4)
	_bank(640, 422, 3, 3)
	_bank(1040, 422, 3, 3)
	_piece(Rect2(540, 100, 50, 70), 495, 230, 45, 113)
	_piece(Rect2(210, 0, 140, 70), 416, 204, 205, 94)
	_piece(BLUE_BIN, 692, 352, 50, 70)
	_piece(BLUE_BIN, 750, 352, 50, 70)
	_piece(GRATE, 880, 422, 80, 80)
	_piece(GRATE, 960, 422, 80, 80)
	_piece(Rect2(420, 92, 70, 40), 82, 266, 137, 48)
	_piece(Rect2(420, 92, 70, 40), 821, 209, 177, 48)
	_piece(Rect2(490, 360, 50, 70), 933, 148, 44, 61)
	_piece(ARROW, 150, 385, 58, 50)
	_piece(ARROW, 815, 290, 58, 50)
	for i in 3:
		_piece(STRIPE, 1064 + i * 72, 332, 72, 18)
	_piece(Rect2(210, 419, 70, 70), 1100, 308, 68, 68)
