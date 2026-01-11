extends Node2D
class_name MainGame

@onready var pause_menu = $UI/PauseMenu
@onready var ball = $Ball
@onready var player_paddle = $PlayerPaddle
@onready var ai_paddle = $AIPaddle
@onready var animated_bg = $AnimatedBackground
@onready var grid_node = $Grid

var powerup_scene = preload("res://scenes/PowerUp.tscn")
var powerup_timer: float = 0.0
const POWERUP_SPAWN_INTERVAL = 15.0

const NEON_COLORS = {
	background = Color(0.05, 0.05, 0.1, 1.0),
	player = Color(0.0, 1.0, 1.0, 1.0),
	ai = Color(1.0, 0.0, 1.0, 1.0),
	ball = Color(1.0, 1.0, 0.0, 1.0),
	score = Color(1.0, 1.0, 1.0, 1.0),
	center_line = Color(0.5, 0.5, 0.5, 0.3),
	grid = Color(0.0, 0.5, 1.0, 0.1)
}

var is_paused = false

var shake_intensity: float = 0.0
var shake_duration: float = 0.2
var shake_timer: float = 0.0
const SHAKE_DECAY: float = 15.0

var bg_time: float = 0.0

# Impact flashes
var flashes = [] # [{pos: Vector2, radius: float, alpha: float}]

var player_shield_active = false
var ai_shield_active = false
var can_collect_powerups = false
var paddle_boost_hits = 0 # Remaining hits for paddle boost

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	setup_neon_colors()
	
	GameState.state_changed.connect(_on_state_changed)
	GameState.score_changed.connect(_on_score_changed)
	GameState.game_over.connect(_on_game_over)
	
	ball.paddle_hit.connect(_on_paddle_hit)
	ball.wall_hit.connect(_on_wall_hit)
	ball.level_up.connect(_on_ball_level_up)
	
	pause_menu.hide()
	
	_apply_difficulty_settings()
	reset_game()
	
	# Set up grid drawing
	grid_node.set_script(null) # Ensure no script conflicts
	grid_node.draw.connect(_draw_grid)
	
	# Initial grace period
	_start_grace_period()

func _start_grace_period():
	can_collect_powerups = false
	await get_tree().create_timer(3.0).timeout
	can_collect_powerups = true
	print("Grace period ended. Power-ups can now be collected.")

func _clear_powerups():
	get_tree().call_group("powerups", "queue_free")

func _reset_effects():
	player_shield_active = false
	ai_shield_active = false
	paddle_boost_hits = 0
	# Reset paddle scales if overdrive was active
	player_paddle.scale = Vector2.ONE
	ai_paddle.scale = Vector2.ONE
	player_paddle.SPEED = 400.0
	ai_paddle.AI_SPEED = 350.0

func setup_neon_colors():
	$Background.color = NEON_COLORS.background
	$CenterLine.default_color = NEON_COLORS.center_line
	
	player_paddle.get_node("PaddleVisual").color = NEON_COLORS.player
	ai_paddle.get_node("PaddleVisual").color = NEON_COLORS.ai
	
	$UI/PlayerScore.modulate = NEON_COLORS.player
	$UI/AIScore.modulate = NEON_COLORS.ai

func _apply_difficulty_settings():
	var settings = GameState.get_difficulty_settings()
	ball.INITIAL_SPEED = settings.ball_initial_speed
	ball.MAX_SPEED = settings.ball_max_speed
	ai_paddle.AI_SPEED = settings.ai_speed
	ai_paddle.AI_REACTION_DELAY = settings.ai_reaction

func reset_game():
	GameState.reset_scores()
	update_scores()
	ball.reset()

func update_scores():
	$UI/PlayerScore.text = str(GameState.player_score)
	$UI/AIScore.text = str(GameState.ai_score)

func _on_state_changed(new_state):
	if new_state == GameState.State.PAUSED:
		pause_menu.show()
		get_tree().paused = true
		is_paused = true
	elif new_state == GameState.State.PLAYING:
		pause_menu.hide()
		get_tree().paused = false
		is_paused = false
	elif new_state == GameState.State.GAME_OVER:
		get_tree().paused = false
		SceneManager.goto_scene("res://scenes/GameOver.tscn")

func _on_score_changed(p_score, a_score):
	update_scores()
	add_impact_flash(get_viewport_rect().size / 2, 200.0)
	apply_screen_shake(10.0)

func _on_game_over(winner):
	print("Game Over! Winner: ", winner)
	SoundManager.play(SoundManager.Sound.GAME_OVER)
	if winner == "PLAYER":
		SoundManager.play(SoundManager.Sound.WIN)
	GameState.set_state(GameState.State.GAME_OVER)

func _spawn_powerup():
	print("Spawning power-up...")
	var p = powerup_scene.instantiate()
	p.position = Vector2(
		get_viewport_rect().size.x / 2,
		randf_range(100, get_viewport_rect().size.y - 100)
	)
	p.type = randi() % 5
	p.collected.connect(_on_powerup_collected)
	add_child(p)

func _on_powerup_collected(player_hit: bool, type):
	var target_paddle = player_paddle if player_hit else ai_paddle
	print("Power-up collected by ", "Player" if player_hit else "AI", ": ", type)
	
	match type:
		0: # OVERDRIVE
			_apply_overdrive(target_paddle)
		1: # TIME_WARP
			_apply_time_warp()
		2: # SHIELD
			_apply_shield(player_hit)
		3: # FAST_BALL
			_apply_fast_ball()
		4: # PADDLE_BOOST
			_apply_paddle_boost()

func _apply_overdrive(paddle):
	var original_scale = paddle.scale
	var original_speed = paddle.SPEED if "SPEED" in paddle else paddle.AI_SPEED
	
	paddle.scale.y = 2.0
	if "SPEED" in paddle: paddle.SPEED *= 1.5
	if "AI_SPEED" in paddle: paddle.AI_SPEED *= 1.5
	
	await get_tree().create_timer(8.0).timeout
	
	paddle.scale = original_scale
	if "SPEED" in paddle: paddle.SPEED = 400.0
	if "AI_SPEED" in paddle: paddle.AI_SPEED = 350.0

func _apply_time_warp():
	var original_speed = ball.current_speed
	ball.current_speed *= 0.5
	ball.velocity = ball.velocity.normalized() * ball.current_speed
	
	await get_tree().create_timer(5.0).timeout
	
	ball.current_speed = original_speed
	ball.velocity = ball.velocity.normalized() * ball.current_speed

func _apply_shield(is_player: bool):
	if is_player:
		player_shield_active = true
		await get_tree().create_timer(10.0).timeout
		player_shield_active = false
	else:
		ai_shield_active = true
		await get_tree().create_timer(10.0).timeout
		ai_shield_active = false

func _apply_fast_ball():
	ball.current_speed *= 2.0
	ball.velocity = ball.velocity.normalized() * ball.current_speed
	add_impact_flash(ball.position, 100.0)

func _apply_paddle_boost():
	paddle_boost_hits = 5
	print("Paddle boost active! Next 5 hits will be extra fast.")

func on_ball_scored(player_won):
	if not player_won and player_shield_active:
		print("Player shield blocked score!")
		ball.reset()
		player_shield_active = false # Consume shield
		return
	if player_won and ai_shield_active:
		print("AI shield blocked score!")
		ball.reset()
		ai_shield_active = false
		return
		
	GameState.add_score(player_won)
	SoundManager.play(SoundManager.Sound.SCORE)
	
	# Reset everything on score
	_clear_powerups()
	_reset_effects()
	ball.reset()
	_start_grace_period()

func _on_paddle_hit(type):
	SoundManager.play(SoundManager.Sound.HIT_PADDLE)
	apply_screen_shake(5.0)
	add_impact_flash(ball.position, 50.0)
	
	if paddle_boost_hits > 0:
		paddle_boost_hits -= 1
		ball.current_speed += 100.0
		ball.velocity = ball.velocity.normalized() * ball.current_speed
		add_impact_flash(ball.position, 80.0)
		print("Paddle boost! Hits remaining: ", paddle_boost_hits)

func _on_wall_hit():
	SoundManager.play(SoundManager.Sound.HIT_WALL)
	apply_screen_shake(2.0)
	add_impact_flash(ball.position, 30.0)

func _on_ball_level_up(new_speed):
	print("Level Up! New speed: ", new_speed)
	add_impact_flash(get_viewport_rect().size / 2, 500.0)
	apply_screen_shake(15.0)
	# Maybe flash the whole background briefly
	var tween = create_tween()
	tween.tween_property(animated_bg, "color", Color.WHITE, 0.1)
	tween.tween_property(animated_bg, "color", NEON_COLORS.background, 0.4)

func _process(delta):
	# Update flashes even when playing
	if GameState.current_state == GameState.State.PLAYING:
		_update_flashes(delta)
		_animate_background(delta)
		_apply_screen_shake(delta)
		grid_node.queue_redraw()
		queue_redraw() # For flashes
		
		# Power-up spawning
		powerup_timer += delta
		if powerup_timer >= POWERUP_SPAWN_INTERVAL:
			powerup_timer = 0.0
			_spawn_powerup()
	
	if GameState.current_state != GameState.State.PLAYING:
		return
	
	var player_direction = Input.get_axis("player_up", "player_down")
	player_paddle.velocity.y = player_direction * player_paddle.SPEED

func _animate_background(delta):
	bg_time += delta
	var pulse = 0.95 + 0.05 * sin(bg_time * 0.5)
	animated_bg.color = NEON_COLORS.background * pulse

func apply_screen_shake(intensity: float):
	shake_intensity = intensity
	shake_timer = 0.0

func _apply_screen_shake(delta):
	if shake_intensity > 0:
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		position = shake_offset
		shake_intensity = move_toward(shake_intensity, 0, SHAKE_DECAY * delta)
	else:
		position = Vector2.ZERO

func add_impact_flash(pos: Vector2, max_radius: float):
	flashes.append({
		"pos": pos,
		"radius": 0.0,
		"max_radius": max_radius,
		"alpha": 1.0
	})

func _update_flashes(delta):
	var to_remove = []
	for i in range(flashes.size()):
		var f = flashes[i]
		f.radius += 500.0 * delta
		f.alpha -= 2.0 * delta
		if f.alpha <= 0:
			to_remove.append(i)
	
	for i in range(to_remove.size() - 1, -1, -1):
		flashes.remove_at(to_remove[i])

func _draw():
	for f in flashes:
		draw_arc(f.pos, f.radius, 0, TAU, 32, Color(1, 1, 1, f.alpha), 2.0)

func _draw_grid():
	var viewport_size = get_viewport_rect().size
	var spacing = 50
	var offset = fmod(bg_time * 20.0, spacing)
	
	for x in range(0, viewport_size.x + spacing, spacing):
		grid_node.draw_line(Vector2(x, 0), Vector2(x, viewport_size.y), NEON_COLORS.grid, 1.0)
	
	for y in range(0, viewport_size.y + spacing, spacing):
		grid_node.draw_line(Vector2(0, y), Vector2(viewport_size.x, y), NEON_COLORS.grid, 1.0)

func _input(event):
	if event.is_action_pressed("pause"):
		if GameState.current_state == GameState.State.PLAYING:
			GameState.set_state(GameState.State.PAUSED)
		elif GameState.current_state == GameState.State.PAUSED:
			GameState.set_state(GameState.State.PLAYING)
