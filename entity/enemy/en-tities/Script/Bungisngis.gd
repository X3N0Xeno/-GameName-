extends Node2D

# === base stats ===========
@export var MAX_HP: int = 80
@export var PHASE2_HP_THRESHOLD: int = 40  # HP to trigger Phase 2

@export var ROCK_COOLDOWN: float = 1.5       # faster rock spawn
@export var SHOCKWAVE_COOLDOWN: float = 3.5  # slower shockwave
@export var LOB_COOLDOWN: float = 4.0        # lob attack cooldown

@export var CLOSE_RANGE_DISTANCE: float = 300.0  # no rocks if player is closer

@export var ROCK_SCENE: PackedScene = preload("res://Scenes/Rock.tscn")
@export var SHOCKWAVE_SCENE: PackedScene = preload("res://Scenes/Shockwave.tscn")
@export var LOB_SCENE: PackedScene = preload("res://Scenes/Lob.tscn")

# === NODE REFERENCES(is that a reference reference) ==
@onready var rock_spawn: Marker2D = $RockSpawn
@onready var shock_spawn: Marker2D = $ShockSpawn
@onready var lob_spawn: Marker2D = $LobSpawn
@onready var player: Node2D = get_node("../../HK")  #repath ni HA

# === STATE ============
var hp: int
var attack_timer: float = 0.0
var rng := RandomNumberGenerator.new()

# Original cooldowns for phase calculations
var original_rock_cd: float
var original_shock_cd: float
var original_lob_cd: float

func _ready() -> void:
	hp = MAX_HP
	rng.randomize()
	print("[Bungisngis] Ready! HP =", hp)

	# Save original cooldowns
	original_rock_cd = ROCK_COOLDOWN
	original_shock_cd = SHOCKWAVE_COOLDOWN
	original_lob_cd = LOB_COOLDOWN

func _process(delta: float) -> void:
	if hp <= 0 or not player:
		return

	var distance = global_position.distance_to(player.global_position)

	# Phase 2: increase attack speed(naka inspire)
	if hp <= PHASE2_HP_THRESHOLD:
		ROCK_COOLDOWN = original_rock_cd * 0.75
		LOB_COOLDOWN = original_lob_cd * 0.75
		# edge case amp
		#chokewave cd if close
		if distance <= CLOSE_RANGE_DISTANCE:
			SHOCKWAVE_COOLDOWN = original_shock_cd * 0.5  # close-range: faster shockwave
		else:
			SHOCKWAVE_COOLDOWN = original_shock_cd * 0.75
	else:
		ROCK_COOLDOWN = original_rock_cd
		LOB_COOLDOWN = original_lob_cd
		if distance <= CLOSE_RANGE_DISTANCE:
			SHOCKWAVE_COOLDOWN = original_shock_cd * 0.5
		else:
			SHOCKWAVE_COOLDOWN = original_shock_cd

	# Countdown timer
	attack_timer -= delta
	if attack_timer <= 0.0:
		_attack(distance)

# === ATTACKS ==========
func _attack(distance: float) -> void:
	if not player:
		return

	var choice = 0

	if distance <= CLOSE_RANGE_DISTANCE:
		# Close-range: only shockwave or lob
		print("Close") #debug ra
		choice = rng.randi_range(2, 3)
	else:
		# Far: any attack
		choice = rng.randi_range(1, 3)

	match choice:
		1:
			_spawn_rock()
			attack_timer = ROCK_COOLDOWN
		2:
			_spawn_shockwave()
			attack_timer = SHOCKWAVE_COOLDOWN
		3:
			_spawn_lob_rock()
			attack_timer = LOB_COOLDOWN

# --- Spawn Rock ---
func _spawn_rock() -> void:
	if not ROCK_SCENE or not rock_spawn:
		return
	var rock = ROCK_SCENE.instantiate()#java reference
	get_tree().current_scene.add_child(rock)
	rock.global_position = rock_spawn.global_position
	print("[Bungisngis] Rock spawned at", rock.global_position) #debug sad

# --- Spawn Shockwave ---
func _spawn_shockwave() -> void:
	if not SHOCKWAVE_SCENE or not shock_spawn:
		return
	var shock = SHOCKWAVE_SCENE.instantiate()#still java reference
	get_tree().current_scene.add_child(shock)
	shock.global_position = shock_spawn.global_position
	print("[Bungisngis] Shockwave spawned at", shock.global_position)

# --- Spawn Lob Rocks ---
func _spawn_lob_rock() -> void:
	if not LOB_SCENE or not lob_spawn:
		return
	var lob_count = 7 if hp <= PHASE2_HP_THRESHOLD else 5

	for i in range(lob_count):
		var lob = LOB_SCENE.instantiate()
		get_tree().current_scene.add_child(lob)
		var offset = (i - int(lob_count / 2)) * 16  # spread horizontally thanks gpt
		lob.global_position = lob_spawn.global_position + Vector2(offset, 0)
		print("[Bungisngis] Lob Rock spawned at", lob.global_position)

# === DAMAGE ===========
func take_damage(amount: int, from: Vector2) -> void:
	hp -= amount
	print("[Bungisngis] HP:", hp)
	if hp <= 0:
		print("[Bungisngis] stopped bungisngising!")
		queue_free()
