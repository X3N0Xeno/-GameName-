extends Node

@export var clues: Array[NodePath]  # paths to all Clue nodes

@export var altar_gate: AnimatableBody2D
@export var player_node: NodePath
@export var start_position: NodePath
@export var exit_zone: NodePath  # The red zone at location 5

var current_index := 0

func _ready():
	for i in range(clues.size()):
		var clue = get_node(clues[i])
		clue.visible = (i == 0)
		clue.set_active(i == 0)

func clue_found(index: int):
	if index == current_index:
		current_index += 1
		if current_index < clues.size():
			var next_clue = get_node(clues[current_index])
			next_clue.visible = true
			next_clue.set_active(true)
			print("Next clue revealed:", next_clue.name)
		else:
			# --- REPLACE YOUR OLD 'else' BLOCK WITH THIS ---
			print("All clues discovered! Teleporting player and opening exit.")
			if altar_gate:
				altar_gate.open_gate()
			# 1. Teleport the player
			var player = get_node(player_node)
			var start_pos = get_node(start_position)
			if player and start_pos:
				player.global_position = start_pos.global_position
			else:
				print("Player or Start Position not set in Clue Progression node.")
			
			# 2. Deactivate the exit zone
			var zone = get_node(exit_zone)
			if zone:
				# This permanently removes the red zone.
				zone.queue_free()
			else:
				print("Exit Zone not set in Clue Progression node.")
			# ----------------------------------------------------
