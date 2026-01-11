extends Node

signal state_changed(new_state)
signal score_changed(player_score, ai_score)
signal game_over(winner)

enum State {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state: State = State.MAIN_MENU
var player_score: int = 0
var ai_score: int = 0
var last_winner: String = ""
const WIN_SCORE: int = 10

var difficulty: String = "medium"
const DIFFICULTIES = ["easy", "medium", "hard"]
const DIFFICULTY_SETTINGS = {
	"easy": {
		"ai_speed": 250.0,
		"ai_reaction": 0.2,
		"ball_initial_speed": 250.0,
		"ball_max_speed": 450.0
	},
	"medium": {
		"ai_speed": 350.0,
		"ai_reaction": 0.1,
		"ball_initial_speed": 300.0,
		"ball_max_speed": 600.0
	},
	"hard": {
		"ai_speed": 450.0,
		"ai_reaction": 0.05,
		"ball_initial_speed": 350.0,
		"ball_max_speed": 750.0
	}
}

var high_score: int = 0
const SAVE_FILE_PATH = "user://neon_pong_save.dat"

func _ready():
	load_high_score()

func set_state(new_state: State):
	current_state = new_state
	state_changed.emit(new_state)
	print("Game state changed to: ", State.keys()[new_state])

func get_difficulty_settings():
	return DIFFICULTY_SETTINGS[difficulty]

func add_score(player: bool):
	if player:
		player_score += 1
	else:
		ai_score += 1
	
	score_changed.emit(player_score, ai_score)
	
	if player_score >= WIN_SCORE or ai_score >= WIN_SCORE:
		last_winner = "PLAYER" if player_score >= WIN_SCORE else "AI"
		set_state(State.GAME_OVER)
		game_over.emit(last_winner)
		if player_score > high_score:
			high_score = player_score
			save_high_score()

func reset_scores():
	player_score = 0
	ai_score = 0
	score_changed.emit(player_score, ai_score)

func change_difficulty():
	var current_index = DIFFICULTIES.find(difficulty)
	var next_index = (current_index + 1) % DIFFICULTIES.size()
	difficulty = DIFFICULTIES[next_index]
	print("Difficulty changed to: ", difficulty)

func save_high_score():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score)
		file.close()

func load_high_score():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_32()
			file.close()
