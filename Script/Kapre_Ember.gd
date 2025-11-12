extends CharacterBody2D

# --- CONFIG ---
@export var speed_min: float = 20.0   # minimum initial speed
@export var speed_max: float = 100.0   # maximum initial speed
@export var gravity: float = 800.0
@export var rotate_speed: float = 180.0
@export var lifetime: float = 3.0
@export var explosion_duration: float = 0.5

# --- STATE ---
var lifetime_timer: float = 0.0
var exploded: bool = false
var rng := RandomNumberGenerator.new()

# --- NODES ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: CollisionShape2D = $Collision
@onready var explosion_area: Area2D = $Hitbox
@onready var explosion_collision: CollisionShape2D = $Hitbox/CollisionShape2D2

func _ready() -> void:
	rng.randomize()
	lifetime_timer = lifetime

	# --- Randomized launch ---
	var angle_deg = rng.randf_range(20.0, 60.0)      # upward angle
	var angle_rad = deg_to_rad(angle_deg)

	var dir = 1 if rng.randi() % 2 == 0 else -1      # left or right
	var speed = rng.randf_range(speed_min, speed_max) # random speed

	velocity = Vector2(speed * dir * cos(angle_rad), -speed * sin(angle_rad))

	# Flip sprite horizontally
	if sprite:
		sprite.flip_h = dir < 0

	# Hide explosion until triggered
	explosion_area.visible = false
	explosion_area.monitoring = false
	explosion_collision.disabled = true


func _physics_process(delta: float) -> void:
	if exploded:
		return

	# Gravity + motion
	velocity.y += gravity * delta
	move_and_slide()
	rotation_degrees += rotate_speed * delta

	lifetime_timer -= delta
	if lifetime_timer <= 0.0:
		explode()

func _on_body_entered(body: Node) -> void:
	if exploded:
		return
	explode()

func explode() -> void:
	if exploded:
		return
	exploded = true

	hitbox.disabled = true
	explosion_area.visible = true
	explosion_area.monitoring = true
	explosion_collision.disabled = false

	sprite.scale = Vector2(2.5, 2.5)
	sprite.modulate = Color(1.5, 0.5, 0.1)
	sprite.self_modulate = Color(1, 0.6, 0.2)

	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(3, 3), explosion_duration / 2)
	tween.tween_property(sprite, "modulate:a", 0.0, explosion_duration / 2).set_delay(explosion_duration / 2)

	await get_tree().create_timer(explosion_duration).timeout
	queue_free()

func get_damage() -> int:
	return 1
