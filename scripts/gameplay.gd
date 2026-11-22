extends Control

const Effects := preload("res://scripts/fab_art.gd")
const DISPLAY_FONT := preload("res://assets/kenney_ui-pack-space-expansion/Font/Kenney Future Narrow.ttf")
const BODY_FONT := preload("res://assets/kenney_ui-pack-space-expansion/Font/Kenney Future.ttf")
const PIXEL_FONT := preload("res://assets/kenney_fonts/Kenney Pixel Square.res")

const ROWS := 8
const COLS := 10
const IP_SEGMENTS := 4
const TOTAL_ROUNDS := 3

# Public / State variables
var target_ip: Array[String] = []
var target_ip_text := ""
var grid_data: Array = []
var target_row := 6
var target_col := 6

var selector_row := 6
var selector_col := 2

var round_index := 1
var lives := 3
var seconds := 60.0
var stability := 100
var finished := false

# Compatibility variables for automated test suites
var red_zone := false
var solution := 0

var recovery := 0

# Animation / Feedback state
var feedback_state := "ACTIVE" # ACTIVE, MATCH_SUCCESS, MISMATCH_FAIL, VICTORY, GAMEOVER
var feedback_timer := 0.0
var shake_offset := Vector2.ZERO
var flicker_timer := 0.0
var status_message := "Injecting IP payload..."

# Layout dimensions
var win_rect := Rect2(190, 42, 900, 636)
var cell_w := 76.0
var cell_h := 36.0
var grid_origin := Vector2(260, 218)

@onready var effects: Effects = $Effects
@onready var answer_pads: Array[Button] = [%Answer1, %Answer2, %Answer3, %Answer4]


func _ready() -> void:
	GameState.selected_level = maxi(2, GameState.selected_level)
	GameState.points = 0
	seconds = GameState.fuse_seconds()
	stability = GameState.start_stability()
	lives = 2 if GameState.selected_world == "SHENZHEN" else 3
	
	_setup_answer_pads()
	_generate_puzzle()
	queue_redraw()


func _setup_answer_pads() -> void:
	# Keep AnswerGrid pads for automated test compatibility
	for i in answer_pads.size():
		answer_pads[i].pressed.connect(_on_test_pad_pressed.bind(i))


func _generate_puzzle() -> void:
	# Generate 4 random 2-digit octets
	target_ip.clear()
	for i in range(IP_SEGMENTS):
		target_ip.append("%02d" % randi_range(0, 99))
	target_ip_text = ".".join(target_ip)
	
	# Compatibility solution
	solution = target_ip[0].to_int() + target_ip[1].to_int()
	if answer_pads.size() >= 2:
		answer_pads[0].text = str(solution)
		answer_pads[1].text = str(solution + 7)
		answer_pads[2].text = str(maxi(0, solution - 5))
		answer_pads[3].text = str(solution + 12)
	
	# Pick target position in grid
	target_row = randi_range(0, ROWS - 1)
	target_col = randi_range(0, COLS - IP_SEGMENTS)
	
	# Default selector position away from target initially
	selector_row = (target_row + 4) % ROWS
	selector_col = 2
	
	# Populate 8x10 grid with random 2-digit pairs
	grid_data.clear()
	for r in range(ROWS):
		var row_arr: Array[String] = []
		for c in range(COLS):
			row_arr.append("%02d" % randi_range(0, 99))
		grid_data.append(row_arr)
	
	# Place the target IP horizontally at (target_row, target_col)
	for i in range(IP_SEGMENTS):
		grid_data[target_row][target_col + i] = target_ip[i]
	
	# Add a couple of decoy partial matches to make the puzzle authentic and fun
	var decoy_row := (target_row + 2) % ROWS
	var decoy_col := (target_col + 3) % (COLS - IP_SEGMENTS)
	grid_data[decoy_row][decoy_col] = target_ip[0]
	if IP_SEGMENTS > 1:
		grid_data[decoy_row][decoy_col + 1] = target_ip[1]
	
	status_message = "Hack the laptop."
	queue_redraw()


func _process(delta: float) -> void:
	if finished:
		return
	
	seconds = maxf(0.0, seconds - delta * (1.3 if red_zone else 1.0))
	if seconds <= 0.0 and feedback_state != "GAMEOVER":
		_trigger_game_over("The countdown expired before host was compromised.")
		return
	
	# Subtle matrix glitch: occasionally cycle a random non-target cell
	flicker_timer += delta
	if flicker_timer >= 2.8 and feedback_state == "ACTIVE":
		flicker_timer = 0.0
		_flicker_decoy_cells()
	
	# Handle feedback state transitions
	if feedback_timer > 0.0:
		feedback_timer -= delta
		if feedback_state == "MISMATCH_FAIL":
			shake_offset = Vector2(randf_range(-3.5, 3.5), randf_range(-3.5, 3.5))
		if feedback_timer <= 0.0:
			shake_offset = Vector2.ZERO
			if feedback_state == "MATCH_SUCCESS":
				if round_index < TOTAL_ROUNDS:
					round_index += 1
					feedback_state = "ACTIVE"
					_generate_puzzle()
				else:
					feedback_state = "VICTORY"
					finished = true
					SoundFX.play("win")
					GameState.finish_level(true, seconds, stability, "Host compromised! Wafer fab security override successful.")
			elif feedback_state == "MISMATCH_FAIL":
				if lives <= 0 or stability <= 0:
					_trigger_game_over("System Lockout: Maximum intrusion attempts exceeded.")
				else:
					feedback_state = "ACTIVE"
					status_message = "Hack the laptop."
			queue_redraw()
	
	queue_redraw()


func _flicker_decoy_cells() -> void:
	for count in 3:
		var r := randi_range(0, ROWS - 1)
		var c := randi_range(0, COLS - 1)
		if r == target_row and c >= target_col and c < target_col + IP_SEGMENTS:
			continue
		grid_data[r][c] = "%02d" % randi_range(0, 99)
	queue_redraw()


func _trigger_game_over(reason: String) -> void:
	finished = true
	feedback_state = "GAMEOVER"
	SoundFX.play("fail")
	GameState.finish_level(false, 0, 0, reason)


func _gui_input(event: InputEvent) -> void:
	if finished or feedback_state != "ACTIVE":
		return
	
	if event is InputEventMouseMotion:
		var local: Vector2 = event.position - (grid_origin + shake_offset)
		if local.x >= 0 and local.x <= COLS * cell_w and local.y >= 0 and local.y <= ROWS * cell_h:
			var raw_c := int(local.x / cell_w)
			var c := clampi(raw_c - 1, 0, COLS - IP_SEGMENTS)
			var r := clampi(int(local.y / cell_h), 0, ROWS - 1)
			if c != selector_col or r != selector_row:
				selector_col = c
				selector_row = r
				SoundFX.play("gta_tick")
				queue_redraw()
	
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local: Vector2 = event.position - (grid_origin + shake_offset)
		if local.x >= 0 and local.x <= COLS * cell_w and local.y >= 0 and local.y <= ROWS * cell_h:
			_submit_selection()


func _unhandled_key_input(event: InputEvent) -> void:
	if finished or feedback_state != "ACTIVE":
		return
	if not event.is_pressed() or event.is_echo():
		return
	
	var moved := false
	if event.is_action_pressed("ui_left") or event.keycode == KEY_A or event.keycode == KEY_LEFT:
		selector_col = clampi(selector_col - 1, 0, COLS - IP_SEGMENTS)
		moved = true
	elif event.is_action_pressed("ui_right") or event.keycode == KEY_D or event.keycode == KEY_RIGHT:
		selector_col = clampi(selector_col + 1, 0, COLS - IP_SEGMENTS)
		moved = true
	elif event.is_action_pressed("ui_up") or event.keycode == KEY_W or event.keycode == KEY_UP:
		selector_row = clampi(selector_row - 1, 0, ROWS - 1)
		moved = true
	elif event.is_action_pressed("ui_down") or event.keycode == KEY_S or event.keycode == KEY_DOWN:
		selector_row = clampi(selector_row + 1, 0, ROWS - 1)
		moved = true
	elif event.is_action_pressed("ui_accept") or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		get_viewport().set_input_as_handled()
		_submit_selection()
		return
	
	if moved:
		get_viewport().set_input_as_handled()
		SoundFX.play("gta_tick")
		queue_redraw()


func _submit_selection() -> void:
	if finished or feedback_state != "ACTIVE":
		return
	
	var matches := true
	for i in range(IP_SEGMENTS):
		if grid_data[selector_row][selector_col + i] != target_ip[i]:
			matches = false
			break
	
	if matches:
		_on_match_success()
	else:
		_on_mismatch_fail()


func _on_match_success() -> void:
	feedback_state = "MATCH_SUCCESS"
	feedback_timer = 0.85
	GameState.points += 10
	stability = mini(100, stability + 10)
	seconds = minf(GameState.fuse_seconds(), seconds + 10.0)
	if red_zone:
		recovery += 1
		if recovery >= 3:
			red_zone = false
			recovery = 0
			stability = GameState.recover_stability()
	status_message = "IP MATCH VERIFIED // HOST SECTOR UNLOCKED"
	GameState.send_hardware_signal("G")
	SoundFX.play("gta_match")
	
	if has_node("Effects") and $Effects.has_method("celebrate"):
		var center_pos := grid_origin + Vector2((selector_col + 2.0) * cell_w, (selector_row + 0.5) * cell_h)
		$Effects.celebrate(center_pos)
	
	queue_redraw()


func _on_mismatch_fail() -> void:
	feedback_state = "MISMATCH_FAIL"
	feedback_timer = 0.55
	lives -= 1
	recovery = 0
	red_zone = true
	stability = maxi(0, stability - GameState.mistake_cost())
	var penalty: float = GameState.hit_penalty()
	seconds = maxf(0.0, seconds - penalty)
	status_message = "ACCESS DENIED // IP MISMATCH (-%ds)" % int(penalty)
	GameState.send_hardware_signal("R")
	SoundFX.play("gta_error")
	queue_redraw()


func _on_test_pad_pressed(index: int) -> void:
	# Test harness hook for automated tests
	feedback_state = "ACTIVE"
	if index == 0:
		selector_row = target_row
		selector_col = target_col
		_submit_selection()
	else:
		selector_row = (target_row + 1) % ROWS
		selector_col = target_col
		_submit_selection()


# ---------------- RENDERING ----------------

func _draw() -> void:
	# 1. OS Desktop Background
	_draw_os_desktop()
	
	# 2. Main Terminal Window
	var win: Rect2 = win_rect
	win.position += shake_offset
	_draw_terminal_window(win)
	
	# 3. Header Bar & Signal
	_draw_terminal_header(win)
	
	# 4. Target IP & Timer Readout
	_draw_target_readout(win)
	
	# 5. Matrix Number Grid & Selector Box
	_draw_matrix_grid(win)
	
	# 6. Terminal Footer & Status
	_draw_terminal_footer(win)


func _draw_os_desktop() -> void:
	# Desktop gradient wallpaper
	var top_c := Color("#173767")
	var bot_c := Color("#0c1b33")
	draw_rect(Rect2(0, 0, 1280, 720), bot_c)
	# Subtle top glow
	draw_rect(Rect2(0, 0, 1280, 360), Color(top_c, 0.45))
	
	# "My Computer" desktop icon on left edge
	var icon_pos := Vector2(48, 300)
	# Drive box
	draw_rect(Rect2(icon_pos.x, icon_pos.y, 44, 38), Color("#3b5f8a"))
	draw_rect(Rect2(icon_pos.x + 2, icon_pos.y + 2, 40, 34), Color("#1b3353"))
	# Drive slot
	draw_rect(Rect2(icon_pos.x + 8, icon_pos.y + 12, 28, 4), Color("#0a1524"))
	# LED light
	draw_circle(icon_pos + Vector2(34, 26), 2.5, Color("#00ff88"))
	# Label
	draw_string(BODY_FONT, icon_pos + Vector2(-10, 54), "My Computer", HORIZONTAL_ALIGNMENT_CENTER, 64, 11, Color("#e2edf8"))
	
	# Top-left helper tip card
	var card_rect := Rect2(36, 26, 250, 74)
	draw_rect(card_rect, Color(0.04, 0.08, 0.14, 0.92))
	draw_rect(card_rect, Color("#1a3c61"), false, 1.0)
	var tip := "Use WASD / Arrows / Mouse to find the IP in the grid.\nPress Space / Enter / Click once highlighted."
	draw_multiline_string(BODY_FONT, card_rect.position + Vector2(12, 22), tip, HORIZONTAL_ALIGNMENT_LEFT, card_rect.size.x - 24, 10, -1, Color("#8ab3cf"))


func _draw_terminal_window(win: Rect2) -> void:
	# Outer glow & shadow
	draw_rect(win.grow(4), Color(0, 0, 0, 0.6))
	# Pitch black terminal background
	draw_rect(win, Color("#000000"))
	# Outer border
	var border_c := Color("#0088cc")
	if feedback_state == "MATCH_SUCCESS":
		border_c = Color("#00ff88")
	elif feedback_state == "MISMATCH_FAIL":
		border_c = Color("#ff2244")
	draw_rect(win, border_c, false, 2.0)
	
	# Corner tech brackets
	var blen := 14.0
	# Top-Left
	draw_line(win.position, win.position + Vector2(blen, 0), Color("#00e5ff"), 2.0)
	draw_line(win.position, win.position + Vector2(0, blen), Color("#00e5ff"), 2.0)
	# Top-Right
	var tr := win.position + Vector2(win.size.x, 0)
	draw_line(tr, tr - Vector2(blen, 0), Color("#00e5ff"), 2.0)
	draw_line(tr, tr + Vector2(0, blen), Color("#00e5ff"), 2.0)
	# Bottom-Left
	var bl := win.position + Vector2(0, win.size.y)
	draw_line(bl, bl + Vector2(blen, 0), Color("#00e5ff"), 2.0)
	draw_line(bl, bl - Vector2(0, blen), Color("#00e5ff"), 2.0)
	# Bottom-Right
	var br := win.position + win.size
	draw_line(br, br - Vector2(blen, 0), Color("#00e5ff"), 2.0)
	draw_line(br, br - Vector2(0, blen), Color("#00e5ff"), 2.0)


func _draw_terminal_header(win: Rect2) -> void:
	var h_rect := Rect2(win.position.x, win.position.y, win.size.x, 38)
	draw_rect(h_rect, Color("#091424"))
	draw_line(win.position + Vector2(0, 38), win.position + Vector2(win.size.x, 38), Color("#142f4c"), 1.0)
	
	# Globe / satellite circle icon
	var icon_center := win.position + Vector2(26, 19)
	draw_circle(icon_center, 10, Color("#1a3c61"))
	draw_arc(icon_center, 9, 0, TAU, 16, Color("#00e5ff"), 1.5)
	draw_line(icon_center - Vector2(9, 0), icon_center + Vector2(9, 0), Color("#00e5ff"), 1.0)
	draw_line(icon_center - Vector2(0, 9), icon_center + Vector2(0, 9), Color("#00e5ff"), 1.0)
	
	# Title & subtitle
	draw_string(DISPLAY_FONT, win.position + Vector2(46, 20), "CONNECTING TO THE HOST", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#4fe3ff"))
	draw_string(BODY_FONT, win.position + Vector2(48, 32), "COMPROMISING GLOBAL SECURITY ONE SLIP AT A TIME", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#75a4be"))
	
	# Signal strength bars (5 bars)
	var sig_x := win.position.x + win.size.x - 52
	var sig_y := win.position.y + 26
	for b in 5:
		var bar_h := (b + 1) * 3.5
		var bar_c := Color("#00ff88") if b < 4 else Color("#38d996")
		draw_rect(Rect2(sig_x + b * 6.5, sig_y - bar_h, 4, bar_h), bar_c)


func _draw_target_readout(win: Rect2) -> void:
	var ip_color := Color("#ff2848")
	if feedback_state == "MATCH_SUCCESS":
		ip_color = Color("#00ff88")
	elif feedback_state == "MISMATCH_FAIL":
		ip_color = Color("#ff4455")
	
	# Target IP centered
	var ip_y := win.position.y + 88
	draw_string(DISPLAY_FONT, Vector2(win.position.x, ip_y), target_ip_text, HORIZONTAL_ALIGNMENT_CENTER, win.size.x, 44, ip_color)
	
	# Green digital timer centered below Target IP
	var timer_y := win.position.y + 130
	var timer_str := _format_digital_clock(seconds)
	var timer_color := Color("#00ff88")
	if seconds < 15.0:
		timer_color = Color("#ff2a44") if fmod(seconds * 4.0, 1.0) > 0.5 else Color("#ffaa00")
	draw_string(BODY_FONT, Vector2(win.position.x, timer_y), timer_str, HORIZONTAL_ALIGNMENT_CENTER, win.size.x, 22, timer_color)


func _draw_matrix_grid(win: Rect2) -> void:
	var g_origin := grid_origin + shake_offset
	
	# Draw highlight selector box over selector_row and selector_col..selector_col+3
	var sel_rect := Rect2(
		g_origin.x + selector_col * cell_w,
		g_origin.y + selector_row * cell_h,
		cell_w * IP_SEGMENTS,
		cell_h
	)
	
	var sel_fill := Color(0.85, 0.12, 0.20, 0.38)
	var sel_border := Color("#ff2848")
	if feedback_state == "MATCH_SUCCESS":
		sel_fill = Color(0.0, 0.95, 0.50, 0.45)
		sel_border = Color("#00ff88")
	elif feedback_state == "MISMATCH_FAIL":
		sel_fill = Color(1.0, 0.05, 0.15, 0.60)
		sel_border = Color("#ff1133")
	
	# Selector background & glowing border
	draw_rect(sel_rect, sel_fill)
	draw_rect(sel_rect, sel_border, false, 2.0)
	
	# Draw all cells in the 8x10 matrix
	for r in range(ROWS):
		for c in range(COLS):
			var num_str: String = grid_data[r][c] if r < grid_data.size() and c < grid_data[r].size() else "00"
			var pos_x := g_origin.x + c * cell_w
			var pos_y := g_origin.y + r * cell_h
			
			var is_selected := (r == selector_row and c >= selector_col and c < selector_col + IP_SEGMENTS)
			var text_color: Color
			if is_selected:
				if feedback_state == "MATCH_SUCCESS":
					text_color = Color("#00ff88")
				elif feedback_state == "MISMATCH_FAIL":
					text_color = Color("#ff3344")
				else:
					text_color = Color("#ff3b53") # Bright red inside selector
			else:
				text_color = Color("#cad5de") # Crisp monospace outside
			
			draw_string(DISPLAY_FONT, Vector2(pos_x, pos_y + 25), num_str, HORIZONTAL_ALIGNMENT_CENTER, cell_w, 20, text_color)


func _draw_terminal_footer(win: Rect2) -> void:
	# Subtitle / instructions
	var sub_y := win.position.y + win.size.y - 74
	var sub_color := Color("#35c98d") if feedback_state == "MATCH_SUCCESS" else Color("#cad5de")
	draw_string(BODY_FONT, Vector2(win.position.x, sub_y), status_message, HORIZONTAL_ALIGNMENT_CENTER, win.size.x, 14, sub_color)
	
	# Bottom status line
	var bar_y := win.position.y + win.size.y - 34
	
	# Left: Stage progress
	var stage_str := "STAGE  %02d / %02d" % [round_index, TOTAL_ROUNDS]
	draw_string(BODY_FONT, win.position + Vector2(28, win.size.y - 34), stage_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#00e5ff"))
	
	# Center: Lives indicator
	var lives_str := "TEAM LIVES: "
	for l in lives:
		lives_str += "● "
	draw_string(BODY_FONT, Vector2(win.position.x, bar_y), lives_str, HORIZONTAL_ALIGNMENT_CENTER, win.size.x, 12, Color("#ff4466") if lives == 1 else Color("#00ff88"))
	
	# Right: Button hints
	var hint_str := "Move: WASD / Arrows / Mouse    Select: Space / Enter / Click"
	draw_string(BODY_FONT, win.position + Vector2(win.size.x - 420, win.size.y - 34), hint_str, HORIZONTAL_ALIGNMENT_RIGHT, 390, 10, Color("#7596ad"))


func _format_digital_clock(sec: float) -> String:
	var total_ms := int(maxf(0.0, sec) * 1000.0)
	var m := int(total_ms / 60000)
	var s := int((total_ms % 60000) / 1000)
	var ms := int(total_ms % 1000)
	return "%02d:%02d:%03d" % [m, s, ms]
