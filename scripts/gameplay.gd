extends Control

const Effects := preload("res://scripts/fab_art.gd")
const LineHUD := preload("res://scripts/line_hud.gd")
const KEY_ROW := [KEY_1, KEY_2, KEY_3, KEY_4]
const NUMPAD := [KEY_KP_1, KEY_KP_2, KEY_KP_3, KEY_KP_4]
const BENCH := Color("#102122")
const ACCEPT := Color("#a2e9bf")
const REJECT := Color("#ffac89")

@onready var hud: LineHUD = %LineHUD
@onready var pads: Array[Button] = [%Answer1, %Answer2, %Answer3, %Answer4]

var seconds := GameState.BOMB_SECONDS
var stability := GameState.START_STABILITY
var red_zone := false
var recovery := 0
var batch := 0
var solution := 0
var choices: Array[int] = []
var finished := false
var lamp: Tween
var focus_before_mail: Control


func _ready() -> void:
	# Running this scene directly in the editor opens the first console job.
	GameState.selected_level = maxi(2, GameState.selected_level)
	GameState.points = 0
	hud.setup()
	for i in pads.size():
		pads[i].pressed.connect(_submit.bind(i))
	pads[0].grab_focus()
	_deal_batch()


func _process(delta: float) -> void:
	if finished:
		return
	seconds = maxf(0, seconds - delta * (1.5 if red_zone else 1.0))
	hud.set_clock(seconds, red_zone)
	if seconds <= 0:
		_close(false, "The clock ran out before the last batch cleared.")


func _deal_batch() -> void:
	batch += 1
	var limit := 20 + GameState.selected_level * 15
	var a := randi_range(2, limit)
	var b := randi_range(2, limit)
	var task: String
	var equation: String
	match randi_range(0, 2):
		0:
			task = "Two wafer lots, one tray. Count the total."
			equation = "%d + %d" % [a, b]
			solution = a + b
		1:
			task = "Take the rejected dies off the tally."
			equation = "%d − %d" % [maxi(a, b), mini(a, b)]
			solution = absi(a - b)
		_:
			a = randi_range(2, 6 + GameState.selected_level * 2)
			b = randi_range(2, 6 + GameState.selected_level * 2)
			task = "Each tray holds the same number of chips. Count the lot."
			equation = "%d × %d" % [a, b]
			solution = a * b
	%Batch.text = "BATCH   N° %03d" % batch
	%Task.text = task
	%QuestionLabel.text = equation + " = ?"
	choices.assign([solution])
	while choices.size() < pads.size():
		var candidate := randi_range(maxi(0, solution - 12), solution + 12)
		if candidate not in choices:
			choices.append(candidate)
	choices.shuffle()
	for i in pads.size():
		pads[i].text = str(choices[i])


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or finished:
		return
	if %VCPopup.visible:
		if event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			_file_mail()
		return
	var index := KEY_ROW.find(event.keycode)
	if index < 0:
		index = NUMPAD.find(event.keycode)
	if index >= 0:
		get_viewport().set_input_as_handled()
		_submit(index)


func _submit(index: int) -> void:
	if finished or %VCPopup.visible:
		return
	if choices[index] == solution:
		_accept()
	else:
		_reject()
	hud.set_line(stability)
	if stability == 0:
		_close(false, "Stability hit zero. The line shut down.")
	elif GameState.points >= GameState.target_points():
		_close(true, "Last batch signed off. The factory is safe.")
	else:
		_deal_batch()


func _accept() -> void:
	GameState.points += 10
	stability = mini(100, stability + 10)
	GameState.send_hardware_signal("G")
	_feedback("Batch cleared. +10 points.", ACCEPT)
	if not red_zone:
		return
	recovery += 1
	if recovery < 3:
		%LineState.text = "RED ZONE   /   %d OF 3" % recovery
		return
	red_zone = false
	recovery = 0
	stability = 80
	seconds += 10.0
	GameState.send_hardware_signal("B")
	lamp.kill()
	%Background.color = Color("#24553e")
	lamp = create_tween()
	lamp.tween_property(%Background, "color", BENCH, 0.5)
	%LineState.text = "LINE STEADY"
	%LineState.modulate = Color.WHITE
	var origin: Vector2 = %QuestionLabel.get_global_rect().get_center()
	Effects.celebrate($Effects, $Effects.to_local(origin))
	_feedback("Bounce Back!  Stability 80.  Ten seconds back on the clock.", ACCEPT)


func _reject() -> void:
	stability = maxi(0, stability - 25)
	recovery = 0
	_feedback("Batch rejected. The answer was %d.  −25 stability." % solution, REJECT)
	if stability == 0 or (stability > 30 and not red_zone):
		return
	%LineState.text = "RED ZONE   /   0 OF 3"
	%LineState.modulate = REJECT
	_feedback("Red zone. Get three right in a row to slow the clock.", REJECT)
	if red_zone:
		return
	red_zone = true
	GameState.send_hardware_signal("R")
	if lamp:
		lamp.kill()
	lamp = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	lamp.tween_property(%Background, "color", Color("#532d28"), 0.65)
	lamp.tween_property(%Background, "color", Color("#2c2020"), 0.65)


func _feedback(message: String, color: Color) -> void:
	%StatusLabel.text = message
	%StatusLabel.modulate = color


func _interrupt() -> void:
	if finished:
		return
	if GameState.selected_world == "INDIA":
		%FlickerOverlay.show()
		$GridRecovery.start()
	elif not %VCPopup.visible:
		focus_before_mail = get_viewport().gui_get_focus_owner()
		for pad in pads:
			pad.disabled = true
		%VCPopup.show()
		%VCDismissButton.grab_focus()


func _file_mail() -> void:
	%VCPopup.hide()
	for pad in pads:
		pad.disabled = false
	if is_instance_valid(focus_before_mail):
		focus_before_mail.grab_focus()
	else:
		pads[0].grab_focus()


func _close(saved: bool, note: String) -> void:
	finished = true
	GameState.finish_level(saved, seconds, stability, note)
