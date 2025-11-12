extends Node2D # Or whatever your Babaylan's root node is

# --- Node References ---
@onready var interaction_area = $Area2D
@onready var prompt_label = $Label
@onready var animated_sprite = $AnimatedSprite2D
@onready var fast_travel_menu = $FastTravelMenu # <-- Link to your new menu instance

var player_in_area := false
var player_node: Node2D = null

func _ready():
	prompt_label.visible = false
	
	# Connect the Area2D signals
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	
	# --- NEW: Connect to the Menu's signals ---
	fast_travel_menu.save_pressed.connect(_on_menu_save_pressed)
	fast_travel_menu.travel_pressed.connect(_on_menu_travel_pressed)
	fast_travel_menu.closed.connect(_on_menu_closed)


func _process(_delta):
	# When player presses "E", show the menu
	if player_in_area and Input.is_action_just_pressed("interact"):
		# Instead of saving, we now show the menu
		fast_travel_menu.show_menu()
		
		# You might want to pause the game here
		# get_tree().paused = true

# --- This is your OLD save_the_game() function, renamed ---
func _on_menu_save_pressed():
	if player_node != null:
		SaveManager.save_game(player_node.global_position)
		prompt_label.text = "Game Saved!"
		animated_sprite.play("default") # Or "save_anim"
	else:
		print("Error: Player node not found, cannot save.")

# --- This is the new fast travel logic ---
func _on_menu_travel_pressed(scene_path: String, spawn_point_name: String):
	# We use the same system as your LevelTransition portals
	PortalManager.next_spawn_point_name = spawn_point_name
	
	# Unpause the game before changing scenes
	# get_tree().paused = false 
	
	get_tree().call_deferred("change_scene_to_file", scene_path)

func _on_menu_closed():
	# If you paused the game, unpause it
	# get_tree().paused = false
	pass

# --- Signal Functions ---
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		player_node = body
		prompt_label.text = "Press E to Interact"
		prompt_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		player_node = null
		prompt_label.visible = false
