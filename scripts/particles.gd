extends GPUParticles2D

const COLORS = {
	"player": Color(0.0, 1.0, 1.0, 1.0),
	"ai": Color(1.0, 0.0, 1.0, 1.0),
	"wall": Color(1.0, 1.0, 1.0, 1.0)
}

func _ready():
	emitting = false

func emit_at(position: Vector2, type: String = "player"):
	global_position = position
	
	var material = create_material(COLORS[type])
	process_material = material
	
	emitting = true
	
	var timer = get_tree().create_timer(0.5)
	await timer.timeout
	emitting = false

func create_material(color: Color) -> ParticleProcessMaterial:
	var material = ParticleProcessMaterial.new()
	material.color = color
	return material
