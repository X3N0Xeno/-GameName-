extends CharacterBody2D

const SPEED = 50.0
const VISIBLE_RANGE = 300.0  # distance where ghost fades in

@export var max_hp: int = 3
@onready var tar = $"../../HK"

var hp: int
var target_visible := false
var is_knocked_back := false

# Max HP setter
func _ready() -> void:
	hp = max_hp

func _physics_process(delta: float) -> void:
	if not tar:
		return

	# Distance of MC and the ghost
	var dist = global_position.distance_to(tar.global_position)
	# Boolean check
	var should_be_visible = dist <= VISIBLE_RANGE
	
	# Check if inside distance and fade in/out accordingly
	if should_be_visible != target_visible:
		target_visible = should_be_visible
		_fade(target_visible)

	if not is_knocked_back and should_be_visible:
		var direction = (tar.global_position - global_position).normalized()
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 600 * delta)
		
	move_and_slide()

# Knockback + Damage
func take_damage(amount: int, from: Vector2) -> void:
	hp -= amount
	print("Ghost HP:", hp)

	if hp <= 0:
		queue_free()  # ghost dies
		return

	var knock_dir = (global_position - from).normalized()
	velocity = knock_dir * 400
	is_knocked_back = true

	var knock_timer := get_tree().create_timer(0.2)
	knock_timer.timeout.connect(func(): is_knocked_back = false)

# Test damage input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test_damage"):
		if tar:
			take_damage(1, tar.global_position)

# Fade effect
func _fade(show: bool) -> void:
	var tween = get_tree().create_tween()
	if show:
		tween.tween_property(self, "modulate:a", 1.0, 0.5)
	else:
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
\
