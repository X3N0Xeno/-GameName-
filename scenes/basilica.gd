extends Node2D

# --- Drag these nodes here from the Scene dock ---
@export var canvas_modulate: CanvasModulate
@export var dark_zone_trigger: Area2D
#@export var prop_tilemap: TileMapLayer
@export var wall_tilemap: TileMapLayer # Your 'Wall' node
@export var player: CharacterBody2D    # Your 'Player' node

# Add more @export vars here for any other nodes that need to
# be affected (like your NPCs, props, etc.)
@export var babaylan_npc: Node2D # Your 'Babaylan (Save)' node
# ---------------------------------------------------

# 1. Preload the new material resource you just made
var dark_material = preload("res://scripts/dark_light_only_material.tres") # Make sure this path is correct!

# 2. Variables to store the *original* materials
var default_wall_material: Material
#var default_prop_material: Material
var default_player_sprite_material: Material
var default_npc_sprite_material: Material # For the Babaylan

# We need to get the actual sprite nodes from the parents
@onready var player_sprite = player.get_node("Sprite") # Assumes player's sprite is named "Sprite2D"
@onready var npc_sprite = babaylan_npc.get_node("AnimatedSprite2D") # Assumes Babaylan's sprite is "AnimatedSprite2D"

func _ready():
	# 3. Store the original materials when the game starts
	if wall_tilemap:
		default_wall_material = wall_tilemap.material
	#if prop_tilemap:
	#	default_prop_material = prop_tilemap.material
	if player_sprite:
		default_player_sprite_material = player_sprite.material
	if npc_sprite:
		default_npc_sprite_material = npc_sprite.material
		


func _on_dark_zone_trigger_body_entered(body):
	if body.is_in_group("player"):
		# 1. Fade the scene to black
		var tween = create_tween()
		tween.tween_property(canvas_modulate, "color", Color(0.25, 0.25, 0.25, 1.0), 0.5) 

		# 2. Apply the "Light Only" material to all nodes
		if wall_tilemap: wall_tilemap.material = dark_material
#		if wall_tilemap: prop_tilemap.material = dark_material
		if player_sprite: player_sprite.material = dark_material
		if npc_sprite: npc_sprite.material = dark_material
		# (Add more lines here for other props/NPCs)

func _on_dark_zone_trigger_body_exited(body):
	if body.is_in_group("player"):
		# 1. Fade back to white (normal visibility)
		var tween = create_tween()
		tween.tween_property(canvas_modulate, "color", Color.WHITE, 0.5)

		# 2. Revert all nodes to their original, default materials
		if wall_tilemap: wall_tilemap.material = default_wall_material
#		if wall_tilemap: prop_tilemap.material = default_prop_material
		if player_sprite: player_sprite.material = default_player_sprite_material
		if npc_sprite: npc_sprite.material = default_npc_sprite_material
		# (Add more lines here for other props/NPCs)
