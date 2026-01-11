extends Control

signal resume_pressed
signal restart_pressed
signal quit_pressed

@onready var resume_button = $VBoxContainer/MarginContainer/ResumeButton
@onready var restart_button = $VBoxContainer/MarginContainer2/RestartButton
@onready var quit_button = $VBoxContainer/MarginContainer3/QuitButton

const PAUSE_INPUT = "pause"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Don't auto-pause here, let the Main scene handle it
	# set_pause()
	
	resume_button.pressed.connect(_on_resume)
	restart_button.pressed.connect(_on_restart)
	quit_button.pressed.connect(_on_quit)

func set_pause():
	get_tree().paused = true

func _on_resume():
	get_tree().paused = false
	GameState.set_state(GameState.State.PLAYING)
	resume_pressed.emit()

func _on_restart():
	get_tree().paused = false
	GameState.set_state(GameState.State.PLAYING)
	GameState.reset_scores()
	SceneManager.goto_scene("res://Main.tscn")

func _on_quit():
	get_tree().paused = false
	SceneManager.goto_scene("res://scenes/MainMenu.tscn")
