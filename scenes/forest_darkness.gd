extends Area2D

# --- Drag your nodes here in the Inspector ---
@export var player_node: NodePath
@export var canvas_modulate_node: NodePath
# -------------------------------------------

# --- Tweak these values in the Inspector ---
# The Y-position where the darkness *starts*
@export var start_y: float = 200.0
# The Y-position where the darkness is *maximum*
@export var end_y: float = 1000.0
# The darkest color (0,0,0 is pitch black, 0.2,0.2,0.2 is dim)
@export var max_darkness: Color = Color(0.1, 0.1, 0.1)
# -------------------------------------------

var player_in_zone := false
var player: Node2D
var canvas_modulate: CanvasModulate

func _ready():
	# Connect the signals to ourself
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Get the nodes from the paths
	player = get_node_or_null(player_node)
	canvas_modulate = get_node_or_null(canvas_modulate_node)

func _physics_process(_delta):
	# If the player isn't in the zone, or if nodes are missing, do nothing.
	if not player_in_zone or not player or not canvas_modulate:
		return

	# This is the core logic:
	# 1. Get player's Y position
	var player_y = player.global_position.y
	
	# 2. Calculate a 0.0 to 1.0 value based on their position
	#    remap() converts one range (start_y to end_y) to another (0 to 1)
	var darkness_factor = remap(player_y, start_y, end_y, 0.0, 1.0)
	
	# 3. Clamp the value so it doesn't go below 0 or above 1
	darkness_factor = clamp(darkness_factor, 0.0, 1.0)
	
	# 4. Use lerp() to smoothly blend from WHITE to your max_darkness color
	canvas_modulate.color = Color.WHITE.lerp(max_darkness, darkness_factor)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_zone = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_zone = false
		
		# If the nodes are valid, fade back to white
		if canvas_modulate:
			var tween = create_tween()
			tween.tween_property(canvas_modulate, "color", Color.WHITE, 0.5)
