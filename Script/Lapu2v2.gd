extends CharacterBody2D

# --- Enemy Stats ---
@export var max_hp: int = 120
@export var gravity: float = 900.0
@export var fall_gravity_multiplier: float = 4.0
@export var charge_speed: float = 30.0
@export var attack_range: float = 150.0
@export var is_attacking: bool = false
@export var is_flipped: bool = false

# --- Front Slash ---
@export var slash_delay: float = 0.75
@export var slash_dur: float = 1.0
@export var lunge_speed: float = 120.0
@export var lunge_len: float = 10.0

# --- Bait Slash ---
@export var retreat_speed: float = 100.0
@export var retreat_len: float = 40.0
@export var counter_speed: float = 80.0
@export var counter_len: float = 20.0
@export var bait_delay: float = 0.5

# --- Double Slash ---
@export var double_slash_speed: float = 60.0
@export var double_slash_len: float = 50.0
@export var double_slash_delay: float = 0.8

# --- Ground Slam ---
@export var slam_jump_height: float = -300.0
@export var slam_down_speed: float = 130.0
@export var slam_delay: float = 0.3
@export var slam_forward_speed: float = 200.0

# --- Nodes ---
@onready var player = get_node_or_null("../../Player")
@onready var sprite_node: AnimatedSprite2D = $AnimatedSprite2D
@onready var slash_area: Area2D = $Hitbox
@onready var col_right: CollisionShape2D = $Hitbox/Right
@onready var col_left: CollisionShape2D = $Hitbox/Left
@onready var col_up: CollisionShape2D = $Hitbox/Up
@onready var col_down: CollisionShape2D = $Hitbox/Down

@export var attack_cooldown_time: float = 2
var attack_cooldown_timer: float = 0.0
var is_alive = true
# --- State Variables ---
var hp: int
var att: int

# --- Ready ---
func _ready() -> void:
	hp = max_hp
	is_alive = true
	print("[DEBUG] Boss ready! HP =", hp)
	if not player:
		print("[DEBUG] Player node NOT found!")
	sprite_node.play("idle")

# --- Physics ---
# --- Physics ---
func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity.y += gravity * (fall_gravity_multiplier if velocity.y > 0 else 1) * delta
	else:
		velocity.y = 0

	# update cooldown timer
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta

	if player and is_alive == true:
		var dir_to_player = (player.global_position - global_position).normalized()
		var target_speed = 0.0

		# only chase when not attacking
		if not is_attacking:
			target_speed = dir_to_player.x * charge_speed

			# update facing only outside of attacks
			if sprite_node:
				is_flipped = target_speed < 0
				sprite_node.flip_h = is_flipped
		else:
			# minor drift during attack
			target_speed = dir_to_player.x * (charge_speed * 0.05)

		# smooth horizontal velocity
		velocity.x = lerp(velocity.x, target_speed, delta * 8.0)

		var distance_to_player = global_position.distance_to(player.global_position)

		# check attack only if cooldown is finished
		if attack_cooldown_timer <= 0.0 and is_on_floor() and not is_attacking:
			if distance_to_player <= (attack_range / 2):
				start_attack(4)
			elif distance_to_player <= attack_range:
				start_attack(3)

	move_and_slide()


# --- ATTACK SELECTOR ---
func start_attack(max):
	if is_attacking:
		return

	is_attacking = true
	att = randi_range(1, 4)
	print("[DEBUG] Starting attack:", att)

	match att:
		1:
			await get_tree().create_timer(slash_delay).timeout
			await front_slash()
			attack_cooldown_timer = 1.2
		2:
			await bait_slash()
			attack_cooldown_timer = 1.5
		3:
			await double_front_slash()
			attack_cooldown_timer = 2.0
		4:
			await ground_slam()
			attack_cooldown_timer = 2.5

	is_attacking = false
	sprite_node.play("idle")

# --- FRONT SLASH ---
func front_slash():
	close_collision()
	print("Front Slash start")

	front_open()
	sprite_node.play("attack")

	var dir = (player.global_position - global_position).normalized()
	var start_pos = global_position
	var target_speed = dir.x * lunge_speed

	# keep facing locked
	sprite_node.flip_h = is_flipped

	while global_position.distance_to(start_pos) < lunge_len:
		velocity.x = lerp(velocity.x, target_speed, 0.1)
		move_and_slide()
		await get_tree().process_frame

	velocity.x = lerp(velocity.x, 0.0, 0.2)
	close_collision()
	await get_tree().create_timer(0.1).timeout
	sprite_node.play("idle")
	await get_tree().create_timer(0.3).timeout

# --- DOUBLE FRONT SLASH ---
func double_front_slash():
	close_collision()
	print("Double Front Slash start")

	var dir = (player.global_position - global_position).normalized()
	sprite_node.flip_h = is_flipped

	for i in 2:
		front_open()
		var start_pos = global_position
		sprite_node.play("attack")

		var target_speed = dir.x * double_slash_speed * (1.0 + i * 0.2)
		while global_position.distance_to(start_pos) < double_slash_len * (1.0 + i * 0.2):
			velocity.x = lerp(velocity.x, target_speed, 0.25)
			move_and_slide()
			await get_tree().process_frame

		close_collision()
		sprite_node.play("idle")
		await get_tree().create_timer(0.25).timeout

# --- BAIT SLASH ---
func bait_slash():
	close_collision()
	print("Bait Slash start")

	var dir = (player.global_position - global_position).normalized()
	var retreat_dir = -dir
	sprite_node.flip_h = is_flipped

	# retreat back smoothly
	var start_pos = global_position
	while global_position.distance_to(start_pos) < retreat_len:
		velocity.x = lerp(velocity.x, retreat_dir.x * retreat_speed, 0.2)
		move_and_slide()
		await get_tree().process_frame

	velocity.x = 0
	await get_tree().create_timer(bait_delay).timeout

	# counter forward
	front_open()
	sprite_node.play("attack")
	var counter_start = global_position
	while global_position.distance_to(counter_start) < counter_len:
		velocity.x = lerp(velocity.x, dir.x * counter_speed, 0.25)
		move_and_slide()
		await get_tree().process_frame

	velocity.x = 0
	close_collision()
	sprite_node.play("idle")
	await get_tree().create_timer(0.3).timeout

# --- GROUND SLAM ---
func ground_slam():
	close_collision()
	print("Ground Slam start")
	sprite_node.flip_h = is_flipped

	var dir = (player.global_position - global_position).normalized()
	velocity.y = slam_jump_height
	velocity.x = dir.x * slam_forward_speed
	move_and_slide()

	await get_tree().create_timer(slam_delay).timeout

	velocity.x = 0
	velocity.y = slam_down_speed

	while not is_on_floor():
		move_and_slide()
		await get_tree().process_frame

	col_left.disabled = false
	col_right.disabled = false

	await get_tree().create_timer(0.4).timeout
	close_collision()
	sprite_node.play("idle")

# --- Utility ---
func front_open():
	close_collision()
	if is_flipped:
		col_left.disabled = false
	else:
		col_right.disabled = false

func close_collision():
	col_right.disabled = true
	col_left.disabled = true
	col_down.disabled = true
	col_up.disabled = true

# --- COMBAT SYSTEM ---
func get_damage() -> int:
	return 1

func take_damage(amount: int, source_pos: Vector2) -> void:
	if is_alive == false:
		return
	hp -= amount
	print("Ghost HP:", hp)
	
	if hp <= 0:
		PortalManager.is_lapulapu_dead = true
		die()
	else:
		# Optional: small flash on damage
		if sprite_node:
			var original_color = sprite_node.modulate
			sprite_node.modulate = Color(1,1,1,1)
			var tween = get_tree().create_tween()
			tween.tween_property(sprite_node, "modulate", original_color, 0.15)

# --- DEATH ---
func die() -> void:
	if not is_alive:
		return

	is_alive = false
	is_attacking = false

	# Stop movement
	velocity = Vector2.ZERO


	# Lock animation/frame
	if sprite_node:
		sprite_node.play("idle")
		sprite_node.flip_h = sprite_node.flip_h  # keep facing

	print("[Lapu-Lapu] Defeated! Boss is now inactive.")
