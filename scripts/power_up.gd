extends Area2D
class_name PowerUp

enum Type { OVERDRIVE, TIME_WARP, SHIELD, FAST_BALL, PADDLE_BOOST }

var type: int = 0
var color: Color = Color.WHITE
var time_alive: float = 0.0

signal collected(player_hit, type)

func _ready():
	add_to_group("powerups")
	# Randomize type on spawn if not set
	_setup_visuals()
	
	area_entered.connect(_on_area_entered)
	
	# Spawn animation
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _setup_visuals():
	match type:
		Type.OVERDRIVE:
			color = Color(1, 0.5, 0, 1) # Orange
		Type.TIME_WARP:
			color = Color(0, 1, 1, 1) # Cyan
		Type.SHIELD:
			color = Color(0.5, 0, 1, 1) # Purple
		Type.FAST_BALL:
			color = Color(1, 0, 0, 1) # Red
		Type.PADDLE_BOOST:
			color = Color(0, 1, 0, 1) # Green

func _process(delta):
	time_alive += delta
	queue_redraw()
	
	# Float up and down
	position.y += sin(time_alive * 2.0) * 0.5

func _draw():
	var points = []
	var sides = 6
	var radius = 20.0
	for i in range(sides):
		var angle = i * TAU / sides
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	
	# Draw glow
	draw_polyline(points + [points[0]], color * 0.5, 4.0)
	draw_polyline(points + [points[0]], Color.WHITE, 1.5)
	
	# Internal pulse
	var pulse = 0.3 + 0.2 * sin(time_alive * 5.0)
	draw_colored_polygon(points, Color(color.r, color.g, color.b, pulse))

func _on_area_entered(area):
	if area.name == "Ball":
		var main_scene = get_parent()
		if "can_collect_powerups" in main_scene and not main_scene.can_collect_powerups:
			return
			
		# First player to hit it gets it? Or based on who hit the ball last?

		# Let's say: based on ball's velocity direction
		var player_hit = area.velocity.x > 0 # If moving right, player (on left) hit it last
		collected.emit(player_hit, type)
		
		# Feedback
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await tween.finished
		queue_free()
