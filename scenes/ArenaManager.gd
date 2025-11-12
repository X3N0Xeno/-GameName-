extends Area2D

# This is a unique name for this arena
@export var arena_id: String = "arena_1"

# --- Drag nodes here in the Inspector ---
@export var barriers: Array[NodePath]
@export var enemy_scene: PackedScene # The .tscn file of the enemy to spawn
@export var spawn_points: Array[NodePath] # All the Marker2Ds
@export var enemy_count: int = 5
# ----------------------------------------

var enemies_remaining: int = 0
var is_active: bool = true

func _ready():
	if arena_id.is_empty():
		print("ARENA ERROR: ArenaManager needs a unique 'arena_id'!")
		return

	# 1. Register with the global manager
	PortalManager.register_arena(arena_id)
	
	# 2. Check if this arena should be active
	is_active = PortalManager.is_arena_active(arena_id)
	
	if not is_active:
		# This arena was already cleared this visit. Deactivate tripwire.
		monitoring = false
		return
		
	# 3. Connect the tripwire signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and is_active:
		print("Arena '", arena_id, "' triggered!")
		
		# 1. Deactivate self to prevent re-triggering
		is_active = false
		PortalManager.set_arena_active(arena_id, false)
		
		# 2. Lock the doors and spawn enemies
		_close_barriers()
		_spawn_enemies()

func _close_barriers():
	for path in barriers:
		get_node(path).close_barrier()

func _open_barriers():
	for path in barriers:
		get_node(path).open_barrier()

func _spawn_enemies():
	enemies_remaining = enemy_count
	
	for i in enemy_count:
		if not enemy_scene: 
			print("ARENA ERROR: No enemy_scene set!")
			continue
			
		var enemy = enemy_scene.instantiate()
		
		# Pick a random spawn point
		var spawn_node = get_node_or_null(spawn_points.pick_random())
		if spawn_node:
			# Add enemy to the main scene (not this Area2D)
			get_parent().call_deferred("add_child",enemy)
			enemy.global_position = spawn_node.global_position
		else:
			print("ARENA ERROR: Invalid spawn point!")
		
		# --- VERY IMPORTANT ---
		# Your enemy script MUST have a "died" signal
		enemy.get_node_or_null("CharacterBody2D").died.connect(_on_enemy_died)

func _on_enemy_died():
	enemies_remaining -= 1
	print(enemies_remaining, " enemies left.")
	
	if enemies_remaining <= 0:
		_on_arena_cleared()

func _on_arena_cleared():
	print("Arena '", arena_id, "' CLEARED!")
	# Open the doors
	_open_barriers()
