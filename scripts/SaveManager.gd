extends Node

# --- SaveManager.gd ---

# The save file path
const SAVE_PATH = "user://savegame.json"

# A variable to hold data *while* we are loading
var pending_load_data = {}

# --- This is the function your save point will call ---
func save_game(player_position: Vector2):
	# 1. Get the current scene path
	var scene_path = get_tree().current_scene.scene_file_path

	# 2. Create a dictionary of all data to save
	var save_data = {
		"last_scene": scene_path,
		"player_position_x": player_position.x,
		"player_position_y": player_position.y,

		# --- Upgrade / Flag Data ---
		"has_attack_upgrade": PortalManager.has_attack_upgrade,
		"has_dash_upgrade": PortalManager.has_dash_upgrade,
		"can_break_heavy_walls": PortalManager.can_break_heavy_walls,
		"has_ancestral_key": PortalManager.has_ancestral_key,
		"is_tikbalang_dead": PortalManager.is_tikbalang_dead,
		"is_lapulapu_dead": PortalManager.is_lapulapu_dead,
		"is_manananggal_dead": PortalManager.is_manananggal_dead,
		"is_kapre_dead": PortalManager.is_kapre_dead,
		"is_bungisngis_dead": PortalManager.is_bungisngis_dead,
		"is_black_lady_dead": PortalManager.is_black_lady_dead,
		"completed_puzzles": PortalManager.completed_puzzles
	}

	# 3. Open/create the save file
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	# 4. Store the data as a JSON string
	file.store_string(JSON.stringify(save_data))
	file.close()

	print("Game saved! Position: ", player_position)
	# You can add a "Game Saved!" UI popup here


# --- This is the function your "Load Game" button will call ---
func load_game():
	# 1. Check if the save file exists
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		return

	# 2. Open the file
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	# 3. Parse the JSON data
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		print("Error parsing save file!")
		return

	# 4. Store the loaded data *temporarily*
	var data = json.get_data()
	pending_load_data = data

	# --- Load the saved upgrade flags (default to false if missing) ---
	PortalManager.has_attack_upgrade = data.get("has_attack_upgrade", false)
	PortalManager.has_dash_upgrade = data.get("has_dash_upgrade", false)
	PortalManager.can_break_heavy_walls = data.get("can_break_heavy_walls", false)
	PortalManager.has_ancestral_key = data.get("has_ancestral_key", false)
	PortalManager.is_black_lady_dead = data.get("is_black_lady_dead", false)
	PortalManager.is_kapre_dead = data.get("is_kapre_dead", false)
	PortalManager.is_bungisngis_dead = data.get("is_bungisngis_dead", false)
	PortalManager.is_manananggal_dead = data.get("is_manananggal_dead", false)
	PortalManager.is_lapulapu_dead = data.get("is_lapulapu_dead", false)
	PortalManager.is_tikbalang_dead = data.get("is_tikbalang_dead", false)
	PortalManager.completed_puzzles = data.get("completed_puzzles", [])
	# Update the count based on the loaded array
	PortalManager.puzzles_completed_count = PortalManager.completed_puzzles.size()
	# 5. Go to the saved scene
	get_tree().change_scene_to_file(pending_load_data["last_scene"])


# --- This is the function your Player will call ---
func get_pending_load_position() -> Vector2:
	if pending_load_data.has("player_position_x"):
		var x = pending_load_data["player_position_x"]
		var y = pending_load_data["player_position_y"]

		# Clear the data after reading it
		pending_load_data = {}
		return Vector2(x, y)

	return Vector2.ZERO # No load data
