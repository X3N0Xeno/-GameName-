extends Area2D

# =====================
# === CONFIG ==========
# =====================
@export var speed: float = 200.0
@export var turn_rate: float = 2.0       # how quickly it turns toward target (lower = wider arc)
@export var lifetime: float = 3.0        # auto-destroy after this time
@export var startup_delay: float = 0.4  # short pause before moving

# =====================
# === NODES ===========
# =====================
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var player: Node2D = get_node("../../Player")

# =====================
# === STATE ===========
# =====================
var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.RIGHT
var is_active: bool = false

# =====================
# === READY ===========
# =====================
func _ready() -> void:

	# Connect signal manually (ensures it always works)
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

	if player:
		direction = (player.global_position - global_position).normalized()
		rotation = direction.angle()
	
	# Flash before moving
	if sprite:
		sprite.modulate = Color(2, 2, 2)
	
	await get_tree().create_timer(startup_delay).timeout
	
	if sprite:
		sprite.modulate = Color(1, 1, 1)

	is_active = true
	velocity = direction * speed

	# Self-destruct timer
	await get_tree().create_timer(lifetime).timeout
	queue_free()

# =====================
# === PHYSICS =========
# =====================
func _physics_process(delta: float) -> void:
	if not is_active:
		return
	
	if player:
		var desired_dir = (player.global_position - global_position).normalized()
		# Smoothly rotate toward player
		direction = direction.lerp(desired_dir, turn_rate * delta).normalized()
	
	velocity = direction * speed
	global_position += velocity * delta
	rotation = direction.angle()

# =====================
# === COLLISION =======
# =====================
func _on_body_entered(body: Node) -> void:
	
	# Check if it's the player
	if body.name == "HK" or body.is_in_group("player"):
		queue_free()
	
	# Check if it's a TileMap
	elif body.name == "TileMapLayer":
		queue_free()

func get_damage() -> int:
	return 1
