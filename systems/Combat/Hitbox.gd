extends Area2D
class_name Hitbox

@export var damage: int = 10
@export var attack_owner: Player  # the player or entity this hitbox belongs to

var _hit_targets: Array[Area2D] = []
var _active: bool = false

func _ready():
	monitoring = false
	# Make sure collision shapes start disabled so nothing triggers initially
	_disable_shapes()
	connect("area_entered", Callable(self, "_on_area_entered"))

func activate():
	_hit_targets.clear()
	_active = true
	monitoring = true
	_enable_shapes()

func deactivate():
	_active = false
	monitoring = false
	_disable_shapes()

func _on_area_entered(area: Area2D) -> void:
	# Only respond when active
	if not _active:
		return

	# Prevent hitting the same hurtbox more than once per activation
	if area in _hit_targets:
		return

	# Ignore overlapping self
	if area == self:
		return

	var target_owner = area.get_owner()
	# Ignore the owner’s own hurtbox
	if attack_owner and target_owner == attack_owner:
		return

	if area is Hitbox:
		# Don’t hit other hitboxes
		return

	# Try to apply damage
	if target_owner and target_owner.has_method("take_damage"):
		_hit_targets.append(area)
		target_owner.take_damage(damage)

# Helpers to enable / disable collision shapes under this Area2D
func _enable_shapes():
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false

func _disable_shapes():
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true
