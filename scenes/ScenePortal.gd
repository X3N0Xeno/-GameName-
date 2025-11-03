extends Area2D

@export var target_scene: PackedScene

# This is the new, most important variable.
# You must set this in the Inspector (e.g., "punso_1", "punso_2")
@export var nuno_id: String = ""

var current_scene_path: String = ""

func _ready():
	if nuno_id.is_empty():
		print("ERROR: ScenePortal ", name, " has no nuno_id set!")
		return

	# Tell the manager this portal exists
	PortalManager.register_portal(nuno_id)

	# Check 1: Is this specific Nuno defeated?
	if PortalManager.is_nuno_defeated(nuno_id):
		queue_free()
		return

	# Check 2: Is this portal disabled from a previous use?
	if not PortalManager.is_portal_active(nuno_id):
		print("Portal: ", nuno_id, " disabled for this visit.")
		$CollisionShape2D.disabled = true
		# Assuming your sprite node is named "Nuno"
		$Nuno.modulate = Color(1, 1, 1, 0.5) 
		return

	print("Portal: ", nuno_id, " active.")
	current_scene_path = get_tree().current_scene.scene_file_path
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body.is_in_group("player"):
		
		if PortalManager.just_returned_from_portal:
			return 
		
		if not PortalManager.is_portal_active(nuno_id):
			return

		# --- UPDATE THIS LOGIC ---
		# 1. Set return point by direct variable access
		PortalManager.return_scene_path = current_scene_path
		PortalManager.return_position = global_position
		
		# 2. Tell the manager WHICH Nuno we are challenging
		PortalManager.set_current_nuno_challenge(nuno_id)
		
		# 3. Disable THIS portal
		PortalManager.set_portal_active(nuno_id, false)
		
		# 4. Teleport
		if get_tree().change_scene_to_file(target_scene.resource_path) != OK:
			print("Error: Could not change scene to ", target_scene.resource_path)

func _on_body_exited(body):
	if body.is_in_group("player"):
		if PortalManager.just_returned_from_portal:
			PortalManager.just_returned_from_portal = false
