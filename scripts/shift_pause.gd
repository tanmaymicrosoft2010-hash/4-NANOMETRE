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
	if event.is_action_pressed("pause_shift") or ($Shade.visible and event.is_action_pressed("ui_cancel")):
		get_viewport().set_input_as_handled()
		if $Shade.visible:
			_resume()
		else:
			_take_break()


func _take_break() -> void:
	previous_focus = get_viewport().gui_get_focus_owner()
	%JumpKey.visible = GameState.selected_level == 1
	_label_jump_key()
	var back_path := %Resume.get_path_to(%JumpKey) if %JumpKey.visible else ^"../Leave"
	%Resume.focus_previous = back_path
	%Leave.focus_next = %Leave.get_path_to(%JumpKey) if %JumpKey.visible else ^"../Resume"
	get_tree().paused = true
	$PauseButton.hide()
	$Shade.show()
	%Resume.grab_focus()


func _resume() -> void:
	listening_for_key = false
	get_tree().paused = false
	$Shade.hide()
	$PauseButton.show()
	if is_instance_valid(previous_focus) and previous_focus.is_visible_in_tree():
		previous_focus.grab_focus()


func _leave() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(GameState.FACTORIES if GameState.floor_dispatch else GameState.ORDERS)


func _listen_for_jump() -> void:
	listening_for_key = true
	%JumpKey.text = "Press the new jump key. Esc cancels."


func _label_jump_key() -> void:
	%JumpKey.text = "Change keyboard jump:  " + GameState.jump_key_text
