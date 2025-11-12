extends Area2D

# This flag makes sure we only trigger this once
var is_triggered := false

# --- Get references to our new nodes ---
@onready var info_label: Label = $InfoLabel
@onready var label_timer: Timer = $LabelTimer
@onready var sprite: Sprite2D = $Sprite2D # To hide the item
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	# Connect the signals
	body_entered.connect(_on_body_entered)
	label_timer.timeout.connect(_on_label_timer_timeout)
	
	# Start with the label hidden
	info_label.visible = false

func _on_body_entered(body):
	# Check if it's the player and if we haven't already been triggered
	if body.is_in_group("player") and not is_triggered:
		
		is_triggered = true # Lock this trigger
		
		print("Player has obtained the Heavy Wall Break ability!")
		
		# 1. Set the global flag
		PortalManager.can_break_heavy_walls = true
		
		# 2. Hide the item and its collision
		sprite.visible = false
		collision.disabled = true
		
		# (Optional: Add an AudioStreamPlayer node and play a sound here)
		# $AudioStreamPlayer.play()

		# 3. Set the label text and show it
		info_label.text = "You can now break heavy walls!"
		info_label.visible = true
		
		# 4. Start the timer to hide the label
		label_timer.start()

# This runs when the timer finishes
func _on_label_timer_timeout():
	# Now that the label has been shown, destroy the whole item
	queue_free()
