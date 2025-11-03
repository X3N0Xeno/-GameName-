extends CharacterBody2D

# ======================
# === SANTELMO CONFIG ===
# ======================
@export var hover_height: float = 10.0
@export var hover_speed: float = 1.5
@export var move_speed: float = 120.0

@export var aggro_range: float = 600.0
@export var explode_range: float = 150.0
@export var explode_delay: float = 0.6
@export var explode_linger: float = 1.2
@export var explode_damage: int = 2
@export var death_explode_damage_mult: float = 2
@export var max_hp: int = 20

# ======================
# === NODE REFS ===
# ======================
@onready var player = get_node_or_null("../../HK")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_area: Area2D = $Explosion
@onready var col_attack: CollisionShape2D = $Explosion/Attack
@onready var col_death: CollisionShape2D = $Explosion/Death

# ======================
# === STATE VARS ===
# ======================
var hp: int
var hover_timer: float = 0.0
var is_exploding: bool = false
var is_dead: bool = false

# ======================
# === READY ===
# ======================
func _ready() -> void:
	hp = max_hp
	close_explosion()
	print("[Santelmo] Ready — hovering menace online.")
	if explosion_area:
		explosion_area.connect("body_entered", Callable(self, "_on_explosion_hit"))

# ======================
# === PHYSICS PROCESS ===
# ======================
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if not player:
		_hover_motion(delta)
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	if is_exploding:
		velocity = Vector2.ZERO
		return
	
	if dist <= explode_range:
		start_explosion()
	elif dist <= aggro_range:
		_chase_player(delta)
	else:
		_hover_motion(delta)
	
	move_and_slide()

# ======================
# === MOVEMENT ===
# ======================
func _hover_motion(delta: float):
	hover_timer += delta * hover_speed
	var offset_y = sin(hover_timer) * hover_height
	velocity = Vector2(0, offset_y * 0.5)

func _chase_player(delta: float):
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * move_speed
	sprite.flip_h = velocity.x > 0

# ======================
# === EXPLOSION LOGIC ===
# ======================
func start_explosion():
	if is_exploding or is_dead:
		return
	is_exploding = true
	velocity = Vector2.ZERO

	print("Booom")
	await get_tree().create_timer(explode_delay).timeout
	
	open_attack_explosion()

	await get_tree().create_timer(explode_linger).timeout
	close_explosion()
	is_exploding = false

# ======================
# === DEATH EXPLOSION ===
# ======================
func die():
	if is_dead:
		return
	is_dead = true
	print("[Santelmo] ☠️ Death explosion triggered!")

	open_death_explosion()
	
	await get_tree().create_timer(explode_linger).timeout
	queue_free()

# ======================
# === EXPLOSION AREA CONTROL ===
# ======================
func open_attack_explosion():
	col_attack.disabled = false
	col_death.disabled = true
	explosion_area.monitoring = true
	explosion_area.monitorable = true

func open_death_explosion():
	col_attack.disabled = true
	col_death.disabled = false
	explosion_area.monitoring = true
	explosion_area.monitorable = true

func close_explosion():
	col_attack.disabled = true
	col_death.disabled = true
	explosion_area.monitoring = false
	explosion_area.monitorable = false

# ======================
# === SIGNAL CALLBACK ===
# ======================
func _on_explosion_hit(body: Node) -> void:
	if not body:
		return
	print("I exploded on you")
