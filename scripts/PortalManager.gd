extends Node

# --- Direct Variables for Return ---
# We no longer use get/set/clear functions for these
var return_scene_path: String = ""
var return_position: Vector2 = Vector2.ZERO

var just_returned_from_portal: bool = false

# --- Dictionary for Portal States ---
# Stores state for "punso_1", "punso_2", etc.
var portal_states: Dictionary = {}

# Stores which Nuno we are currently fighting
var current_nuno_id: String = ""


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
