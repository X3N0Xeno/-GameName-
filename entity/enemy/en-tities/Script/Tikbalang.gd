extends CharacterBody2D

# ======================
# === ENEMY SETTINGS ===
# ======================
@export var max_hp: int = 30
@export var gravity: float = 900.0
@export var fall_gravity_multiplier: float = 4.0

# --- Normal Dash (Attack 1) ---
@export var dash_speed: float = 900.0
@export var dash_distance: float = 400.0
@export var dash_windup: float = 1.2
@export var dash_end_delay: float = 1.0
@export var afterimage_interval: float = 0.05
@export var afterimage_fade: float = 0.3

# --- Fly Pound (Attack 2) ---
@export var fly_pound_jump: float = -800.0
@export var fly_pound_speed: float = 200.0
@export var fly_pound_target_snap: bool = true
@export var landing_pause_duration: float = 2.0

# --- Teleport Dash (Attack 3) ---
@export var teleport_distance: float = 300.0
@export var teleport_hang_time: float = 1.5

# --- Aura / Telegraph ---
@export var aura_scale: float = 1.5
@export var aura_color: Color = Color(0.0, 0.0, 0.0, 0.5)
@export var aura_duration: float = 0.5
@export var aura_wait_time: float = 0.75

# ======================
# === NODE REFS ===
# ======================
@onready var player = $"../../HK"
@onready var sprite_node := get_node_or_null("AnimatedSprite2D")

# ======================
# === STATE VARS ===
# ======================
var hp
var attPat = 0
var is_dashing = false
var dash_dir = 1
var dash_start_x = 0.0
var is_winding_up = false
var windup_timer = 0.0
var afterimage_timer = 0.0
var is_fly_pounding = false
var pound_target_x = 0.0
var is_landing_pause = false
var landing_pause_timer = 0.0
var is_teleport_paused = false
var teleport_pause_timer = 0.0

# ======================
# === READY ===
# ======================
func _ready() -> void:
	hp = max_hp

# ======================
# === PHYSICS PROCESS ===
# ======================
func _physics_process(delta: float) -> void:
	# --- Gravity ---
	if not is_on_floor():
		if velocity.y < 0:
			velocity.y += gravity * delta
		else:
			velocity.y += gravity * fall_gravity_multiplier * delta
	else:
		if is_fly_pounding:
			is_fly_pounding = false
			velocity = Vector2.ZERO
			if fly_pound_target_snap:
				global_position.x = pound_target_x
			is_landing_pause = true
			landing_pause_timer = landing_pause_duration
		velocity.y = 0

	# --- Landing Pause ---
	if is_landing_pause:
		landing_pause_timer -= delta
		velocity.x = 0
		if landing_pause_timer <= 0:
			is_landing_pause = false

	# --- Teleport Pause ---
	if is_teleport_paused:
		teleport_pause_timer -= delta
		velocity.x = 0
		if teleport_pause_timer <= 0:
			is_teleport_paused = false

	# --- Attack Selection ---
	if not is_dashing and not is_winding_up and not is_fly_pounding and not is_landing_pause and not is_teleport_paused:
		attPat = randi_range(1, 3)
		match attPat:
			1:
				spawn_aura()
				start_windup()
			2:
				start_fly_pound()
			3:
				spawn_aura2()
				start_teleport_dash()

	# --- Windup ---
	if is_winding_up:
		windup_timer -= delta
		if windup_timer <= 0:
			is_winding_up = false
			start_dash()

	# --- Dash ---
	if is_dashing:
		velocity.x = dash_speed * dash_dir
		afterimage_timer -= delta
		if afterimage_timer <= 0:
			spawn_afterimage()
			afterimage_timer = afterimage_interval
		if abs(global_position.x - dash_start_x) >= dash_distance:
			stop_dash()
	elif not is_fly_pounding and not is_landing_pause and not is_teleport_paused:
		velocity.x = 0

	# --- Fly Pound Movement ---
	if is_fly_pounding:
		var dir = sign(pound_target_x - global_position.x)
		velocity.x = fly_pound_speed * dir
		if abs(global_position.x - pound_target_x) < 5:
			velocity.x = 0

	move_and_slide()

	# --- Flip Sprite ---
	if player and sprite_node:
		sprite_node.flip_h = player.global_position.x > global_position.x

# ======================
# === NORMAL DASH ===
# ======================
func start_windup():
	is_winding_up = true
	windup_timer = dash_windup
	dash_dir = -1 if player.global_position.x < global_position.x else 1
	if sprite_node:
		sprite_node.flip_h = dash_dir > 0

func start_dash():
	is_dashing = true
	dash_start_x = global_position.x
	afterimage_timer = 0.0
	dash_dir = -1 if player.global_position.x < global_position.x else 1
	if sprite_node:
		sprite_node.flip_h = dash_dir > 0

func stop_dash():
	is_dashing = false
	velocity.x = 0
	is_landing_pause = true
	landing_pause_timer = dash_end_delay

# ======================
# === FLY POUND ===
# ======================
func start_fly_pound():
	is_fly_pounding = true
	pound_target_x = player.global_position.x
	velocity.y = fly_pound_jump
	if sprite_node:
		sprite_node.flip_h = player.global_position.x > global_position.x

func _process_fly_pound(delta):
	if not is_fly_pounding:
		return
	
	# Smoothly track player’s position while midair
	var target_x = lerp(pound_target_x, player.global_position.x, 0.05)
	pound_target_x = target_x
	
	var dir = sign(pound_target_x - global_position.x)
	velocity.x = fly_pound_speed * dir
	
	# Apply gravity manually
	if not is_on_floor():
		if velocity.y < 0:
			velocity.y += gravity * delta
		else:
			velocity.y += gravity * fall_gravity_multiplier * delta
	else:
		# Landed!
		is_fly_pounding = false
		velocity = Vector2.ZERO
		if fly_pound_target_snap:
			global_position.x = pound_target_x
		is_landing_pause = true
		landing_pause_timer = landing_pause_duration

# ======================
# === TELEPORT DASH ===
# ======================
func start_teleport_dash():
	if not player:
		return
	var dir = -1 if global_position.x > player.global_position.x else 1
	spawn_afterimage()
	global_position.x = player.global_position.x + teleport_distance * dir
	spawn_afterimage()
	if sprite_node:
		sprite_node.flip_h = dir > 0
	is_teleport_paused = true
	teleport_pause_timer = teleport_hang_time

# ======================
# === VISUAL FX ===
# ======================
func spawn_afterimage():
	if not sprite_node:
		return
	var ghost = Sprite2D.new()
	var frame_tex = sprite_node.sprite_frames.get_frame_texture(
		sprite_node.animation,
		sprite_node.frame
	)
	ghost.texture = frame_tex
	ghost.global_transform = sprite_node.global_transform
	ghost.z_index = sprite_node.z_index
	ghost.modulate = Color(1, 1, 1, 0.3)
	get_tree().current_scene.add_child(ghost)
	var tween = get_tree().create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, afterimage_fade)
	tween.tween_callback(Callable(ghost, "queue_free"))

func spawn_aura(scale_factor: float = -1, color: Color = Color(), duration: float = -1.0):
	if not sprite_node:
		return
	var aura = Sprite2D.new()
	var frame_tex = sprite_node.sprite_frames.get_frame_texture(
		sprite_node.animation,
		sprite_node.frame
	)
	aura.texture = frame_tex
	aura.global_transform = sprite_node.global_transform
	aura.scale *= scale_factor if scale_factor > 0 else aura_scale
	aura.z_index = sprite_node.z_index - 1
	aura.modulate = Color(1, 1, 1, 0.4)
	get_tree().current_scene.add_child(aura)
	var tween = get_tree().create_tween()
	tween.tween_interval(aura_wait_time)
	tween.tween_property(aura, "modulate:a", 0.0, duration if duration > 0 else aura_duration)
	tween.tween_callback(Callable(aura, "queue_free"))

func spawn_aura2(scale_factor: float = -1, color: Color = Color(), duration: float = -1.0):
	if not sprite_node:
		return
	var aura = Sprite2D.new()
	var frame_tex = sprite_node.sprite_frames.get_frame_texture(
		sprite_node.animation,
		sprite_node.frame
	)
	aura.texture = frame_tex
	aura.global_transform = sprite_node.global_transform
	aura.scale *= scale_factor if scale_factor > 0 else aura_scale
	aura.z_index = sprite_node.z_index - 1
	aura.modulate = aura_color
	get_tree().current_scene.add_child(aura)
	var tween = get_tree().create_tween()
	tween.tween_interval(aura_wait_time)
	tween.tween_property(aura, "modulate:a", 0.0, duration if duration > 0 else aura_duration)
	tween.tween_callback(Callable(aura, "queue_free"))
