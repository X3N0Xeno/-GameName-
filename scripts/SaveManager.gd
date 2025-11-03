extends Node

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
		# Add other things here, like:
		# "player_health": player.health,
		# "clues_found": ClueProgression.current_index,
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
	pending_load_data = json.get_data()

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
