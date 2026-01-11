extends Control

signal main_menu_pressed
signal play_again_pressed

@onready var winner_label = $VBoxContainer/WinnerLabel
@onready var score_label = $VBoxContainer/MarginContainer2/ScoreLabel
@onready var high_score_label = $VBoxContainer/MarginContainer/HighScoreLabel
@onready var play_again_button = $VBoxContainer/MarginContainer3/PlayAgainButton
@onready var main_menu_button = $VBoxContainer/MarginContainer4/MainMenuButton

var winner: String = ""

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	winner = GameState.last_winner
	_display_results()
	
	GameState.game_over.connect(_on_game_over)
	
	play_again_button.pressed.connect(_on_play_again)
	main_menu_button.pressed.connect(_on_main_menu)

func _on_game_over(result):
	winner = result
	_display_results()

func _display_results():
	if winner == "":
		winner_label.text = "GAME OVER"
	else:
		winner_label.text = winner + " WINS!"
	
	var score_text = str(GameState.player_score) + " - " + str(GameState.ai_score)
	score_label.text = "Final Score: " + score_text
	
	var is_high_score = GameState.player_score >= GameState.WIN_SCORE
	if is_high_score:
		high_score_label.text = "NEW HIGH SCORE: " + str(GameState.player_score)
		high_score_label.modulate = Color.YELLOW
	else:
		high_score_label.text = "High Score: " + str(GameState.high_score)
		high_score_label.modulate = Color.WHITE

func _on_play_again():
	SceneManager.goto_scene("res://Main.tscn")
	GameState.set_state(GameState.State.PLAYING)

func _on_main_menu():
	SceneManager.goto_scene("res://scenes/MainMenu.tscn")
