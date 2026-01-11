extends Node

enum Sound {
	HIT_PADDLE,
	HIT_WALL,
	SCORE,
	WIN,
	GAME_OVER
}

var volume: float = 0.8

const SOUND_FILES = {
	Sound.HIT_PADDLE: "res://sounds/hit_paddle.wav",
	Sound.HIT_WALL: "res://sounds/hit_wall.wav",
	Sound.SCORE: "res://sounds/score.wav",
	Sound.WIN: "res://sounds/win.wav",
	Sound.GAME_OVER: "res://sounds/game_over.wav"
}

var audio_players = {}

func _ready():
	_setup_audio_players()

func _setup_audio_players():
	for sound in Sound:
		var player = AudioStreamPlayer.new()
		player.volume_db = linear_to_db(volume)
		add_child(player)
		audio_players[sound] = player

func play(sound: Sound):
	if audio_players.has(sound):
		var player = audio_players[sound]
		if ResourceLoader.exists(SOUND_FILES[sound]):
			player.stream = load(SOUND_FILES[sound])
			player.play()
		else:
			print("Sound file not found: ", SOUND_FILES[sound])
			_generate_placeholder_sound(sound)

func _generate_placeholder_sound(sound: Sound):
	match sound:
		Sound.HIT_PADDLE:
			print("♪ HIT PADDLE")
		Sound.HIT_WALL:
			print("♪ HIT WALL")
		Sound.SCORE:
			print("★ SCORE!")
		Sound.WIN:
			print("🏆 YOU WIN!")
		Sound.GAME_OVER:
			print("💀 GAME OVER")

func set_volume(new_volume: float):
	volume = clamp(new_volume, 0.0, 1.0)
	for player in audio_players.values():
		player.volume_db = linear_to_db(volume)

func linear_to_db(linear: float) -> float:
	if linear <= 0.001:
		return -80.0
	return 20.0 * log(linear) / log(10.0)
