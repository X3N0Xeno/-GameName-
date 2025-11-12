extends Node

# --- Drag these in the Inspector ---
@export var player: CharacterBody2D
@export var nuno_instance: Node2D  # Drag your Nuno node from the scene here
@export var spawn_locations: Node    # Drag your "SpawnLocations" node here
# -----------------------------------

var spawn_markers: Array[Marker2D] = [] # We'll fill this automatically
var current_location_index := 0
var touches_remaining := 4
var timer: Timer

func _ready():
	# 1. Get all the spawn point markers
	for marker in spawn_locations.get_children():
		if marker is Marker2D:
			spawn_markers.append(marker)
	
	# 2. Create the 60-second timer
	timer = Timer.new()
	timer.wait_time = 30.0
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	# 3. Connect to the Nuno's "touched" signal
	nuno_instance.player_touched.connect(_on_player_touched)
	
	# 4. Start the game!
	spawn_nuno(true) # 'true' for first spawn

func spawn_nuno(is_first_spawn: bool = false):
	if is_first_spawn:
		# Rule: First spawn is always at the topmost location (index 0)
		current_location_index = 0
	else:
		# Rule: Find a new random location
		var valid_indices = get_valid_spawn_indices()
		current_location_index = valid_indices.pick_random()
	
	# Move the Nuno and start the timer (if not the first spawn)
	nuno_instance.global_position = spawn_markers[current_location_index].global_position
	print("Nuno teleported to: ", spawn_markers[current_location_index].name)
	
	if not is_first_spawn:
		timer.start()

func get_valid_spawn_indices() -> Array[int]:
	var valid_indices: Array[int] = []
	
	# Find the location nearest to the player
	var nearest_to_player_index = -1
	var min_dist_sq = INF
	
	for i in spawn_markers.size():
		var pos = spawn_markers[i].global_position
		var dist_sq = player.global_position.distance_squared_to(pos)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			nearest_to_player_index = i
			
	# Rule: Can't be current location or location nearest to player
	for i in spawn_markers.size():
		if i == current_location_index:
			continue
		if i == nearest_to_player_index:
			continue
		valid_indices.append(i)
		
	# Failsafe: If rules leave no options (e.g., only 2 spawns)
	# just pick any location that isn't the current one.
	if valid_indices.is_empty():
		for i in spawn_markers.size():
			if i != current_location_index:
				valid_indices.append(i)
				
	return valid_indices

func _on_player_touched():
	touches_remaining -= 1
	timer.stop()
	print("Player touched Nuno! ", touches_remaining, " touches remaining.")
	
	if touches_remaining <= 0:
		defeat_nuno()
	else:
		# Teleport to a new location
		spawn_nuno()

func _on_timer_timeout():
	print("Time's up! Nuno teleports.")
	spawn_nuno()

func defeat_nuno():
	print("Nuno is defeated!")
	nuno_instance.queue_free()

	# Tell the manager the current challenge is done
	PortalManager.complete_current_nuno_challenge()

	# (Rest of your return logic...)
	# Access variable directly
	var return_scene = PortalManager.return_scene_path
	
	if return_scene.is_empty():
		print("NunoManager ERROR: No return scene set!")
		return
		
	get_tree().change_scene_to_file(return_scene)
