extends Node2D

# =====================
# === CONFIG ==========
# =====================
@export var max_hp: int = 1
@export var phase2_threshold: int = 400

@export var move_speed: float = 100.0
@export var follow_speed: float = 5.0
@export var segment_spacing: float = 30.0

@export var attack_cooldown: float = 3.0  # seconds between attacks
# =====================
# === NODES ===========
# =====================
@onready var head: Node2D = $Head
@onready var segments: Array[Node2D] = [
	$Body1, $Body2, $Body3, $Body4, $Body5,
	$Body6, $Body7, $Body8, $Body9, $Body10,
	$Body11, $Body12, $Body13, $Body14, $Body15,
	$Body16,$Tail
]
@onready var player: Node2D = $"../Player" # adjust path if needed

# =====================
# === STATE ===========
# =====================
var hp: int
var phase: int = 1
var is_attacking: bool = false
var attack_timer: float = 0.0
var rng := RandomNumberGenerator.new()
var idle_task_running = false

# =====================
# === READY ===========
# =====================
func _ready() -> void:
	hp = max_hp
	rng.randomize()
	print("[Bakunawa] Ready with", hp, "HP")

	# Start idle hover asynchronously
	_start_idle_hover()


# =====================
# === PROCESS =========
# =====================
func _process(delta: float) -> void:
	_move_segments(delta)
	if hp <= 0:
		return

	handle_phase()

	# Handle attack timing
	if not is_attacking:
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = attack_cooldown
			# Launch attack async
			start_attack()

	

# =====================
# === PHASE CONTROL ===
# =====================
func handle_phase() -> void:
	if hp <= phase2_threshold and phase == 1:
		phase = 2
		print("[Bakunawa] → Phase 2 Activated!")

# =====================
# === BODY FOLLOW =====
# =====================
func _move_segments(delta: float):
	var prev_pos = head.global_position
	for seg in segments:
		var to_prev = prev_pos - seg.global_position
		var distance = to_prev.length()

		if distance > segment_spacing:
			# Only move as far as needed to maintain spacing
			var move_amount = distance - segment_spacing
			seg.global_position += to_prev.normalized() * move_amount

		# Smooth rotation toward previous segment (≈90% of the way)
		var dir = to_prev.normalized()
		if dir.length() > 0.01:
			var target_angle = dir.angle()
			# Interpolate current rotation toward target
			seg.rotation = lerp_angle(seg.rotation, target_angle, 0.9)

		prev_pos = seg.global_position



# =====================
# === ATTACK SYSTEM (RNG) ===
# =====================
func start_attack() -> void:
	if is_attacking:
		return
	is_attacking = true
	print("[Bakunawa] Deciding next attack...")

	match phase:
		1:
			await phase1_attack()
		2:
			await phase2_attack()

	is_attacking = false

func phase1_attack() -> void:
	# Randomly pick between Bite Attack or Beam Attack
	var choice = rng.randi_range(1, 3)
	match choice:
		1:
			print("[Bakunawa] → Phase 1 Bite Attack Selected")
			await bite_attack()
		2:
			print("[Bakunawa] → Phase 1 Beam Attack Selected")
			await beam_attack()
		#3:
			#print("[Bakunawa] → Phase 1 dive Attack Selected")
			#await vertical_bite_orbit()
		3:
			print("[Bakunawa] → Phase 1 Perch Selected")
			await idle_square_pattern()

func phase2_attack() -> void:
	# Example: RNG between Bite and Beam, could add more
	var choice = rng.randi_range(3, 3)
	match choice:
		1:
			print("[Bakunawa] → Phase 2 Beam + Bite Attack Selected")
			await stormfall_bite_combo()
		2:
			print("[Bakunawa] → Phase 2 Devour Attack Selected")
			await twin_devour()
		3:
			print("[Bakunawa] → Phase 2 Beam Attack Selected")
			await beam_attack()
		4:
			print("[Bakunawa] → Phase 2 Perch Selected")
			await idle_square_pattern()


func _start_idle_hover() -> void:
	if idle_task_running:
		return
	idle_task_running = true
	# start the coroutine without blocking
	idle_hover_task()

func idle_hover_task() -> void:
	# Run as a separate async task
	async_idle_hover()

func async_idle_hover() -> void:
	if not player:
		idle_task_running = false
		return

	var hover_height = -400.0
	var hover_amplitude_x = 800.0
	var hover_amplitude_y = 50.0
	var sway_speed = 0.5
	var time_passed = 0.0

	# ------------------------------
	# Step 0: Move smoothly to starting hover position
	# ------------------------------
	var start_pos = Vector2(player.global_position.x, hover_height)
	while head.global_position.distance_to(start_pos) > 1.0:
		if is_attacking:
			await get_tree().process_frame
			continue

		var delta = get_process_delta_time()
		head.global_position = head.global_position.lerp(start_pos, 0.5 * delta)
		# Rotate toward player
		var move_dir = (player.global_position - head.global_position).normalized()
		if move_dir.length() > 0.01:
			head.rotation = lerp_angle(head.rotation, move_dir.angle(), 2.0 * delta)
		await get_tree().process_frame

	var current_pos = head.global_position

	# ------------------------------
	# Step 1: Start slow hover
	# ------------------------------
	while true:
		var delta = get_process_delta_time()

		# If attacking, just wait and keep current position
		if is_attacking:
			await get_tree().process_frame
			continue

		time_passed += delta

		var target_x = player.global_position.x + hover_amplitude_x * sin(time_passed * sway_speed)
		var target_y = hover_height + hover_amplitude_y * sin(time_passed * sway_speed * 0.5)
		var target_pos = Vector2(target_x, target_y)

		# Smoothly move toward target
		var lerp_speed = 0.5
		current_pos = current_pos.lerp(target_pos, lerp_speed * delta)
		head.global_position = current_pos

		# Rotate toward player
		var move_dir = (player.global_position - head.global_position).normalized()
		if move_dir.length() > 0.01:
			head.rotation = lerp_angle(head.rotation, move_dir.angle(), 1.5 * delta)

		await get_tree().process_frame

# =====================
# === BITE ATTACK =====
# =====================
func bite_attack() -> void:
	if not player:
		print("[Bakunawa] No player found — cannot bite.")
		return

	print("[Bakunawa] → Bite Attack START")
	is_attacking = true

	# --- Step 1: Face player (rotation only) ---
	var move_vec = player.global_position - head.global_position
	if move_vec.length() > 0.01:
		head.rotation = move_vec.angle()

	# --- Step 2: Vertical descent slightly below player ---
	var target_y = player.global_position.y  # adjust as needed
	var vertical_speed = 100.0
	while abs(head.global_position.y - target_y) > 1.0:
		head.global_position.y = move_toward(head.global_position.y, target_y, vertical_speed * get_process_delta_time())
		# Head always faces downward while dropping
		head.rotation = deg_to_rad(90)
		await get_tree().process_frame

	# --- Step 3: Horizontal alignment with player ---
	var target_x = player.global_position.x
	var horizontal_speed = 200.0
	while abs(head.global_position.x - target_x) > 1.0:
		head.global_position.x = move_toward(head.global_position.x, target_x, horizontal_speed * get_process_delta_time())
		
		# Head faces movement direction
		var dir = Vector2(target_x - head.global_position.x, 0).normalized()
		if dir.length() > 0.01:
			head.rotation = dir.angle()
		
		await get_tree().process_frame

	print("[Bakunawa] → Bite Attack END")
	await get_tree().create_timer(0.6).timeout
	is_attacking = false
	
	if has_method("_start_idle_hover"):
		await _start_idle_hover()



func beam_attack() -> void:
	if not player:
		print("[Bakunawa] No player found — cannot beam.")
		return

	print("[Bakunawa] → Beam Attack START")
	is_attacking = true

	# --- Move Bakunawa upward before horizontal movement ---
	var ascend_speed := 300.0
	var target_y := 750

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var next_drop_time := rng.randf_range(0.3, 0.6)

	# Use absolute check to prevent infinite loop
	while abs(head.global_position.y - target_y) > 5.0 and hp > 0:
		var delta := get_process_delta_time()
		head.global_position.y = move_toward(head.global_position.y, target_y, ascend_speed * delta)

		# Drop beams during ascent (less frequent)
		next_drop_time -= delta
		if next_drop_time <= 0.0:
			var beam_scene := preload("res://Scene/Bakunawa_Beams.tscn")
			var beam := beam_scene.instantiate()
			get_tree().current_scene.add_child(beam)
			beam.global_position = head.global_position
			if beam.has_method("init"):
				beam.init(Vector2.DOWN)
			next_drop_time = rng.randf_range(0.3, 0.6)  # slower drop during ascent

		await get_tree().process_frame

	# --- Horizontal movement while dropping beams ---
	var horizontal_speed := 120.0
	var direction := 1 if (player.global_position.x - head.global_position.x) >= 0 else -1
	var horizontal_distance := 800.0
	var start_x := head.global_position.x
	var end_x := start_x + horizontal_distance * direction

	next_drop_time = rng.randf_range(0.2, 0.6)  # faster beam rain during sweep

	while abs(head.global_position.x - end_x) > 1.0 and hp > 0:
		var delta := get_process_delta_time()
	
		# Move toward target with clamping to prevent overshoot
		head.global_position.x = move_toward(head.global_position.x, end_x, horizontal_speed * delta)
	
		# Rotate head slightly toward movement direction
		var move_dir := Vector2(direction, 0)
		head.rotation = lerp_angle(head.rotation, move_dir.angle(), 2.0 * delta)
	
		# Drop beams as it moves horizontally
		next_drop_time -= delta
		if next_drop_time <= 0.0:
			var beam_scene := preload("res://Scene/Bakunawa_Beams.tscn")
			var beam := beam_scene.instantiate()
			get_tree().current_scene.add_child(beam)
			beam.global_position = head.global_position
			if beam.has_method("init"):
				beam.init(Vector2.DOWN)
			next_drop_time = rng.randf_range(0.3, 0.6)
	
		await get_tree().process_frame

# Snap exactly to the target X to avoid tiny residual offsets
	head.global_position.x = end_x

	print("[Bakunawa] → Beam Attack END")

	# --- Cooldown / transition ---
	await get_tree().create_timer(0.3).timeout
	is_attacking = false

	# Optional smooth return to idle hover
	if has_method("_start_idle_hover"):
		await _start_idle_hover()



func vertical_bite_orbit():
	if not player:
		return

	is_attacking = true

	# -------------------------------
	# Vertical Bite Overshoot
	# -------------------------------
	var target_x = player.global_position.x
	var start_y = head.global_position.y
	var overshoot_y = player.global_position.y + 200  # go past player
	head.global_position = Vector2(target_x, start_y)
	
	var dive_speed = 200
	while head.global_position.y < overshoot_y - 1.0:  # safe loop
		# Move down
		head.global_position.y = move_toward(head.global_position.y, overshoot_y, dive_speed * get_process_delta_time())

		# Head always faces down while diving
		head.rotation = deg_to_rad(90)  # facing downward

		await get_tree().process_frame

	print("Debug: Dive complete")
	await get_tree().create_timer(0.1).timeout

	# -------------------------------
	# Orbit Around Player
	# -------------------------------
	var orbit_radius = 700
	var orbit_speed = -2.0  # radians per second
	var orbit_time = 2.0
	var dt = 0.0

	# Start angle based on current head position relative to player
	var angle = atan2(head.global_position.y - player.global_position.y,
					  head.global_position.x - player.global_position.x)

	while dt < orbit_time:
		if not player:
			break

		# Increment angle
		angle += orbit_speed * get_process_delta_time()

		# Calculate new orbit position
		var offset = Vector2(cos(angle), sin(angle)) * orbit_radius
		var new_pos = player.global_position + offset
		var move_vec = new_pos - head.global_position

		# Set position
		head.global_position = new_pos

		# Head faces direction of movement along orbit
		if move_vec.length() > 0.1:
			head.rotation = move_vec.angle()  # just rotate, no flipping

		dt += get_process_delta_time()
		await get_tree().process_frame

	print("Debug: Orbit complete")

	is_attacking = false
	
	if has_method("_start_idle_hover"):
		await _start_idle_hover()


func idle_square_pattern():
	if not player:
		return

	is_attacking = true

	# -------------------------------
	# Square path settings
	# -------------------------------
	var arena_center = Vector2(2700, 750)  # adjust Y to hover above arena
	var square_size = 150.0  # width/height of square
	var speed = 120.0        # movement speed
	var pause_time = 0.0     # pause at corners
	var rotation_speed = 3.0  # radians/sec, controls smooth rotation

	# Define corners relative to arena_center
	var corners = [
		arena_center + Vector2(-square_size*2, -square_size),
		arena_center + Vector2(square_size*2, -square_size),
		arena_center + Vector2(square_size*2, square_size / 8),
		arena_center + Vector2(-square_size*2, square_size / 8)
	]

	# Move head to first corner instantly
	head.global_position = corners[0]

	var total_loops = 2  # how many times to do the square
	for loop in range(total_loops):
		for i in range(4):
			var target_pos = corners[i]

			while head.global_position.distance_to(target_pos) > 1.0:
				var move_vec = target_pos - head.global_position
				if move_vec.length() < 5.0:
					break  # close enough, skip rotation jitter

				var move_dir = move_vec.normalized()
	
	# Smooth movement
				head.global_position += move_dir * speed * get_process_delta_time()
	
	# Smooth rotation toward movement direction
				var target_angle = move_dir.angle()
				head.rotation = lerp_angle(head.rotation, target_angle, rotation_speed * get_process_delta_time())

				await get_tree().process_frame


			# Pause at corner
			await get_tree().create_timer(pause_time).timeout

	print("Debug: Idle square complete")
	is_attacking = false

func stormfall_bite_combo():
	if not player:
		return

	is_attacking = true
	print("[Bakunawa] → Stormfall START")

	# -------------------------------
	# Step 1 — Rise slightly above arena
	# -------------------------------
	var rise_height = head.global_position.y - 800.0
	var rise_speed = 100.0

	while abs(head.global_position.y - rise_height) > 1.0:
		head.global_position.y = move_toward(head.global_position.y, rise_height, rise_speed * get_process_delta_time())
		await get_tree().process_frame

	print("debug")

	# -------------------------------
	# Step 2 — Storm: move left-right while dropping beams
	# -------------------------------
	print("[Bakunawa] → Summoning storm...")
	var storm_duration = 9.0
	var beam_spawn_interval = 0.15
	var beam_timer = 0.0
	var time_elapsed = 0.0
	var arena_width = 400.0
	var arena_top = -600.0

	var horizontal_range = 800.0
	var orbit_speed = 2.0
	var angle = 0.0

	while time_elapsed < storm_duration:
		var delta = get_process_delta_time()
		time_elapsed += delta
		beam_timer -= delta

		# Move left-right smoothly with sine wave
		angle += orbit_speed * delta
		head.global_position.x = horizontal_range * sin(angle) + player.global_position.x

		# Drop beams
		if beam_timer <= 0.0:
			var beam_scene = preload("res://Scene/Bakunawa_Beams.tscn")
			var beam = beam_scene.instantiate()
			get_tree().current_scene.add_child(beam)

			var random_x = player.global_position.x + randf_range(-arena_width / 2, arena_width / 2)
			var spawn_pos = Vector2(random_x, player.global_position.y + arena_top)
			beam.global_position = spawn_pos

			if beam.has_method("init"):
				beam.init(Vector2.DOWN)

			beam_timer = beam_spawn_interval

		await get_tree().process_frame

	print("[Bakunawa] → Storm complete, prepare to dive...")

	# -------------------------------
	# Step 3 — Short dramatic pause
	# -------------------------------
	await get_tree().create_timer(0.3).timeout

	# -------------------------------
	# Step 4 — Bite attack from current head position
	# -------------------------------
	print("[Bakunawa] → Diving Bite!")
	var vertical_speed = 180.0
	var horizontal_speed = 160.0

	var descent_amount = max(player.global_position.y - head.global_position.y, 100)
	var target_y = head.global_position.y + descent_amount

	# Step 4a — Vertical descent
	while abs(head.global_position.y - target_y) > 1.0:
		head.global_position.y = move_toward(head.global_position.y, target_y, vertical_speed * get_process_delta_time())
		head.rotation = deg_to_rad(90)
		await get_tree().process_frame

	# Step 4b — Align horizontally with player
	var target_x = player.global_position.x + 1600
	while abs(head.global_position.x - target_x) > 1.0:
		head.global_position.x = move_toward(head.global_position.x, target_x, horizontal_speed * get_process_delta_time())
		var dir = Vector2(target_x - head.global_position.x, 0).normalized()
		if dir.length() > 0.01:
			head.rotation = dir.angle()
		await get_tree().process_frame

	print("[Bakunawa] → Stormfall Bite COMPLETE!")
	is_attacking = false
	print("[Bakunawa] → Phase 2 Combo END")

func twin_devour() -> void:
	if not player:
		return

	is_attacking = true
	print("[Bakunawa] → Twin Devour START")

	# -------------------------------
	# Step 1 — Rise before first dive
	# -------------------------------
	var rise_amount := 500.0
	var rise_speed := 120.0
	var target_y := head.global_position.y - rise_amount

	while abs(head.global_position.y - target_y) > 5.0:
		var delta := get_process_delta_time()
		head.global_position.y = move_toward(head.global_position.y, target_y, rise_speed * delta)
		await get_tree().process_frame

	# -------------------------------
	# Step 2 — First Dive (aim toward player)
	# -------------------------------
	print("[Bakunawa] → First Dive!")

	var dive_speed := 500.0
	var dive_target := player.global_position + Vector2(0, 300)

	while head.global_position.distance_to(dive_target) > 5.0:
		var delta := get_process_delta_time()
		var dir := (dive_target - head.global_position).normalized()
		head.global_position = head.global_position.move_toward(dive_target, dive_speed * delta)
		head.rotation = lerp_angle(head.rotation, dir.angle(), 5.0 * delta)
		await get_tree().process_frame

	# --- Beam Burst after dive ---
	_spawn_even_beams(player.global_position.x + 20, 40, 25.0, player.global_position.y - 400)
	print("[Bakunawa] → Beam Burst 1 Released!")
	await get_tree().create_timer(0.6).timeout

	# -------------------------------
	# Step 3 — Second Bite (rise up toward player)
	# -------------------------------
	print("[Bakunawa] → Second Bite (Rising)")

	var rise_speed_up := 400.0
	var rise_target := player.global_position - Vector2(0, 600)

	while abs(head.global_position.y - rise_target.y) > 5.0:
		var delta := get_process_delta_time()
		var dir := (rise_target - head.global_position).normalized()
		head.global_position = head.global_position.move_toward(rise_target, rise_speed_up * delta)
		head.rotation = lerp_angle(head.rotation, dir.angle(), 5.0 * delta)
		await get_tree().process_frame

	# --- Beam Burst after rise ---
	_spawn_even_beams(player.global_position.x, 40, 25.0, player.global_position.y - 400)
	await get_tree().create_timer(1.5).timeout
	_spawn_even_beams(player.global_position.x + 20, 40, 25.0, player.global_position.y - 400)
	print("[Bakunawa] → Beam Burst 2 Released!")

	await get_tree().create_timer(0.8).timeout

	print("[Bakunawa] → Twin Devour COMPLETE!")
	is_attacking = false

	# Optional: smooth return to idle hover
	if has_method("_start_idle_hover"):
		_start_idle_hover()



# -------------------------------
# Helper: Evenly spaced beam spawn
# -------------------------------
func _spawn_even_beams(center_x: float, num_beams: int, spacing: float, y_pos: float):
	var beam_scene = preload("res://Scene/Bakunawa_Beams.tscn")
	var start_x = center_x - ((num_beams - 1) / 2.0) * spacing
	for i in range(num_beams):
		var beam = beam_scene.instantiate()
		get_tree().current_scene.add_child(beam)
		var spawn_x = start_x + i * spacing
		beam.global_position = Vector2(spawn_x, y_pos)
		if beam.has_method("init"):
			beam.init(Vector2.DOWN)




# =====================
# === DAMAGE ==========
# =====================
func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if hp <= 0:
		return
	
	hp -= amount
	print("[Bakunawa] Took", amount, "damage →", hp, "HP left (Knockback:", knockback, ")")

	_flash_white()

	if hp <= 0:
		die()


# =====================
# === FLASH EFFECT ====
# =====================
func _flash_white() -> void:
	var all_parts: Array = [head] + segments
	for part in all_parts:
		if part is CanvasItem:
			part.modulate = Color(2.0, 2.0, 2.0)
	await get_tree().create_timer(0.05).timeout
	for part in all_parts:
		if part is CanvasItem:
			part.modulate = Color(1, 1, 1)

# =====================
# === DEATH ===========
# =====================
func die() -> void:
	is_attacking = true  # stop any attacks
	print("[Bakunawa] Defeated! Starting spiral death sequence...")

	# --------------------------
	# Step 1: Circular loop before rising
	# --------------------------
	var circle_radius = 200.0
	var circle_speed = 1.5  # radians per second
	var angle = 0.0
	var center = head.global_position

	var circle_duration = TAU / circle_speed  # one full loop
	var time_passed = 0.0

	while time_passed < circle_duration * 2:
		var delta = get_process_delta_time()
		time_passed += delta
		angle += circle_speed * delta

		head.global_position.x = center.x + cos(angle) * circle_radius
		head.global_position.y = center.y + sin(angle) * circle_radius

		await get_tree().process_frame

	# Snap to center after circle
	head.global_position = center

	# --------------------------
	# Step 2: Slowly rise upward in a wide wave
	# --------------------------
	var start_pos = head.global_position
	var target_y = start_pos.y - 2000
	var vertical_speed = 2.0          # very slow rise
	var wave_amplitude = 400.0        # very wide horizontal wave
	var wave_frequency = 0.25         # slow side-to-side movement
	var time_elapsed = 0.0

	var flash_timer = 0.0
	var flash_interval = 1.0

	while head.global_position.y > target_y:
		var delta = get_process_delta_time()
		time_elapsed += delta
		flash_timer += delta

		# Move upward slowly
		head.global_position.y = move_toward(head.global_position.y, target_y, vertical_speed * delta)

		# Apply wide horizontal wave
		head.global_position.x = start_pos.x + sin(time_elapsed * wave_frequency * TAU) * wave_amplitude

		# Flash red occasionally
		if flash_timer >= flash_interval:
			flash_timer = 0.0
			head.modulate = Color(1, 0, 0)
			await get_tree().process_frame
			head.modulate = Color(1, 1, 1)

		await get_tree().process_frame

	# Snap to final Y
	head.global_position.y = target_y

	await get_tree().create_timer(1.0).timeout
	queue_free()
