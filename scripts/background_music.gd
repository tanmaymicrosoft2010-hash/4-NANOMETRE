extends AudioStreamPlayer

const MENU_MUSIC: AudioStream = preload("res://assets/audio/leappad3-menu-music.mp3")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bus = "Master"
	volume_db = -16.0
	stream = MENU_MUSIC
	play()
