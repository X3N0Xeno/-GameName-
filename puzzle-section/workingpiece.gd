extends Sprite2D

var dragging: bool = false
var cluster: Array = []   # group of fragments moving together
var pending_snap: Dictionary = {}  # store snap info until button_up

static var counter = 0;

# Define valid connections (fragment:side → fragment:side)
const VALID_CONNECTIONS = {
	"Fragment 1:Right": "Fragment 2:Left",
	"Fragment 1:Down": "Fragment 3:Top",
	"Fragment 2:Left": "Fragment 1:Right",
	"Fragment 2:Down": "Fragment 4:Top",
	"Fragment 3:Top": "Fragment 1:Down",
	"Fragment 3:Down": "Fragment 5:Top",
	"Fragment 3:Right": "Fragment 4:Left",
	"Fragment 4:Top": "Fragment 2:Down",
	"Fragment 4:Down": "Fragment 6:Top",
	"Fragment 4:Left": "Fragment 3:Right",
	"Fragment 5:Right": "Fragment 6:Left",
	"Fragment 5:Top": "Fragment 3:Down",
	"Fragment 6:Left": "Fragment 5:Right",
	"Fragment 6:Top": "Fragment 4:Down"
}

func _ready() -> void:
	cluster = [self]
	for side in ["Right", "Left", "Top", "Down"]:
		if has_node(side):
			var area: Area2D = get_node(side)
			area.area_entered.connect(_on_area_entered.bind(side))

func _process(_delta: float) -> void:
	if dragging:
		var mouse_pos = get_global_mouse_position()
		var delta = mouse_pos - global_position
		for piece in cluster:
			piece.global_position += delta

func _on_button_button_down() -> void:
	dragging = true
	pending_snap.clear()

func _on_button_button_up() -> void:
	dragging = false
	if pending_snap.has("other_piece"):
		counter += 1
		var other_piece: Sprite2D = pending_snap["other_piece"]
		var my_side: String = pending_snap["my_side"]

		# calculate snap offset based on sprite size and side
		var my_half = texture.get_size() * 0.5 * scale
		var snap_offset := Vector2.ZERO

		match my_side:
			"Right": #change + to -
				snap_offset = Vector2(-(my_half.x *2),0)
			"Left":
				snap_offset = Vector2((my_half.x *2), 0)
			"Top":
				snap_offset = Vector2(0, (my_half.y *2))
			"Down":
				snap_offset = Vector2(0, -(my_half.y *2))

		var target_pos = other_piece.global_position + snap_offset
		var delta = target_pos - global_position

		for piece in cluster:
			piece.global_position += delta

		if other_piece.cluster != cluster:
			cluster = cluster + other_piece.cluster
			for piece in cluster:
				piece.cluster = cluster
	
	pending_snap.clear()
	print(counter)
	if counter == 5:
			game_over()

func _on_area_entered(other_area: Area2D, my_side: String) -> void:
	if not dragging:
		return

	var other_piece: Sprite2D = other_area.get_parent() as Sprite2D
	if other_piece == null or other_piece == self:
		return

	var my_key = name + ":" + my_side
	var other_key = other_piece.name + ":" + other_area.name

	if VALID_CONNECTIONS.has(my_key) and VALID_CONNECTIONS[my_key] == other_key:
		pending_snap = {
			"other_piece": other_piece,
			"my_side": my_side,
			"other_side": other_area.name
		}
		
func game_over() -> void:
	dragging = false

	# Disable dragging on all pieces in the cluster
	for piece in cluster:
		if piece.has_node("Button"):
			var btn = piece.get_node("Button")
			btn.disabled = true

	# Calculate cluster center (average position of all pieces)
	var cluster_center := Vector2.ZERO
	for piece in cluster:
		cluster_center += piece.global_position
	cluster_center /= cluster.size()

	# Get the camera center in world space
	var camera := get_viewport().get_camera_2d()
	var target_center := Vector2.ZERO
	if camera:
		target_center = camera.get_screen_center_position()
	else:
		# fallback: center of viewport in world coordinates
		target_center = get_viewport_rect().size * 0.5

	# Calculate the shift vector
	var shift := target_center - cluster_center

	# Tween all pieces so the cluster moves smoothly
	var tween := create_tween()
	for piece in cluster:
		tween.tween_property(
			piece, "global_position",
			piece.global_position + shift, 
			0.67
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
