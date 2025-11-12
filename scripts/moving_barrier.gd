extends AnimatableBody2D

# Set this in the Inspector.
# e.g., (0, 200) to move 200 pixels down.
@export var move_offset: Vector2 = Vector2(0, 100)
@export var move_duration: float = 1.0

var open_position: Vector2

func _ready():
	# Save the starting (open) position
	open_position = global_position
	# Start with the collision disabled
	#$CollisionShape2D.disabled = true

func close_barrier():
	print("Closing barrier: ", name)
	# Enable collision so it's a solid wall
	#$CollisionShape2D.disabled = false
	
	# Tween to the closed position
	var tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position", open_position + move_offset, move_duration)

func open_barrier():
	print("Opening barrier: ", name)
	# Tween back to the open position
	var tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position", open_position, move_duration)
	
	# Wait until the tween is finished, *then* disable collision
	await tween.finished
	$CollisionShape2D.disabled = true
