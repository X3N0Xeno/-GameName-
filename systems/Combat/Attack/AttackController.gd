extends Node
class_name AttackController

@export var hitbox: Hitbox
@export var attack_cooldown: float = 0.5
@export var hit_window: float = 0.2

var _can_attack: bool = true

func _input(event):
	if event.is_action_pressed("attack") and _can_attack:
		perform_attack()

func perform_attack() -> void:
	_can_attack = false

	if hitbox:
		# Set ownership
		hitbox.attack_owner = get_owner()

		# Activate hit window
		hitbox.activate()
		await get_tree().create_timer(hit_window).timeout
		hitbox.deactivate()

	# Cooldown before next attack
	await get_tree().create_timer(attack_cooldown).timeout
	_can_attack = true
