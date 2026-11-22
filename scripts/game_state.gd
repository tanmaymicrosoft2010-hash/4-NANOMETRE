extends Node

signal floor_controls_changed

const HOME := "res://scenes/character_select.tscn"
const BRIEFING := "res://scenes/intro_story.tscn"
const FACTORIES := "res://scenes/world_select.tscn"
const ORDERS := "res://scenes/level_select.tscn"
const RUNNER := "res://scenes/level1_runner.tscn"
const MATH_LINE := "res://scenes/gameplay.tscn"
const REPORT := "res://scenes/end_screen.tscn"
const HOW_TO := "res://scenes/how_to_play.tscn"

const BOMB_SECONDS := 300.0
const START_STABILITY := 70
const JOBS := ["Core run", "Host Breach", "Core Override"]
const TARGETS := [100, 150, 200]
const LOG_PATH := "user://shift_log.cfg"
const CURSOR := preload("res://assets/kenney_cursor-pixel-pack/Tiles/tile_0168.png")
const SITES := {
	"USA": {"name": "Silicon Valley", "code": "US / CALIFORNIA", "fuse": 285.0,
			"hit": 6.0, "stability": 70, "mistake": 25, "recover": 80},
	"SHENZHEN": {"name": "Shenzhen", "code": "CN / CHINA", "fuse": 225.0,
			"hit": 8.0, "stability": 60, "mistake": 30, "recover": 70},
}

var selected_world := "USA"
var selected_level := 1
var floor_dispatch := false
var jump_key: Key = KEY_SPACE
var jump_key_text := "Space"
var points := 0
var green_dots := 0
var red_dots := 0
var last_result := "SAVED"
var last_note := ""
var last_seconds := 0.0
var last_stability := 0
var _logbook := ConfigFile.new()


func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR)
	if FileAccess.file_exists(LOG_PATH):
		_logbook.load(LOG_PATH)
		_migrate_site_records()
	AudioServer.set_bus_mute(0, bool(_logbook.get_value("audio", "muted", false)))
	_install_jump_key(int(_logbook.get_value("controls", "jump_key", KEY_SPACE)) as Key)
	jump_key_text = str(_logbook.get_value("controls", "jump_label", OS.get_keycode_string(jump_key)))


func bind_jump(event: InputEventKey) -> bool:
	var key := event.physical_keycode
	if key in [KEY_NONE, KEY_A, KEY_D, KEY_W, KEY_S, KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_P,
			KEY_TAB, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE, KEY_CTRL, KEY_ALT, KEY_META]:
		return false
	_install_jump_key(key)
	var label := event.key_label if event.key_label != KEY_NONE else event.keycode
	jump_key_text = OS.get_keycode_string(key if label == KEY_NONE else label)
	_logbook.set_value("controls", "jump_key", key)
	_logbook.set_value("controls", "jump_label", jump_key_text)
	_logbook.save(LOG_PATH)
	floor_controls_changed.emit()
	return true


func _install_jump_key(key: Key) -> void:
	# Keep Up, touch and the controller binding when replacing the physical key.
	for binding in InputMap.action_get_events("run_jump"):
		if binding is InputEventKey and binding.physical_keycode != KEY_NONE:
			InputMap.action_erase_event("run_jump", binding)
	var replacement := InputEventKey.new()
	replacement.physical_keycode = key
	InputMap.action_add_event("run_jump", replacement)
	jump_key = key


func _exit_tree() -> void:
	Input.set_custom_mouse_cursor(null)


func set_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(0, muted)
	_logbook.set_value("audio", "muted", muted)
	_logbook.save(LOG_PATH)


func site_name() -> String:
	return SITES[selected_world]["name"]


func site_code() -> String:
	return SITES[selected_world]["code"]


func fuse_seconds() -> float:
	return SITES[selected_world]["fuse"]


func hit_penalty() -> float:
	return SITES[selected_world]["hit"]


func start_stability() -> int:
	return SITES[selected_world]["stability"]


func mistake_cost() -> int:
	return SITES[selected_world]["mistake"]


func recover_stability() -> int:
	return SITES[selected_world]["recover"]


func clock_text(seconds: float) -> String:
	var whole := ceili(maxf(0.0, seconds))
	return "%02d:%02d" % [floori(whole / 60.0), whole % 60]


func _migrate_site_records() -> void:
	# Keep times from the old India label when a player first selects Shenzhen.
	var changed := false
	for level in [1, 2, 3]:
		if _logbook.get_value("SHENZHEN", str(level), -1.0) < 0.0:
			var old: float = _logbook.get_value("INDIA", str(level), -1.0)
			if old >= 0.0:
				_logbook.set_value("SHENZHEN", str(level), old)
				changed = true
	if changed:
		_logbook.save(LOG_PATH)


func target_points() -> int:
	return TARGETS[selected_level - 1]


func best_seconds(level: int, site := "") -> float:
	return float(_logbook.get_value(selected_world if site.is_empty() else site, str(level), -1.0))


func start_level(level: int) -> void:
	selected_level = level
	get_tree().change_scene_to_file(RUNNER if level == 1 else MATH_LINE)


func finish_level(saved: bool, seconds: float, stability: int, note: String) -> void:
	last_result = "SAVED" if saved else "FAILED"
	last_note = note
	last_seconds = maxf(0.0, seconds)
	last_stability = stability
	send_hardware_signal("G" if saved else "X")
	if saved and last_seconds > best_seconds(selected_level):
		_logbook.set_value(selected_world, str(selected_level), last_seconds)
		_logbook.save(LOG_PATH)
	# A runner finish can arrive inside a physics overlap callback.
	get_tree().change_scene_to_file.call_deferred(REPORT)


func send_hardware_signal(code: String) -> void:
	if OS.has_feature("web") and code in ["G", "R", "B", "X"]:
		JavaScriptBridge.eval("if(window.sendToArduino) window.sendToArduino('%s');" % code)
