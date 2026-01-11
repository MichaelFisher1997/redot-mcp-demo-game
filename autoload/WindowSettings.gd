extends Node

const TOGGLE_FULLSCREEN_ACTION = "toggle_fullscreen"
const TOGGLE_WINDOW_SIZE_ACTION = "toggle_window_size"

var window_sizes = [
	Vector2i(800, 600),
	Vector2i(1024, 768),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]
var current_size_index: int = 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Center the window on startup
	_center_window()

func _input(event: InputEvent):
	if event.is_action_pressed(TOGGLE_FULLSCREEN_ACTION):
		toggle_fullscreen()
	elif event.is_action_pressed(TOGGLE_WINDOW_SIZE_ACTION):
		cycle_window_size()

func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func cycle_window_size():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	current_size_index = (current_size_index + 1) % window_sizes.size()
	var new_size = window_sizes[current_size_index]
	DisplayServer.window_set_size(new_size)
	_center_window()
	print("Window size changed to: ", new_size)

func _center_window():
	var screen_id = DisplayServer.window_get_current_screen()
	var screen_rect = DisplayServer.screen_get_usable_rect(screen_id)
	var window_size = DisplayServer.window_get_size()
	
	var pos = Vector2i(
		screen_rect.position.x + (screen_rect.size.x - window_size.x) / 2,
		screen_rect.position.y + (screen_rect.size.y - window_size.y) / 2
	)
	DisplayServer.window_set_position(pos)
