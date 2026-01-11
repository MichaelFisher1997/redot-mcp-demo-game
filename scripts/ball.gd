extends Area2D
class_name Ball

signal paddle_hit(type)
signal wall_hit()
signal level_up(new_speed)

var INITIAL_SPEED = 300.0
var MAX_SPEED = 1000.0
var SPEED_INCREMENT = 15.0
var hit_count = 0
const HITS_PER_LEVEL = 5

var velocity = Vector2.ZERO
var current_speed = INITIAL_SPEED

@onready var trail: Line2D = $Trail

var particles_scene: PackedScene = null
const TRAIL_LENGTH = 15

func _ready():
	area_entered.connect(_on_area_entered)
	
	if ResourceLoader.exists("res://scenes/CollisionParticles.tscn"):
		particles_scene = load("res://scenes/CollisionParticles.tscn")
	
	# Clear trail on start
	trail.clear_points()
	trail.top_level = true # Make trail independent of ball movement

func _draw():
	# Core pulse
	var core_pulse = 0.8 + 0.2 * sin(Time.get_ticks_msec() * 0.01)
	# Draw a filled circle
	draw_circle(Vector2.ZERO, 10.0 * core_pulse, Color.WHITE)
	# Glow
	draw_circle(Vector2.ZERO, 15.0, Color(1, 1, 0, 0.4))

func _on_area_entered(area):
	if area.is_in_group("paddles"):
		hit_count += 1
		velocity.x = -velocity.x
		var paddle_visual = area.get_node("PaddleVisual")
		var hit_offset = (position.y - area.position.y) / (paddle_visual.size.y / 2)
		
		# Enhanced physics: More influence from hit position, especially at edges (top/bottom 25%)
		var bounce_influence = 100.0
		var bounce_multiplier = 1.0
		if abs(hit_offset) > 0.5:
			bounce_multiplier = 2.5 # Stronger boost to ensure directional override
		
		# Paddle Spin (English): Transfer some of the paddle's vertical velocity to the ball
		var paddle_velocity_influence = area.velocity.y * 0.2
		
		velocity.y += (hit_offset * bounce_influence * bounce_multiplier) + paddle_velocity_influence
		
		# Progressive Speed Ramping
		if hit_count % HITS_PER_LEVEL == 0:
			current_speed += 50.0
			level_up.emit(current_speed)
		else:
			current_speed = min(current_speed + SPEED_INCREMENT, MAX_SPEED)
			
		velocity = velocity.normalized() * current_speed
		
		var paddle_type = "player" if area.name == "PlayerPaddle" else "ai"
		_emit_particles(paddle_type)
		paddle_hit.emit(paddle_type)


func _emit_particles(type: String):
	if particles_scene:
		var particles = particles_scene.instantiate()
		get_parent().add_child(particles)
		particles.emit_at(position, type)
		await particles.tree_exited
		particles.queue_free()

func reset():
	position = get_viewport_rect().size / 2
	current_speed = INITIAL_SPEED
	hit_count = 0
	var angle = randf_range(-PI/4, PI/4)
	if randi() % 2 == 0:
		angle += PI
	velocity = Vector2.RIGHT.rotated(angle) * current_speed
	
	if trail:
		trail.clear_points()

func _process(delta):
	position += velocity * delta
	
	# Update trail
	trail.add_point(position)
	if trail.get_point_count() > TRAIL_LENGTH:
		trail.remove_point(0)
	
	check_wall_collision()
	check_scoring()
	
	# Speed is now handled in _on_area_entered for ramping
	# current_speed = min(current_speed + SPEED_INCREMENT * delta, MAX_SPEED)
	# velocity = velocity.normalized() * current_speed

func check_wall_collision():
	var viewport_size = get_viewport_rect().size
	var radius = 10.0 # Assuming 20x20 circle
	
	if position.y - radius <= 0:
		position.y = radius
		velocity.y = -velocity.y
		wall_hit.emit()
	
	if position.y + radius >= viewport_size.y:
		position.y = viewport_size.y - radius
		velocity.y = -velocity.y
		wall_hit.emit()

func check_scoring():
	var viewport_size = get_viewport_rect().size
	
	if position.x < 0:
		get_parent().on_ball_scored(false)
	elif position.x > viewport_size.x:
		get_parent().on_ball_scored(true)
