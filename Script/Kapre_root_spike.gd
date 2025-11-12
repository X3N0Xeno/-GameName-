extends Area2D

@export var rise_delay: float = 0.2
@export var active_time: float = 0.75
@onready var shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Face upward visually (since sprite is longer horizontally)
	rotation_degrees = -90

	# Start inactive (underground)
	shape.disabled = true
	await get_tree().create_timer(rise_delay).timeout

	# Spike becomes active
	shape.disabled = false
	print("[RootSpike] Erupted upward!")

	await get_tree().create_timer(active_time).timeout

	# Spike disappears
	shape.disabled = true
	print("[RootSpike] Retracted.")
	queue_free()
	
	var area = $Area2D
	if area:
		area.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))


func get_damage() -> int:
	return 1
