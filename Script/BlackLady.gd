extends CharacterBody2D

# =====================
# === CONFIG ==========
# =====================
@export var max_hp: int = 250
@export var phase2_threshold: int = 75
var chain_attack_active: bool = false
@export var move_speed: float = 50.0
@export var dash_speed: float = 300.0
@export var attack_cooldown: float = 1.0  # slightly faster

# Home position (fixed)
var home_position: Vector2

# =====================
# === Scenes ==========
# =====================
@export var SBall_Scene: PackedScene = preload("res://Scene/SBall.tscn")
@export var SBeam_Scene: PackedScene = preload("res://Scene/SBeam.tscn")

# =====================
# === NODES ===========
# =====================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area: Area2D = $Area2D
@onready var col_contact: CollisionShape2D = $"Hitbox/Contact Collision"
@onready var col_down: CollisionShape2D = $Hitbox/DownSlash
@onready var projectile_spawn: Marker2D = $Node/ProjectileSpawn
@onready var pillar_spawn: Marker2D = $Node/PillarSpawn
@onready var player: Node2D = get_node("../../Player")

# =====================
# === STATE ===========
# =====================
var hp: int
var phase: int = 1
var is_attacking: bool = false
var attack_timer: float = 0.0
var rng := RandomNumberGenerator.new()

# =====================
# === READY ===========
# =====================
func _ready() -> void:
	hp = max_hp
	rng.randomize()
	home_position = global_position
	print("[Black Lady] Ready at home position:", home_position)
	
	var area = $Area2D
	if area:
		area.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))
	sprite.play("Idle")

# =====================
# === PROCESS ========
# =====================
func _process(delta: float) -> void:
	if hp <= 0 or not player:
		return
	
	handle_phase()

	# Flip sprite when not attacking
	if not is_attacking and sprite:
		sprite.flip_h = player.global_position.x < global_position.x

	# Cooldown cycle
	if not is_attacking and not chain_attack_active:
		attack_timer -= delta
		if attack_timer <= 0.0:
			await pick_attack()

# =====================
# === PHASE CONTROL ===
# =====================
func handle_phase() -> void:
	if hp <= phase2_threshold and phase == 1:
		phase = 2
		print("[Black Lady] → Phase 2 activated!")

# =====================
# === ATTACK PICKER ===
# =====================
func pick_attack() -> void:
	is_attacking = true

	match phase:
		1:
			await phase1_attack()
		2:
			await phase2_attack()

	is_attacking = false

# =====================
# === PHASE ATTACKS ===
# =====================
func phase1_attack() -> void:
	var roll = rng.randi_range(1, 3)
	match roll:
		1:
			await spawn_homing_projectiles()
		2:
			await spawn_8way_burst()
		3:
			await dash_toward_player()
			is_attacking = false
	print("[Black Lady] Phase 1 Attack:", roll)

func phase2_attack() -> void:
	var roll = rng.randi_range(1, 3)
	match roll:
		1:
			await spawn_homing_projectiles_phase2()
		2:
			await spawn_12way_burst()
		3:
			# Chain attack: dash → teleport smack → back home
			chain_attack_active = true
			await dash_toward_player()
			await get_tree().create_timer(0.2).timeout
			await teleport_smack()
			await spawn_falling_beams()
			await get_tree().create_timer(2).timeout
			global_position = home_position
			chain_attack_active = false
	print("[Black Lady] Phase 2 Attack:", roll)

# =====================
# === PROJECTILES =====
# =====================
func spawn_homing_projectiles() -> void:
	var num_projectiles = rng.randi_range(1, 3)
	for i in range(num_projectiles):
		var proj = SBall_Scene.instantiate()
		var offset_dir = (rng.randi_range(0, 1) * 2 - 1)  # -1 or +1
		var offset = Vector2(200 * offset_dir, 0)
		proj.global_position = projectile_spawn.global_position + offset
		get_parent().add_child(proj)
		await get_tree().create_timer(1).timeout

func spawn_8way_burst() -> void:
	if not SBeam_Scene or not projectile_spawn:
		return
	for i in range(8):
		var angle_rad = deg_to_rad(i * 45)
		var dir = Vector2(cos(angle_rad), sin(angle_rad)).normalized()
		var proj = SBeam_Scene.instantiate()
		proj.global_position = projectile_spawn.global_position
		get_parent().add_child(proj)
		if proj.has_method("init"):
			proj.init(dir)
		await get_tree().create_timer(0.1).timeout

# =====================
# === DASH ATTACK =====
# =====================
func dash_toward_player() -> void:
	if not player:
		return
	
	is_attacking = true
	var target = player.global_position
	var dash_offset = 150
	var overshoot_distance = 10
	var start_x = home_position.x + (dash_offset if target.x < home_position.x else -dash_offset)
	global_position = Vector2(start_x, target.y)
	var direction = sign(target.x - global_position.x)
	var end_x = target.x + overshoot_distance * direction
	if sprite:
		sprite.flip_h = direction < 0

	await get_tree().create_timer(0.2).timeout

	# Dash movement loop (physics-safe version could use move_and_slide)
	velocity = Vector2(direction * dash_speed, 0)
	while (direction > 0 and global_position.x < end_x) or (direction < 0 and global_position.x > end_x):
		move_and_slide()
		#await get_tree().process_frame

	velocity = Vector2.ZERO
	await get_tree().create_timer(0.2).timeout
	if sprite:
		sprite.visible = false
	await get_tree().create_timer(0.1).timeout
	global_position = home_position
	if sprite:
		sprite.visible = true

# =====================
# === PHASE 2 PROJECTILES
# =====================
func spawn_homing_projectiles_phase2() -> void:
	if not SBall_Scene or not projectile_spawn:
		return
	var num_projectiles = rng.randi_range(3, 5)
	for i in range(num_projectiles):
		var proj_left = SBall_Scene.instantiate()
		proj_left.global_position = projectile_spawn.global_position + Vector2(-200, 0)
		get_parent().add_child(proj_left)
		await get_tree().create_timer(0.2).timeout
		
		var proj_right = SBall_Scene.instantiate()
		proj_right.global_position = projectile_spawn.global_position + Vector2(200, 0)
		get_parent().add_child(proj_right)
		
		await get_tree().create_timer(0.5).timeout

	await get_tree().create_timer(0.5).timeout

func spawn_12way_burst() -> void:
	if not SBeam_Scene or not projectile_spawn:
		return
	await get_tree().create_timer(0.2).timeout
	for i in range(12):
		var angle_deg = i * 30
		var angle_rad = deg_to_rad(angle_deg)
		var dir = Vector2(cos(angle_rad), sin(angle_rad)).normalized()
		var proj = SBeam_Scene.instantiate()
		proj.global_position = projectile_spawn.global_position
		get_parent().add_child(proj)
		if proj.has_method("init"):
			proj.init(dir)
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(0.5).timeout

# =====================
# === TELEPORT SMACK ===
# =====================
func teleport_smack() -> void:
	if not player:
		return

	is_attacking = true
	var tp_offset = Vector2(0, -500)
	global_position = player.global_position + tp_offset

	var downslash = $Area2D/DownSlash
	if downslash:
		downslash.disabled = true

	velocity = Vector2.ZERO
	var gravity = 400  # fall speed

	while global_position.y < player.global_position.y:
		velocity.y = gravity
		move_and_slide()  # no arguments in Godot 4
		await get_tree().process_frame

	if downslash:
		downslash.disabled = false

	await get_tree().create_timer(0.2).timeout

	if downslash:
		downslash.disabled = true

	await get_tree().create_timer(0.5).timeout
	is_attacking = false


func spawn_falling_beams() -> void:
	if not SBeam_Scene or not pillar_spawn:
		return

	var num_beams = 5
	var arena_width = 1000  # adjust to fit your arena
	var spacing = arena_width / (num_beams - 1)
	var start_x = pillar_spawn.global_position.x - arena_width / 2
	var y = pillar_spawn.global_position.y - 500

	for i in range(num_beams):
		var proj = SBeam_Scene.instantiate()
		proj.global_position = Vector2(start_x + i * spacing, y)
		get_parent().add_child(proj)

		# give direction DOWN
		if proj.has_method("init"):
			proj.init(Vector2.DOWN)



# =====================
# === DAMAGE ==========
# =====================
func take_damage(amount: int, _knockback: Vector2) -> void:
	if hp <= 0:
		PortalManager.is_black_lady_dead = true
		return
	hp -= amount
	if sprite:
		sprite.modulate = Color(2,2,2)
		await get_tree().create_timer(0.05).timeout
		sprite.modulate = Color(1,1,1)
	if hp <= 0:
		PortalManager.is_black_lady_dead = true
		die()
	print("hp is ", hp)

# =====================
# === DEATH ===========
# =====================
func die() -> void:
	print("[Black Lady] Defeated.")
	queue_free()
	
	
func _on_area_2d_body_entered(body: Node) -> void:
	if not body or body == self:
		return

	# Detect if player or player-related hitbox
	if body.name == "HK" or body.is_in_group("player"):
		print("[BL] Hit:", body.name)

func get_damage() -> int:
	return 1
