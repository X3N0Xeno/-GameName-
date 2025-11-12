extends Node

# --- Direct Variables for Return ---
# We no longer use get/set/clear functions for these
var return_scene_path: String = ""
var return_position: Vector2 = Vector2.ZERO
var next_spawn_point_name: String = ""
var puzzle_return_scene_path: String = ""
var puzzle_return_position: Vector2 = Vector2.ZERO

var just_returned_from_portal: bool = false
var has_attack_upgrade: bool = true
var can_break_heavy_walls: bool = true
var has_ancestral_key: bool = false
var has_dash_upgrade: bool = true
var is_lapulapu_dead: bool = false
var is_manananggal_dead: bool = false
var is_tikbalang_dead: bool = false
var is_bungisngis_dead: bool = false
var is_black_lady_dead: bool = false
var is_kapre_dead: bool = false

var puzzle_states: Dictionary = {}  # Tracks one-time-per-visit
var completed_puzzles: Array = []   # Tracks permanent completion
var puzzles_completed_count: int = 0
# --- Dictionary for Portal States ---
# Stores state for "punso_1", "punso_2", etc.
var portal_states: Dictionary = {}
var arena_states: Dictionary = {}

func register_arena(id: String):
	if not arena_states.has(id):
		arena_states[id] = {"active": true}
		print("Arena registered: ", id)

func is_arena_active(id: String) -> bool:
	if arena_states.has(id):
		return arena_states[id]["active"]
	return true # Default to active if not registered

func set_arena_active(id: String, is_active: bool):
	if arena_states.has(id):
		arena_states[id]["active"] = is_active

func re_enable_all_arenas():
	print("Re-enabling all arenas...")
	for id in arena_states:
		arena_states[id]["active"] = true

# Stores which Nuno we are currently fighting
var current_nuno_id: String = ""

var is_mactan_boss_dead: bool = false

# --- Portal State Management ---
func register_portal(id: String):
	if not portal_states.has(id):
		portal_states[id] = {"defeated": false, "active": true}

func set_portal_active(id: String, is_active: bool):
	if portal_states.has(id):
		portal_states[id]["active"] = is_active

func is_portal_active(id: String) -> bool:
	if portal_states.has(id):
		return portal_states[id]["active"]
	return true # Default to active if not registered

func is_nuno_defeated(id: String) -> bool:
	if portal_states.has(id):
		return portal_states[id]["defeated"]
	return false # Default to not defeated

func re_enable_all_portals():
	for id in portal_states:
		# Don't re-enable portals for defeated Nunos
		if not portal_states[id]["defeated"]:
			portal_states[id]["active"] = true

# --- Nuno Challenge Management ---
func set_current_nuno_challenge(id: String):
	current_nuno_id = id

func complete_current_nuno_challenge():
	if not current_nuno_id.is_empty():
		if portal_states.has(current_nuno_id):
			portal_states[current_nuno_id]["defeated"] = true
			portal_states[current_nuno_id]["active"] = false # Permanently disable
		else:
			portal_states[current_nuno_id] = {"defeated": true, "active": false}
		current_nuno_id = "" # Clear it after

func register_puzzle(id: String):
	if not puzzle_states.has(id):
		# Only register if it hasn't been permanently completed
		if not id in completed_puzzles:
			puzzle_states[id] = {"active": true}
			print("Puzzle registered: ", id)
		else:
			# This puzzle is already done, so register it as inactive
			puzzle_states[id] = {"active": false}

func is_puzzle_active(id: String) -> bool:
	if puzzle_states.has(id):
		return puzzle_states[id]["active"]
	return true # Default to active

func set_puzzle_active(id: String, is_active: bool):
	if puzzle_states.has(id):
		puzzle_states[id]["active"] = is_active

func re_enable_all_puzzles():
	print("Re-enabling all puzzles...")
	for id in puzzle_states:
		# Only re-enable if it's not in the *permanent* completed list
		if not id in completed_puzzles:
			puzzle_states[id]["active"] = true
