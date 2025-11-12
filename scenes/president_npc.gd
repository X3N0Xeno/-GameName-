extends Sprite2D # Or whatever your NPC's root node is

@onready var prompt_label = $Label
@onready var interaction_area = $Area2D

var player_in_area := false

func _ready():
	prompt_label.visible = false
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		# --- This is the key part ---
		# Check if we already have the key
		if not PortalManager.has_ancestral_key:
			# If not, give the buff/key
			print("Player has been buffed! Got the Ancestral Key!")
			PortalManager.has_ancestral_key = true
			
			# (This is where you'd also add the health/damage buff)
			# PlayerStats.health += 1 
			
			prompt_label.text = "Thank you, Mr. President!"
		else:
			# If we already have the key, just say thanks
			prompt_label.text = "Thank you again!"
			

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		
		# Change the prompt text based on if we have the key
		if PortalManager.has_ancestral_key:
			prompt_label.text = "Thank you again!"
		else:
			prompt_label.text = "Press E to talk"
			
		prompt_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		prompt_label.visible = false
