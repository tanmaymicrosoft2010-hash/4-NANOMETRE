extends PanelContainer

var shown := -1


func setup() -> void:
	%LevelTag.text = "LEVEL %02d" % GameState.selected_level
	%Site.text = "CORE RUN"
	set_clock(GameState.fuse_seconds())
	set_dots(GameState.green_dots, GameState.red_dots)


func set_clock(seconds: float) -> void:
	var whole := ceili(maxf(0.0, seconds))
	if whole == shown:
		return
	shown = whole
	%TimerLabel.text = "%02d:%02d" % [floori(whole / 60.0), whole % 60]
	%TimerLabel.add_theme_color_override("font_color",
			Color("#ff2a44") if seconds <= mini(30.0, GameState.fuse_seconds() * 0.15) else Color("#00ff88"))


func set_dots(green: int, red: int) -> void:
	%GreenLabel.text = "GREEN  %d" % green
	%RedLabel.text = "RED  %d" % red
