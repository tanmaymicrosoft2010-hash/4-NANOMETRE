extends CharacterBody2D

signal landed_on(deck: StaticBody2D)
signal fell
signal returned

const ReturnPress := preload("res://scripts/return_press.gd")
const SPEED := 400.0
const GRAVITY := 1900.0
const JUMP := -560.0
const GROUND_ACCEL := 3400.0
const GROUND_BRAKE := 5200.0
const AIR_ACCEL := 1900.0
const FALL_LIMIT := 1200.0
const CLIMB_SPEED := 240.0

var last_floor: StaticBody2D
var press: ReturnPress
var ladder
var climbing := false
var coyote := 0.0
var buffered_jump := 0.0
@onready var chassis: AnimatedSprite2D = $Chassis
@onready var sole: float = $Collider.shape.size.y * 0.5
@onready var ladder_sense: Area2D = $LadderSense


func _ready() -> void:
	ladder_sense.area_entered.connect(_ladder_entered)
	ladder_sense.area_exited.connect(_ladder_exited)


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("run_left", "run_right")
	if direction != 0:
		chassis.flip_h = direction < 0
	if press:
		_ride_press(delta, direction)
		return
	if climbing:
		_climb(delta, direction)
		return
	if ladder and _wants_climb(direction):
		_start_climb()
		_climb(delta, direction)
		return

	var grounded := is_on_floor()
	var acceleration := AIR_ACCEL
	if grounded:
		acceleration = GROUND_BRAKE if is_zero_approx(direction) or direction * velocity.x < 0 else GROUND_ACCEL
	velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * delta)

	coyote = 0.1 if is_on_floor() else maxf(0, coyote - delta)
	buffered_jump = 0.12 if Input.is_action_just_pressed("run_jump") else maxf(0, buffered_jump - delta)
	velocity.y = minf(velocity.y + GRAVITY * delta, FALL_LIMIT)
	if buffered_jump > 0 and coyote > 0 and velocity.y >= 0:
		_launch(JUMP)
	move_and_slide()
	position.x = maxf(18, position.x)
	if not is_on_floor():
		chassis.play(&"jump")
	elif absf(velocity.x) > 20:
		chassis.play(&"run")
	else:
		chassis.play(&"idle")

	if position.y > 775:
		fell.emit()
	elif is_on_floor():
		for i in get_slide_collision_count():
			var contact := get_slide_collision(i)
			var floor_deck := contact.get_collider() as StaticBody2D
			if floor_deck and contact.get_normal().y < -0.8 and floor_deck != last_floor:
				last_floor = floor_deck
				landed_on.emit(floor_deck)


func board(next_press: ReturnPress) -> bool:
	if press or climbing or velocity.y < 0 or global_position.y + sole > next_press.global_position.y + 10:
		return false
	press = next_press
	velocity = Vector2.ZERO
	chassis.play(&"idle")
	return true


func _ride_press(delta: float, direction: float) -> void:
	press.advance(delta)
	global_position.x = move_toward(global_position.x, press.global_position.x, SPEED * delta)
	global_position.y = press.boot_height() - sole
	if press.elapsed >= ReturnPress.STROKE:
		var launch_speed := press.launch_speed
		press.release()
		press = null
		velocity.x = direction * SPEED
		_launch(-launch_speed)
		returned.emit()


func _wants_climb(direction: float) -> bool:
	return direction > 0.2 or Input.is_action_pressed("run_up")


func _start_climb() -> void:
	climbing = true
	velocity = Vector2.ZERO
	coyote = 0.0
	buffered_jump = 0.0
	collision_mask = 0
	global_position.x = ladder.center_x()
	chassis.play(&"idle")


func _climb(delta: float, direction: float) -> void:
	if not is_instance_valid(ladder):
		_stop_climb()
		return
	if Input.is_action_just_pressed("run_jump"):
		_stop_climb()
		_launch(JUMP)
		velocity.x = direction * SPEED
		return
	var step := 0.0
	if Input.is_action_pressed("run_up") or direction > 0.2:
		step = -1.0
	elif Input.is_action_pressed("run_down") or direction < -0.2:
		step = 1.0
	global_position.x = move_toward(global_position.x, ladder.center_x(), 320.0 * delta)
	global_position.y += step * CLIMB_SPEED * delta
	var top: float = ladder.top_y()
	var bottom: float = ladder.global_position.y
	global_position.y = clampf(global_position.y, top - sole, bottom - sole)
	if step < 0.0 and global_position.y <= top - sole + 0.5:
		_stop_climb()
		return
	if step != 0.0:
		chassis.play(&"run")
	else:
		chassis.play(&"idle")


func _stop_climb() -> void:
	climbing = false
	collision_mask = 1
	ladder = null


func _ladder_entered(area: Area2D) -> void:
	if area.is_in_group("ladders"):
		ladder = area


func _ladder_exited(area: Area2D) -> void:
	if area == ladder:
		ladder = null
		if climbing:
			climbing = false
			collision_mask = 1


func reset_at(checkpoint: Vector2) -> void:
	if press:
		press.release()
		press = null
	if climbing:
		_stop_climb()
	position = checkpoint
	velocity = Vector2.ZERO
	buffered_jump = 0
	coyote = 0
	$Camera2D.reset_smoothing()


func _launch(speed: float) -> void:
	velocity.y = speed
	coyote = 0
	buffered_jump = 0
