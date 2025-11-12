extends Node

# --- Drag your nodes here in the Inspector ---
@export var boss_scene: PackedScene           # The Black Lady's .tscn file
@export var boss_spawn_position: Marker2D    # A Marker2D for where she appears
@export var boss_spawn_pos : Vector2 ##VECTOR2 VERSION
@export var battle_trigger: Area2D           # The Area2D you just made
@export var barriers: Array[NodePath]        # We'll put all 3 barriers/doors here
@export var camera_manager: Camera2D           # The Camera2D node
@export var arena_camera_position: Marker2D  # The Marker2D for the arena view
@export var arena_zoom: Vector2 = Vector2(1.5, 1.5) # How much to zoom out
@export var original_zoom: Vector2 = Vector2(1.0, 1.0) # The normal zoom
# -------------------------------------------

var battle_started := false

func _ready():
	# Connect the trigger area to our start_battle function
	battle_trigger.body_entered.connect(start_battle)

func start_battle(body):
	if body.is_in_group("player") and not battle_started:
		battle_started = true
		print("--- BOSS BATTLE STARTED! ---")
		
		# --- (Old code: disable trigger, close barriers) ---
		battle_trigger.monitoring = false
		for barrier_path in barriers:
			get_node(barrier_path).close_barrier()
			
		# --- ADD THIS: Tell camera to move ---
		if camera_manager:
			camera_manager.focus_on_arena(arena_camera_position.global_position, arena_zoom)
			
		# 3. Spawn the boss
#		var boss = boss_scene.instantiate()
#		boss.global_position = boss_spawn_position.global_position
		var boss = boss_scene.instantiate()
		boss.global_position = boss_spawn_pos
		add_child(boss)
		
		# 4. VERY IMPORTANT: Connect the boss's "defeated" signal to our end_battle function
#		boss.boss_defeated.connect(end_battle)
#		add_child(boss)

func end_battle():
	print("--- BOSS BATTLE ENDED! ---")
	PortalManager.is_mactan_boss_dead = true
	# --- (Old code: open barriers) ---
	for barrier_path in barriers:
		get_node(barrier_path).open_barrier()
		
	# --- ADD THIS: Tell camera to return ---
	if camera_manager:
		camera_manager.resume_following_player(original_zoom)

func _on_battle_trigger_body_entered(body: Node2D) -> void:
	if !battle_started:
		pass
