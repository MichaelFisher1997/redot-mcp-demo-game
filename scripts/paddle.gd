extends Area2D

var SPEED = 400.0
@onready var visual = $PaddleVisual
var velocity = Vector2.ZERO

func _ready():
	add_to_group("paddles")
	print("Paddle ready - monitoring: ", monitoring, " monitorable: ", monitorable)
	print("Paddle collision_layer: ", collision_layer, " mask: ", collision_mask)
	print("Paddle groups: ", get_groups())

func _physics_process(delta):
	position.y += velocity.y * delta
	var viewport_height = get_viewport_rect().size.y
	var paddle_height = visual.size.y
	position.y = clamp(position.y, paddle_height / 2, viewport_height - paddle_height / 2)
