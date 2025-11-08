extends Node2D # Assuming SavePoint is the root of your NPC scene

# --- Node References ---
@onready var interaction_area = $Area2D
@onready var prompt_label = $Label
@onready var animated_sprite = $AnimatedSprite2D # <--- ADD THIS LINE to reference your AnimatedSprite2D

var player_in_area := false
var player_node: Node2D = null # To store a reference to the player

func _ready():
	# Hide the prompt at the start
	prompt_label.visible = false

func _process(_delta):
	# Check for interaction input *only* if the player is in the area
	if player_in_area and Input.is_action_just_pressed("interact"):
		save_the_game()

func save_the_game():
	if player_node != null:
		# Call the global SaveManager and pass it the player's position
		SaveManager.save_game(player_node.global_position)
		
		# Give the player feedback
		prompt_label.text = "Game Saved!"
		print("Game saved!")
		
		# --- ADD THESE LINES TO PLAY ANIMATION ---
		if animated_sprite: # Make sure the sprite exists
			animated_sprite.play("default") # Replace "default" with your animation name, e.g., "save_animation"
		# ----------------------------------------
		
		# Optional: Add a sound effect
		# $AudioStreamPlayer.play()
	else:
		print("Error: Player node not found, cannot save.")

# --- Signal Functions ---

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		player_node = body # Save a reference to the player
		
		# Show the prompt
		prompt_label.text = "Press E to Save"
		prompt_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		player_node = null # Clear the player reference
		
		# Hide the prompt
		prompt_label.visible = false
