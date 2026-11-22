extends Control

const Motor := preload("res://scripts/runner_motor.gd")
const Press := preload("res://scripts/return_press.gd")
const Deck := preload("res://scripts/runner_deck.gd")
const START_X := -40.0
const END_X := 1020.0
const PLAYBACK_RATE := 0.8

@onready var stage: Node2D = $Stage
@onready var runner: AnimatedSprite2D = $Stage/Runner
@onready var lift: Press = $Stage/GreenLift
@onready var bench: Deck = $Stage/WetBench
@onready var rack: Deck = $Stage/TestRack
var clock := 0.45


func _ready() -> void:
	bench.paint(false)
	rack.paint(false)
	# The preview has its own caption; don't clip the in-world station labels.
	bench.get_node("Bay").hide()
	rack.get_node("Bay").hide()
	runner.speed_scale = PLAYBACK_RATE


func _process(delta: float) -> void:
	# Show the same approach, press stroke and ballistic arc as the playable bay.
	var board_x := lift.position.x - 60.0
	var run_time := (board_x - START_X) / Motor.SPEED
	var launch_at := run_time + Press.STROKE
	var launch_y := lift.position.y - 2.0
	var air_time := (lift.launch_speed + sqrt(lift.launch_speed ** 2
			- 2.0 * Motor.GRAVITY * (launch_y - rack.position.y))) / Motor.GRAVITY
	var land_at := launch_at + air_time
	var land_x := lift.position.x + Motor.SPEED * air_time
	clock = fmod(clock + delta * PLAYBACK_RATE, land_at + (END_X - land_x) / Motor.SPEED)

	var foot: Vector2
	var pose := &"run"
	if clock < run_time:
		foot = Vector2(START_X + Motor.SPEED * clock, bench.position.y)
	elif clock < launch_at:
		lift.advance(delta * PLAYBACK_RATE)
		foot = stage.to_local(Vector2(lift.global_position.x, lift.boot_height()))
		foot.x = move_toward(board_x, lift.position.x, Motor.SPEED * (clock - run_time))
		pose = &"idle"
	elif clock < land_at:
		if lift.elapsed > 0:
			lift.release()
		var air := clock - launch_at
		foot = Vector2(lift.position.x + Motor.SPEED * air,
				launch_y - lift.launch_speed * air + 0.5 * Motor.GRAVITY * air * air)
		pose = &"jump"
	else:
		foot = Vector2(land_x + Motor.SPEED * (clock - land_at), rack.position.y)
	runner.position = foot - Vector2(0, 25)
	runner.play(pose)
	stage.get_node("Green09").visible = foot.x < stage.get_node("Green09").position.x
	stage.get_node("Green10").visible = foot.x < stage.get_node("Green10").position.x
