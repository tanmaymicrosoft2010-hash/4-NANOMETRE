extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	# A missing button connection or script can otherwise leave scene_changed pending.
	create_timer(10.0).timeout.connect(func():
		printerr("Timed out waiting for the exported game to change scenes.")
		quit(1))
	var state = root.get_node("GameState")
	root.get_node("BackgroundMusic").stop()
	for site in ["USA", "SHENZHEN"]:
		var problem := await _check_site(state, site)
		if not problem.is_empty():
			printerr("%s: %s" % [site, problem])
			quit(1)
			return
		print("%s: factory selection, Level 2 and recovery effect passed" % site)
	quit()


func _check_site(state, site: String) -> String:
	change_scene_to_file(state.HOME)
	await scene_changed
	var card := current_scene.get_node_or_null("%SiliconButton" if site == "USA" else "%ShenzhenButton") as Button
	if not card:
		return "Factory button missing from the homepage."
	card.pressed.emit()
	await scene_changed
	if current_scene.scene_file_path != state.RUNNER or state.selected_world != site:
		return "Factory button did not start the selected run."

	# Stage the clear screen without writing a best time to the player's logbook.
	state.last_result = "SAVED"
	change_scene_to_file(state.REPORT)
	await scene_changed
	var next := current_scene.get_node("%NextLevelButton") as Button
	if not next.is_visible_in_tree():
		return "Start Level 2 is hidden."
	next.pressed.emit()
	await scene_changed
	var console = current_scene
	if console.scene_file_path != state.MATH_LINE or console.get("solution") == null:
		return "The wafer-sort console did not load."
	for miss in 2:
		if console.red_zone:
			break
		_answer(console, false)
	for hit in 3:
		_answer(console, true)
	if state.points != 30 or console.red_zone:
		return "Answer pads did not complete recovery."
	for spark in console.get_node("Effects").get_children():
		if spark is Sprite2D and spark.texture != null and spark.texture.get_width() > 0:
			return ""
	return "Recovery did not produce a textured spark."


func _answer(console, right: bool) -> void:
	for pad: Button in console.get_node("%AnswerGrid").get_children():
		if (pad.text.to_int() == console.solution) == right:
			pad.pressed.emit()
			return
