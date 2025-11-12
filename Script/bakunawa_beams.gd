extends Area2D

@export var speed: float = 200.0
@export var lifetime: float = 10
@export var startup_delay: float = 0.4

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var direction: Vector2 = Vector2.RIGHT
var velocity: Vector2 = Vector2.ZERO
var is_active: bool = false

func init(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()
	
	if sprite:
		sprite.modulate = Color(2, 2, 2)
	await get_tree().create_timer(startup_delay).timeout
	if sprite:
		sprite.modulate = Color(1, 1, 1)
	
	is_active = true
	velocity = direction * speed

	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	if not is_active:
		return
	
	global_position += velocity * delta
	rotation = direction.angle()

##COMBAT SYSTEM CODE
func get_damage() -> int:
	return 2
