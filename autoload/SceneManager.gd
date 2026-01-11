extends Node

signal transition_started
signal transition_finished

var current_scene: Node = null
var transition_color_rect: ColorRect = null
var tween: Tween = null

const TRANSITION_DURATION = 0.5

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_transition()
	var root = get_tree().root

func _setup_transition():
	if transition_color_rect:
		return
	transition_color_rect = ColorRect.new()
	transition_color_rect.color = Color.BLACK
	transition_color_rect.modulate.a = 0.0
	transition_color_rect.z_index = 1000
	transition_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_color_rect.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child.call_deferred(transition_color_rect)
	transition_color_rect.hide()

func goto_scene(scene_path: String, delay: float = 0.0):
	if not transition_color_rect:
		_setup_transition()
		await get_tree().process_frame
	
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	transition_started.emit()
	transition_color_rect.show()
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(transition_color_rect, "modulate:a", 1.0, TRANSITION_DURATION)
	
	await tween.finished
	
	get_tree().change_scene_to_file(scene_path)
	
	# Small delay to ensure scene is loaded
	await get_tree().process_frame
	
	current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	
	tween = create_tween()
	tween.tween_property(transition_color_rect, "modulate:a", 0.0, TRANSITION_DURATION)
	
	await tween.finished
	
	transition_color_rect.hide()
	transition_finished.emit()
