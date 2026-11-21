extends PanelContainer

var shown_tenths := -1


func setup() -> void:
	%Site.text = GameState.site_name().to_upper()
	%Title.text = "L%d / %s" % [GameState.selected_level, GameState.JOBS[GameState.selected_level - 1]]
	set_clock(GameState.BOMB_SECONDS)
	set_line(GameState.START_STABILITY)


func set_clock(seconds: float, accelerated := false) -> void:
	var tenths := ceili(maxf(seconds, 0.0) * 10)
	if tenths != shown_tenths:
		shown_tenths = tenths
		%TimerLabel.text = "%.1f s" % (tenths / 10.0)
	%TimerLabel.modulate = Color("#ff9877") if accelerated or seconds <= 10 else Color.WHITE


func set_line(stability: int) -> void:
	%StabilityBar.value = stability
	%StabilityText.text = "STABILITY   %d%%" % stability
	%PointsLabel.text = "%d / %d" % [GameState.points, GameState.target_points()]
