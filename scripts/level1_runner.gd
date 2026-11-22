extends Node2D

const Motor := preload("res://scripts/runner_motor.gd")
const Deck := preload("res://scripts/runner_deck.gd")
const FloorStrip := preload("res://scripts/floor_strip.gd")

@export var green_sound: AudioStream
@export var red_sound: AudioStream
@export var fall_sound: AudioStream

@onready var player: Motor = $Player
@onready var hud: FloorStrip = %LineHUD
@onready var feedback: AudioStreamPlayer = $Feedback
@onready var checkpoint := player.position

var seconds := GameState.fuse_seconds()
var immunity := 0.0
var message_time := 0.0
var finished := false
var on_the_clock := false
var wait_for_neutral := false
var trips := 0
var station: StringName = &"Intake"
var hint := "Run right. Jump the gaps. Green dots add 5 seconds."


func _ready() -> void:
	GameState.selected_level = 1
	GameState.points = 0
	GameState.green_dots = 0
	GameState.red_dots = 0
	hud.setup()
	var warm := GameState.selected_world == "SHENZHEN"
	$Sky/Background.color = Color("#3b2c25") if warm else Color("#2d3c3f")
	for deck: Deck in $Track.get_children():
		deck.paint(warm)
	for device: Area2D in $Devices.get_children():
		device.body_entered.connect(_contact.bind(device))
	%TouchControls.visible = DisplayServer.is_touchscreen_available()
	player.set_physics_process(false)
	wait_for_neutral = _moving()
	GameState.floor_controls_changed.connect(_update_control_notes)
	_update_control_notes()


func _update_control_notes() -> void:
	if on_the_clock:
		return
	if %TouchControls.visible:
		%Message.text = "Hold the right arrow to start. Tap Jump at the gaps."
	elif not Input.get_connected_joypads().is_empty():
		%Message.text = "Move the stick or D-pad to start. Jump with the bottom face button."
	else:
		%Message.text = "Move to start.  A/D or arrows: move.  %s or Up: jump." % GameState.jump_key_text


func _moving() -> bool:
	return absf(Input.get_axis("run_left", "run_right")) > 0.0 or Input.is_action_pressed("run_jump")


func _physics_process(delta: float) -> void:
	if finished:
		return
	if not on_the_clock:
		# A carried-over menu press must not clock the player in.
		if wait_for_neutral:
			wait_for_neutral = _moving()
			return
		if not _moving():
			return
		on_the_clock = true
		player.set_physics_process(true)
		%Message.text = hint
	seconds = maxf(0.0, seconds - delta)
	hud.set_clock(seconds)
	if seconds == 0.0:
		_finish(false, "The fuse burned out on the factory floor.")
		return
	if immunity > 0:
		immunity = maxf(0.0, immunity - delta)
		if immunity == 0:
			player.modulate.a = 1.0
	if message_time > 0:
		message_time = maxf(0.0, message_time - delta)
		if message_time == 0:
			%Message.text = hint


func _set_checkpoint(deck: Deck) -> void:
	checkpoint = deck.position + Vector2(48, -26)
	station = deck.name
	%Bay.text = deck.station
	match station:
		&"Inspection":
			hint = "Hot plate ahead. Jump it."
		&"LiftWorks":
			hint = "Jump to the orange ladder and hold right to climb."
		&"Etch":
			hint = "Top of the ladder. Run right and drop to Wet bench."
		&"WetBench":
			hint = "Bridge is out. Step on the green lift and keep holding right."
		&"Transfer":
			hint = "Halfway. Cross the coating line to reach the core."
		&"SpinCoat":
			hint = "Jump the hot plate. Aim for the green dot above it."
		&"Bake":
			hint = "Clear the oven plate, then hold right at the scrubber ladder."
		&"Scrubber":
			hint = "Drop from the far edge to the cooling loop."
		&"Cooling":
			hint = "Ride the green lift over the coolant trench. Keep holding right."
		&"Relay", &"BusBars":
			hint = "Follow the bus bars to the core in Bay 14."
		&"Core":
			hint = "Reach the core door to stop the fuse."
		_:
			hint = "Run right. Jump the gaps. Green dots add 5 seconds."
	if message_time <= 0:
		%Message.text = hint


func _contact(body: Node2D, device: Area2D) -> void:
	if body != player or finished or not on_the_clock:
		return
	if device.is_in_group("time_dots") and not device.is_queued_for_deletion():
		_collect(device)
	elif device.is_in_group("pads") and player.velocity.y >= 0:
		player.board(device)
	elif device.is_in_group("hazards"):
		_damage("Hot plate")
	elif device.is_in_group("goal"):
		_finish(true, "Bomb defused. You reached the core.")


func _collect(dot: Area2D) -> void:
	var green: bool = dot.kind == "Green"
	dot.queue_free()
	_play_feedback(green_sound if green else red_sound)
	if green:
		GameState.green_dots += 1
		seconds = minf(GameState.fuse_seconds(), seconds + 5.0)
		GameState.send_hardware_signal("G")
		_flash("Green dot.  +5 seconds.")
	else:
		GameState.red_dots += 1
		seconds = maxf(0.0, seconds - GameState.hit_penalty())
		GameState.send_hardware_signal("R")
		_flash("Red dot.  -%d seconds." % int(GameState.hit_penalty()))
	hud.set_dots(GameState.green_dots, GameState.red_dots)
	hud.set_clock(seconds)
	if seconds == 0.0:
		_finish(false, "The fuse burned out.")


func _on_return() -> void:
	_flash("Lift launched. Keep holding right.")


func _missed_deck() -> void:
	if finished:
		return
	if immunity > 0:
		player.reset_at.call_deferred(checkpoint)
	else:
		_play_feedback(fall_sound)
		_damage("Missed the landing")


func _play_feedback(clip: AudioStream) -> void:
	feedback.stream = clip
	feedback.play()


func _damage(cause: String) -> void:
	if finished or immunity > 0:
		return
	trips += 1
	seconds = maxf(0.0, seconds - GameState.hit_penalty())
	hud.set_clock(seconds)
	GameState.send_hardware_signal("R")
	if seconds == 0.0:
		_finish(false, "%s. The fuse burned out." % cause)
		return
	immunity = 0.8
	player.modulate.a = 0.55
	player.reset_at.call_deferred(checkpoint)
	_flash("%s.  -%d seconds.  Back to %s." % [cause, int(GameState.hit_penalty()), %Bay.text])


func _flash(note: String) -> void:
	%Message.text = note
	message_time = 2.2


func _finish(saved: bool, note: String) -> void:
	finished = true
	player.set_physics_process(false)
	GameState.finish_level(saved, seconds, 0, note)
