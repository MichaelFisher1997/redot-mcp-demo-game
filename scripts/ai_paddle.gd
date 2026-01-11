extends "res://scripts/paddle.gd"

var AI_SPEED = 350.0
var AI_REACTION_DELAY = 0.1
var ball_y_target = 0
var reaction_timer = 0.0

func _physics_process(delta):
	var ball_node = get_parent().get_node("Ball")
	if not ball_node: return
	
	reaction_timer += delta
	
	# Human-like reaction fluctuations
	var current_ball_speed = ball_node.current_speed
	var adjusted_reaction_delay = AI_REACTION_DELAY
	
	# AI "Panics" if ball is fast and coming at it
	var is_ball_approaching = ball_node.velocity.x > 0
	if is_ball_approaching and current_ball_speed > 600.0:
		# Reduce reaction delay but add inaccuracy
		adjusted_reaction_delay *= 0.5
	
	if reaction_timer >= adjusted_reaction_delay:
		reaction_timer = 0.0
		# Add a bit of noise to target position
		var error_margin = 0.0
		if current_ball_speed > 500.0:
			error_margin = randf_range(-30, 30)
			
		ball_y_target = ball_node.position.y + error_margin
	
	var diff = ball_y_target - position.y
	
	# Only move if ball is on AI's side or coming towards it
	if is_ball_approaching or ball_node.position.x > get_viewport_rect().size.x / 2:
		velocity.y = sign(diff) * AI_SPEED
		if abs(diff) < 10:
			velocity.y = 0
	else:
		# Return to center slowly
		var center_y = get_viewport_rect().size.y / 2
		var to_center = center_y - position.y
		velocity.y = sign(to_center) * (AI_SPEED * 0.5)
		if abs(to_center) < 10:
			velocity.y = 0
	
	super._physics_process(delta)
