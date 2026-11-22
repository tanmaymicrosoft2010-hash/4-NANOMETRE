extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var state = root.get_node("GameState")
	state.selected_level = 2
	change_scene_to_file("res://scenes/gameplay.tscn")
	await scene_changed
	
	var game = current_scene
	if game == null:
		printerr("FAIL: gameplay scene is null")
		quit(1)
		return
	
	# Verify initial state
	if game.grid_data.size() != 8 or game.grid_data[0].size() != 10:
		printerr("FAIL: grid size is not 8x10, got %dx%d" % [game.grid_data.size(), game.grid_data[0].size()])
		quit(1)
		return
	
	if game.target_ip.size() != 4:
		printerr("FAIL: target_ip size is not 4, got %d" % game.target_ip.size())
		quit(1)
		return
	
	print("TEST 1 PASSED: 8x10 grid and 4-octet target IP initialized: ", game.target_ip_text)
	
	# Verify target sequence is present at target_row, target_col
	var tr: int = game.target_row
	var tc: int = game.target_col
	for i in 4:
		if game.grid_data[tr][tc + i] != game.target_ip[i]:
			printerr("FAIL: target IP mismatch in grid at %d,%d" % [tr, tc + i])
			quit(1)
			return
	print("TEST 2 PASSED: Target IP correctly embedded at (%d, %d)" % [tr, tc])
	
	# Test navigation & boundary limits
	game.selector_row = 0
	game.selector_col = 0
	# Move beyond boundaries
	var ev_up := InputEventKey.new()
	ev_up.pressed = true
	ev_up.keycode = KEY_UP
	game._unhandled_key_input(ev_up)
	if game.selector_row != 0:
		printerr("FAIL: selector_row went below 0")
		quit(1)
		return
		
	var ev_left := InputEventKey.new()
	ev_left.pressed = true
	ev_left.keycode = KEY_LEFT
	game._unhandled_key_input(ev_left)
	if game.selector_col != 0:
		printerr("FAIL: selector_col went below 0")
		quit(1)
		return
	print("TEST 3 PASSED: Boundary clamping passed")
	
	# Test Mismatch logic
	var wrong_row: int = (tr + 1) % 8
	game.selector_row = wrong_row
	game.selector_col = tc
	var lives_before: int = game.lives
	game._submit_selection()
	if game.lives != lives_before - 1:
		printerr("FAIL: lives did not decrease on mismatch")
		quit(1)
		return
	print("TEST 4 PASSED: Mismatch correctly penalized life: ", game.lives)
	
	# Test Match logic
	game.feedback_state = "ACTIVE"
	game.selector_row = tr
	game.selector_col = tc
	var pts_before: int = state.points
	game._submit_selection()
	if state.points <= pts_before or game.feedback_state != "MATCH_SUCCESS":
		printerr("FAIL: match was not recognized")
		quit(1)
		return
	print("TEST 5 PASSED: Target IP matched successfully! Points: ", state.points)
	
	print("ALL GTA HACKING UNIT TESTS PASSED!")
	quit(0)
