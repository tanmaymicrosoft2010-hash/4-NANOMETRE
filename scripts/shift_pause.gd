extends CanvasLayer

var previous_focus: Control
var listening_for_key := false


func _input(event: InputEvent) -> void:
	if not listening_for_key:
		return
	if event.is_action_pressed("ui_cancel"):
		listening_for_key = false
		_label_jump_key()
	elif event is InputEventKey and event.pressed and not event.echo:
		if GameState.bind_jump(event):
			listening_for_key = false
			_label_jump_key()
		else:
			%JumpKey.text = "Reserved key. Try another, or Esc to cancel."
	else:
		return
	get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_shift") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if $Shade.visible:
			_resume()
		else:
			_take_break()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and OS.has_feature("web") and is_node_ready():
		if not get_tree().paused and not $Shade.visible:
			_take_break()


func _ready() -> void:
	for btn: Button in [%Resume, %Leave, %JumpKey]:
		btn.mouse_entered.connect(func(): SoundFX.play("ui_tick"))
		btn.focus_entered.connect(func(): SoundFX.play("ui_tick"))


func _take_break() -> void:
	SoundFX.play("ui_click")
	previous_focus = get_viewport().gui_get_focus_owner()
	%JumpKey.visible = GameState.selected_level == 1
	_label_jump_key()
	%Resume.focus_previous = %Resume.get_path_to(%JumpKey) if %JumpKey.visible else ^"../Leave"
	%Leave.focus_next = %Leave.get_path_to(%JumpKey) if %JumpKey.visible else ^"../Resume"
	get_tree().paused = true
	$PauseButton.hide()
	$Shade.show()
	%Resume.grab_focus()


func _resume() -> void:
	SoundFX.play("ui_click")
	listening_for_key = false
	get_tree().paused = false
	$Shade.hide()
	$PauseButton.show()
	if is_instance_valid(previous_focus) and previous_focus.is_visible_in_tree():
		previous_focus.grab_focus()


func _leave() -> void:
	SoundFX.play("ui_click")
	get_tree().paused = false
	get_tree().change_scene_to_file(GameState.HOME)


func _listen_for_jump() -> void:
	listening_for_key = true
	%JumpKey.text = "Press the new jump key. Esc cancels."


func _label_jump_key() -> void:
	%JumpKey.text = "Change keyboard jump:  " + GameState.jump_key_text
