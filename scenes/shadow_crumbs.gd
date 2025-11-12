extends Area2D

func _ready():
	# Connect the signal to ourself
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the node that entered is in the "player" group
	if body.is_in_group("player"):
		
		# (Optional: play your "poof" sound here)
		# $AudioStreamPlayer.play()
		
		# We're done, so remove the breadcrumb
		queue_free()
