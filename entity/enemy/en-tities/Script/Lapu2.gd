extends CharacterBody2D

# --- Enemy Stats ---
@export var max_hp: int = 50
@export var gravity: float = 900.0
@export var fall_gravity_multiplier: float = 4.0
@export var charge_speed: float = 200.0
@export var attack_range: float = 300.0
@export var is_attacking: bool = false
@export var is_flipped: bool = false

# --- Front Slash ---
@export var slash_delay: float = 0.75
@export var slash_dur: float = 1.0
@export var lunge_speed: float = 500.0
@export var lunge_len: float = 50.0

# --- Bait Slash (Replaces Jump Attack) ---
@export var retreat_speed: float = 200.0
@export var retreat_len: float = 300.0
@export var counter_speed: float = 800.0
@export var counter_len: float = 150.0
@export var bait_delay: float = 0.5

# --- Double Slash ---
@export var double_slash_speed: float = 250.0
@export var double_slash_len: float = 80.0
@export var double_slash_delay: float = 0.4

# --- Ground Slam ---
@export var slam_jump_height: float = -700.0
@export var slam_down_speed: float = 900.0
@export var slam_delay: float = 0.3
@export var slam_forward_speed: float = 100.0

# --- Nodes ---
@onready var player = get_node_or_null("../../HK")
@onready var sprite_node: AnimatedSprite2D = $AnimatedSprite2D
@onready var slash_area: Area2D = $Slash
@onready var col_right: CollisionShape2D = $Slash/Right
@onready var col_left: CollisionShape2D = $Slash/Left
@onready var col_up: CollisionShape2D = $Slash/Up
@onready var col_down: CollisionShape2D = $Slash/Down

# --- State Variables ---
var hp: int
var att: int

# --- Ready ---
func _ready() -> void:
	hp = max_hp
	slash_area.connect("body_entered", _on_slash_hit)
	print("[DEBUG] Boss ready! HP =", hp)
	if not player:
		print("[DEBUG] Player node NOT found!")

# --- Physics ---
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * (fall_gravity_multiplier if velocity.y > 0 else 1) * delta
	else:
		velocity.y = 0

	if player:
		var dir_to_player = (player.global_position - global_position).normalized()

		if not is_attacking:
			velocity.x = dir_to_player.x * charge_speed
		else:
			velocity.x = dir_to_player.x * (charge_speed * 0.05)

		if sprite_node:
			sprite_node.flip_h = velocity.x > 0
			is_flipped = velocity.x > 0

		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= (attack_range/2) and is_on_floor() and not is_attacking:
			start_attack(4)
		elif distance_to_player <= attack_range and is_on_floor() and not is_attacking:
			start_attack(3)

	move_and_slide()

# --- ATTACK SELECTOR ---
func start_attack(max):
	if is_attacking:
		return

	is_attacking = true
	att = randi_range(4, 4)

	match att:
		1:
			await get_tree().create_timer(slash_delay).timeout
			await front_slash()
		2:
			await bait_slash() # new attack
		3:
			await double_front_slash()
		4:
			await ground_slam()

	is_attacking = false

# --- FRONT SLASH ---
func front_slash():
	close_collision()
	print("Front Slash start")

	front_open()
	var dir_to_player = (player.global_position - global_position).normalized()
	var start_pos = global_position

	while global_position.distance_to(start_pos) < lunge_len:
		velocity.x = dir_to_player.x * lunge_speed
		move_and_slide()
		await get_tree().process_frame

	velocity.x = 0
	close_collision()
	await get_tree().create_timer(0.3).timeout

# --- DOUBLE FRONT SLASH ---
func double_front_slash():
	close_collision()
	print("Double Front Slash start")

	var dir_to_player = (player.global_position - global_position).normalized()

	# First slash
	front_open()
	var start_pos = global_position
	while global_position.distance_to(start_pos) < double_slash_len:
		velocity.x = dir_to_player.x * double_slash_speed
		move_and_slide()
		await get_tree().process_frame

	close_collision()
	await get_tree().create_timer(double_slash_delay).timeout

	# Second slash (slightly stronger)
	front_open()
	start_pos = global_position
	while global_position.distance_to(start_pos) < double_slash_len * 1.2:
		velocity.x = dir_to_player.x * (double_slash_speed * 1.2)
		move_and_slide()
		await get_tree().process_frame

	velocity.x = 0
	close_collision()
	await get_tree().create_timer(0.4).timeout
	
# --- BAIT SLASH---
func bait_slash():
	close_collision()
	print("Bait Slash start")

	var dir_to_player = (player.global_position - global_position).normalized()
	var retreat_dir = -dir_to_player

	# --- Step back quickly ---
	var start_pos = global_position
	var retreat_distance = 80.0  # how far to step back

	while global_position.distance_to(start_pos) < retreat_distance:
		velocity.x = retreat_dir.x * retreat_speed
		move_and_slide()
		await get_tree().process_frame

	velocity.x = 0

	# --- Small pause (bait moment) ---
	await get_tree().create_timer(bait_delay).timeout

	front_open()

	var counter_start = global_position
	while global_position.distance_to(counter_start) < counter_len:
		velocity.x = dir_to_player.x * counter_speed
		move_and_slide()
		await get_tree().process_frame

	velocity.x = 0
	close_collision()
	await get_tree().create_timer(0.4).timeout

# --- GROUND SLAM ---
func ground_slam():
	close_collision()
	print("Ground Slam start")

	var dir_to_player = (player.global_position - global_position).normalized()

	# Jump diagonally toward player
	velocity.y = slam_jump_height
	velocity.x = dir_to_player.x * slam_forward_speed
	move_and_slide()

	await get_tree().create_timer(slam_delay).timeout

	# Slam straight down
	velocity.x = 0
	velocity.y = slam_down_speed

	while not is_on_floor():
		move_and_slide()
		await get_tree().process_frame

	col_left.disabled = false
	col_right.disabled = false

	await get_tree().create_timer(0.4).timeout
	close_collision()

# --- Utility ---
func front_open():
	close_collision()
	if is_flipped:
		col_right.disabled = false
	else:
		col_left.disabled = false

func close_collision():
	col_right.disabled = true
	col_left.disabled = true
	col_down.disabled = true
	col_up.disabled = true

func _on_slash_hit(body: Node) -> void:
	print("Slash hit:", body.name)
