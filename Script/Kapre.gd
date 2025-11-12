extends CharacterBody2D

# =====================
# === CONFIG ==========
# =====================
@export var max_hp: int = 400
@export var phase2_threshold: int = 100
@export var phase3_threshold: int = -1


@export var move_speed: float = 20.0
@export var attack_cooldown: float = 3.0


@export var dash_distance: float = 50.0
@export var dash_speed: float = 100.0
@export var dash_cooldown: float = 10.0
var dash_timer: float = 0.0


# =====================
# === NODES ===========
# =====================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var melee_left: CollisionShape2D = $Hitbox/MeleeLeft
@onready var melee_right: CollisionShape2D = $Hitbox/MeleeRight
@onready var projectile_spawn: Marker2D = $Node/ProjectileSpawn
@onready var player: Node2D = get_node("../../Player") # adjust path as needed

# =====================
# === STATE ===========
# =====================
var hp: int
var phase: int = 1
var is_attacking: bool = false
var attack_timer: float = 0.0
var rng := RandomNumberGenerator.new()

# hop logic
@export var hop_distance: float = 200.0
@export var hop_speed: float = 350.0
@export var hop_cooldown: float = 10.0
var hop_timer: float = 0.0
var hop_height: float = -250.0


# =====================
# === READY ===========
# =====================
func _ready() -> void:
	hp = max_hp
	sprite.play("default")
	rng.randomize()
	print("[Kapre] Ready with", hp, "HP")
	melee_left.disabled = true
	melee_right.disabled = true


# =====================
# === PROCESS =========
# =====================
func _process(delta: float) -> void:
	if hp <= 0 or not player:
		return

	handle_phase()

	# --- Dash logic ---
	dash_timer -= delta
	if dash_timer <= 0.0 and not is_attacking:
		var distance = global_position.distance_to(player.global_position)
		if distance > 150:  # only dash if player is far
			await dash_toward_player()
			dash_timer = dash_cooldown

	# --- Regular attack logic ---
	if not is_attacking:
		attack_timer -= delta
		if attack_timer <= 0.0:
			await pick_attack()



# =====================
# === PHASE CONTROL ===
# =====================
func handle_phase() -> void:
	if hp <= phase2_threshold and phase == 1:
		phase = 2
		print("[Kapre] → Phase 2 Activated!")
	elif hp <= phase3_threshold and phase == 2:
		phase = 3
		print("[Kapre] → Phase 3 Activated!")

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
		3:
			await phase3_attack()

	is_attacking = false
	attack_timer = attack_cooldown

# =====================
# === PHASE ATTACKS ===
# =====================
func phase1_attack() -> void:
	var roll = rng.randi_range(1, 3)
	match roll:
		1:
			print("[Kapre] Phase 1: Trunk Smash")
			await trunk_smash();
		2:
			print("[Kapre] Phase 1: Root Spike")
			await root_spike()
		3:
			print("[Kapre] Phase 1: Ember Puff")
			await ember_puff()


func phase2_attack() -> void:
	var roll = rng.randi_range(1, 3)
	match roll:
		1:
			print("[Kapre] Phase 2: Trunk Smash (buffed)")
			await trunk_smash_phase2()
		2:
			print("[Kapre] Phase 2: Root Spike (wider range)")
			await root_spike_phase2()
		3:
			print("[Kapre] Phase 2: Dual Ember Puff")
			await dual_ember_puff_phase2()

func phase3_attack() -> void:
	print("[Kapre] Phase 3: Smoke Illusion Test")

func dash_toward_player() -> void:
	if not player:
		return

	print("[Kapre] Dash toward player!")
	is_attacking = true

	# Determine dash direction
	var dir = sign(player.global_position.x - global_position.x)
	if sprite:
		sprite.flip_h = dir < 0

	# Set up dash parameters
	var dash_speed = 200.0     # adjust as needed
	var dash_distance = 100.0  # adjust as needed
	var start_x = global_position.x
	var target_x = start_x + (dash_distance * dir)

	# Short wind-up before moving
	await get_tree().create_timer(0.3).timeout

	# Apply velocity for dash
	velocity = Vector2(dir * dash_speed, 0)

	while (dir > 0 and global_position.x < target_x) or (dir < 0 and global_position.x > target_x):
		move_and_slide()
		await get_tree().process_frame

	# Stop movement cleanly
	velocity = Vector2.ZERO
	move_and_slide()

	print("[Kapre] Dash finished.")
	await get_tree().create_timer(0.5).timeout

	is_attacking = false




# =====================
# === TRUNK SMASH =====
# =====================
func trunk_smash() -> void:
	if not player:
		return

	is_attacking = true

	# --- Flip direction based on player position ---
	var facing_left = player.global_position.x < global_position.x
	if sprite:
		sprite.flip_h = facing_left

	# --- Pick which hitbox to enable ---
	var active_melee = melee_left if facing_left else melee_right
	var inactive_melee = melee_right if facing_left else melee_left

	if inactive_melee:
		inactive_melee.disabled = true

	print("[Kapre] Winds up for Trunk Smash!")

	# --- Wind-up delay before attack ---
	await get_tree().create_timer(0.6).timeout  # slow boss wind-up
	sprite.play("Trunk")
	# --- Short lunge forward ---
	var lunge_distance = 10.0
	var lunge_speed = 40.0
	var direction = -1 if facing_left else 1
	var start_pos = global_position.x
	var target_pos = start_pos + (lunge_distance * direction)

	while (direction > 0 and global_position.x < target_pos) or (direction < 0 and global_position.x > target_pos):
		global_position.x += direction * lunge_speed * get_process_delta_time()
		await get_tree().process_frame

	# --- Activate hitbox ---
	if active_melee:
		active_melee.disabled = false
		print("[Kapre] Trunk Smash active!")
		await get_tree().create_timer(0.4).timeout  # active hit window
		active_melee.disabled = true

	print("[Kapre] Trunk Smash ends.")
	await get_tree().create_timer(0.8).timeout  # cooldown recovery
	sprite.play("default")
	is_attacking = false

# =====================
# === ROOT SPIKE ======
# =====================
func root_spike() -> void:
	is_attacking = true
	print("[Kapre] Root Spike begins!")
	sprite.play("Root")
	var root_scene = preload("res://Scenes/RootSpike.tscn")
	var spike_count = 5
	var spacing = 50.0
	var ground_y = global_position.y

	# --- Determine facing ---
	var facing_left = false
	if player:
		facing_left = player.global_position.x < global_position.x

	# --- Small hop backward before summoning roots ---
	var hop_distance = 60.0
	var hop_speed = 40.0

	var direction: int
	if facing_left:
		direction = 1   # move right (away from player)
	else:
		direction = -1  # move left (away from player)

	var target_x = global_position.x + (hop_distance * direction)
	while abs(global_position.x - target_x) > 5:
		var step = abs(hop_speed * get_process_delta_time())
		global_position.x = move_toward(global_position.x, target_x, step)
		await get_tree().process_frame

	# --- Slight pause before eruption ---
	await get_tree().create_timer(0.3).timeout

	# --- Spawn spikes in front of Kapre ---
	var dir_to_player = -1 if facing_left else 1
	var start_x = global_position.x + 10 * dir_to_player

	for i in range(spike_count):
		var spike = root_scene.instantiate()
		get_parent().add_child(spike)
		spike.global_position = Vector2(start_x + (i * spacing * dir_to_player), ground_y+25)
		print("[Kapre] Root Spike spawned at:", spike.global_position)
		await get_tree().create_timer(0.3).timeout

	await get_tree().create_timer(0.8).timeout
	sprite.play("default")
	is_attacking = false



# =====================
# === EMBER PUFF ======
# =====================
func ember_puff() -> void:
	is_attacking = true
	print("[Kapre] Ember Puff begins!")
	sprite.play("Blow")
	var ember_scene = preload("res://Scenes/ember.tscn")
	var ember = ember_scene.instantiate()
	get_tree().current_scene.add_child(ember)

	# Spawn directly at Kapre’s position
	ember.global_position = global_position

	# Determine direction toward player
	var dir = 1
	if player:
		dir = sign(player.global_position.x - global_position.x)

	# Set Ember velocity
	ember.velocity = Vector2(dir * 300, -150)  # forward & more upward for higher arc

	# Flip Ember sprite to face movement
	if ember.has_node("Sprite2D"):
		var sprite = ember.get_node("Sprite2D")
		sprite.flip_h = dir < 0

	print("[Kapre] Ember Puff launched → dir:", dir)
	await get_tree().create_timer(1.5).timeout  # brief delay before next move
	sprite.play("default")
	is_attacking = false

# =====================
# === PHASE 2 ATTACKS ==
# =====================

# --- Trunk Smash x2 ---
func trunk_smash_phase2() -> void:
	if not player:
		return
	
	is_attacking = true
	print("[Kapre] Phase 2: Trunk Smash x2")
	
	for i in range(2):
		sprite.play("trunk")
		# Flip direction toward player
		var facing_left = player.global_position.x < global_position.x
		if sprite:
			sprite.flip_h = facing_left

		var active_melee = melee_left if facing_left else melee_right
		var inactive_melee = melee_right if facing_left else melee_left
		if inactive_melee:
			inactive_melee.disabled = true

		# Wind-up
		await get_tree().create_timer(0.4).timeout

		# Short lunge
		var lunge_distance = 60.0
		var lunge_speed = 200.0
		var direction = -1 if facing_left else 1
		var start_pos = global_position.x
		var target_pos = start_pos + (lunge_distance * direction)

		while (direction > 0 and global_position.x < target_pos) or (direction < 0 and global_position.x > target_pos):
			global_position.x += direction * lunge_speed * get_process_delta_time()
			await get_tree().process_frame

		# Activate hitbox briefly
		if active_melee:
			active_melee.disabled = false
			await get_tree().create_timer(0.4).timeout
			active_melee.disabled = true

		# Slight pause between strikes
		await get_tree().create_timer(0.3).timeout
		sprite.play("default")

	is_attacking = false
	await get_tree().create_timer(0.8).timeout  # cooldown recovery


# --- Root Spike (7 spikes) ---
func root_spike_phase2() -> void:
	is_attacking = true
	print("[Kapre] Phase 2: Root Spike 7x")
	var root_scene = preload("res://Scenes/RootSpike.tscn")
	var spike_count = 7
	var spacing = 50.0
	var ground_y = global_position.y + +25

	var facing_left = player.global_position.x < global_position.x
	var hop_distance = 80.0
	var hop_speed = 200.0

	var direction: int = 1 if facing_left else -1
	var target_x = global_position.x + hop_distance * direction

	while abs(global_position.x - target_x) > 5:
		sprite.play("Root")
		var step = hop_speed * get_process_delta_time()
		global_position.x = move_toward(global_position.x, target_x, step)
		await get_tree().process_frame

	await get_tree().create_timer(0.3).timeout

	var start_x = global_position.x + 10 * ( -1 if facing_left else 1 )

	for i in range(spike_count):
		var spike = root_scene.instantiate()
		get_parent().add_child(spike)
		spike.global_position = Vector2(start_x + i * spacing * ( -1 if facing_left else 1 ), ground_y)
		await get_tree().create_timer(0.4).timeout

	await get_tree().create_timer(0.8).timeout
	sprite.play("default")
	is_attacking = false


# --- Dual Ember Puff ---
func dual_ember_puff_phase2() -> void:
	is_attacking = true
	print("[Kapre] Phase 2: Dual Ember Puff")

	# Predefined angles for a nice spread (in degrees)
	var angles = [0, 30, 50, 70]
	for i in range(4):
		var ember_scene = preload("res://Scenes/ember.tscn")
		var ember = ember_scene.instantiate()
		get_tree().current_scene.add_child(ember)
		ember.global_position = global_position

		# Convert angle to radians and compute velocity
		var angle_rad = deg_to_rad(angles[i])
		var dir = sign(player.global_position.x - global_position.x)
		var speed = 350  # or whatever feels right
		ember.velocity = Vector2(speed * dir * cos(angle_rad), -speed * sin(angle_rad))

		# Flip sprite
		if ember.has_node("Sprite2D"):
			var sprite = ember.get_node("Sprite2D")
			sprite.flip_h = dir < 0

		await get_tree().create_timer(0.0).timeout  # stagger launches slightly

	is_attacking = false



# =====================
# === DAMAGE ==========
# =====================
func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if hp <= 0:
		PortalManager.is_kapre_dead =true
		return

	hp -= amount
	print("[Kapre] Took", amount, "damage →", hp, "HP left")

	if sprite:
		sprite.modulate = Color(2, 2, 2)
		await get_tree().create_timer(0.05).timeout
		sprite.modulate = Color(1, 1, 1)

	if hp <= 0:
		PortalManager.is_kapre_dead =true
		die()

# =====================
# === DEATH ===========
# =====================
func die() -> void:
	print("[Kapre] Defeated!")
	queue_free()

func get_damage() -> int:
	return 2
