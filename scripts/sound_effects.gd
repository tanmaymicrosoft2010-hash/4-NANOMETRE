extends Node
## Audio Engine & Sound Manager
## Uses original meme audio assets + responsive UI navigation sounds.

const SAMPLE_RATE := 22050

# Preload original meme audio streams
const MONEY_SFX: AudioStream = preload("res://assets/audio/money-soundfx.mp3")
const TUCO_SFX: AudioStream = preload("res://assets/audio/tuco-get-out.mp3")
const SPONGEBOB_FAIL: AudioStream = preload("res://assets/audio/spongebob-fail.mp3")
const SAD_VIOLIN: AudioStream = preload("res://assets/audio/meme-violin-sad-violin.mp3")
const GTA_SAN_ANDREAS: AudioStream = preload("res://assets/audio/gta-san-andreas-abertura-oficial.mp3")
const C4_BEEPING: AudioStream = preload("res://assets/audio/c4-beeping.mp3")
const LEAPPAD_MUSIC: AudioStream = preload("res://assets/audio/leappad3-menu-music.mp3")

var _players: Array[AudioStreamPlayer] = []
var _ambient_player: AudioStreamPlayer
var _cache: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(8):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)
	
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Master"
	_ambient_player.volume_db = -16.0
	add_child(_ambient_player)


func play(name: String) -> void:
	var stream: AudioStream = get_stream(name)
	if not stream:
		return
	for p in _players:
		if not p.playing:
			p.stream = stream
			p.volume_db = 0.0
			p.play()
			return
	_players[0].stream = stream
	_players[0].play()


func play_with_volume(name: String, vol_db: float) -> void:
	var stream: AudioStream = get_stream(name)
	if not stream:
		return
	for p in _players:
		if not p.playing:
			p.stream = stream
			p.volume_db = vol_db
			p.play()
			return
	_players[0].stream = stream
	_players[0].volume_db = vol_db
	_players[0].play()


func get_stream(name: String) -> AudioStream:
	match name:
		"green_pickup":
			return MONEY_SFX
		"red_hazard":
			return TUCO_SFX
		"fall":
			return SPONGEBOB_FAIL
		"win":
			return GTA_SAN_ANDREAS
		"fail":
			return SAD_VIOLIN
		"gta_match":
			return MONEY_SFX
		"gta_error":
			return TUCO_SFX
		"c4":
			return C4_BEEPING
		"music":
			return LEAPPAD_MUSIC
	
	# Cache synthesized procedural UI sounds
	if _cache.has(name):
		return _cache[name]
	
	var stream: AudioStreamWAV
	match name:
		"jump":
			stream = _gen_jump()
		"ui_tick":
			stream = _gen_tick(1400.0, 0.02, 0.25)
		"ui_click":
			stream = _gen_click()
		"gta_tick":
			stream = _gen_tick(950.0, 0.025, 0.35)
		_:
			stream = _gen_tick(800.0, 0.03, 0.3)
	
	_cache[name] = stream
	return stream


func start_ambient() -> void:
	if not _ambient_player.playing:
		_ambient_player.stream = LEAPPAD_MUSIC
		_ambient_player.play()


func stop_ambient() -> void:
	if _ambient_player.playing:
		_ambient_player.stop()


# ---------------- Procedural Sound Generators (for UI navigation) ----------------

static func _build_wav(samples: int, generator: Callable) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(SAMPLE_RATE)
		var s: float = generator.call(i, t, samples)
		var val := int(clampf(s, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, val)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = data
	return wav


static func _gen_tick(freq: float, duration: float, vol: float) -> AudioStreamWAV:
	var total := int(SAMPLE_RATE * duration)
	return _build_wav(total, func(i: int, t: float, n: int) -> float:
		var env := 1.0 - (float(i) / float(n))
		return sin(TAU * freq * t) * env * env * vol
	)


static func _gen_click() -> AudioStreamWAV:
	var total := int(SAMPLE_RATE * 0.04)
	return _build_wav(total, func(i: int, t: float, n: int) -> float:
		var env := exp(-float(i) * 0.003)
		var snap := randf_range(-0.5, 0.5) if i < int(SAMPLE_RATE * 0.005) else 0.0
		return (sin(TAU * 1200.0 * t) * 0.5 + snap) * env * 0.4
	)


static func _gen_jump() -> AudioStreamWAV:
	var total := int(SAMPLE_RATE * 0.12)
	return _build_wav(total, func(i: int, t: float, n: int) -> float:
		var prog := float(i) / float(n)
		var freq := lerpf(220.0, 680.0, sqrt(prog))
		var env := 1.0 - prog
		var wave := sin(TAU * freq * t)
		return wave * env * 0.45
	)
