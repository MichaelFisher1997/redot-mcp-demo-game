extends Control

signal play_pressed
signal difficulty_pressed
signal quit_pressed

@onready var title_label = $VBoxContainer/TitleLabel
@onready var play_button = $VBoxContainer/MarginContainer/PlayButton
@onready var difficulty_button = $VBoxContainer/MarginContainer3/DifficultyButton
@onready var quit_button = $VBoxContainer/MarginContainer4/QuitButton
@onready var high_score_label = $VBoxContainer/MarginContainer2/HighScoreLabel

const NEON_COLORS = {
	title = Color(1.0, 1.0, 0.0, 1.0),
	button_hover = Color(0.0, 1.0, 1.0, 0.8),
	button_normal = Color(0.0, 1.0, 1.0, 0.3),
	button_pressed = Color(1.0, 0.0, 1.0, 0.8),
	difficulty_easy = Color(0.0, 1.0, 0.0, 1.0),
	difficulty_medium = Color(1.0, 1.0, 0.0, 1.0),
	difficulty_hard = Color(1.0, 0.0, 0.0, 1.0)
}

var title_time: float = 0.0
var title_tween: Tween = null

func _ready():
	setup_ui()
	update_difficulty_button()
	update_high_score()

func setup_ui():
	title_label.add_theme_color_override("font_color", NEON_COLORS.title)
	
	play_button.add_theme_color_override("font_color", Color(0, 1, 1, 1))
	difficulty_button.add_theme_color_override("font_color", Color(0, 1, 1, 1))
	quit_button.add_theme_color_override("font_color", Color(0, 1, 1, 1))
	
	play_button.pressed.connect(_on_play_pressed)
	difficulty_button.pressed.connect(_on_difficulty_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _process(delta):
	title_time += delta
	var pulse = 0.8 + 0.2 * sin(title_time * 3.0)
	title_label.modulate.a = pulse

func _on_play_pressed():
	play_pressed.emit()
	get_tree().paused = false
	SceneManager.goto_scene("res://Main.tscn")
	GameState.set_state(GameState.State.PLAYING)
	GameState.reset_scores()

func _on_difficulty_pressed():
	GameState.change_difficulty()
	update_difficulty_button()

func _on_quit_pressed():
	quit_pressed.emit()
	get_tree().quit()

func update_difficulty_button():
	var diff = GameState.difficulty
	var color = NEON_COLORS["difficulty_" + diff]
	difficulty_button.text = "Difficulty: " + diff.capitalize()
	difficulty_button.modulate = color

func update_high_score():
	high_score_label.text = "High Score: " + str(GameState.high_score)
