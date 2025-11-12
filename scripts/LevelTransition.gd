extends Area2D

@export var target_scene_path: String = ""
@export var target_spawn_point_name: String = ""

@export var is_puzzle_portal: bool = false
@export var puzzle_id: String = ""

@export var requires_flag: String = ""

var is_enabled := false

func _ready():
	body_entered.connect(_on_body_entered)

	# For puzzles, register them
	if is_puzzle_portal:
		PortalManager.register_puzzle(puzzle_id)

	# Start disabled if a flag is required
	if not requires_flag.is_empty():
		monitoring = false
	else:
		monitoring = true

func _process(_delta):
	if requires_flag.is_empty():
		return

	# Inline safe check for flag existence
	if not (requires_flag in PortalManager):
		return

	var flag_value = PortalManager.get(requires_flag)

	if flag_value == true and not is_enabled:
		is_enabled = true
		set_deferred("monitoring", true)
		print("[Portal] ✅ Unlocked:", name)
	elif flag_value == false and is_enabled:
		is_enabled = false
		set_deferred("monitoring", false)
		print("[Portal] 🔒 Locked:", name)


func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	# Handle puzzle portal behavior
	if is_puzzle_portal:
		PortalManager.puzzle_return_scene_path = get_tree().current_scene.scene_file_path
		PortalManager.puzzle_return_position = body.global_position
		PortalManager.set_puzzle_active(puzzle_id, false)

	# Set spawn point for the next scene
	PortalManager.next_spawn_point_name = target_spawn_point_name

	if target_scene_path.is_empty():
		print("Error: Target Scene Path is not set!")
		return

	get_tree().call_deferred("change_scene_to_file", target_scene_path)
