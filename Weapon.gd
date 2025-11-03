extends Node
class_name Weapon

@export var damage: int = 10
@export var attack_cooldown: float = 0.3
@export var hitbox: Hitbox

var can_attack: bool = true

func attack(owner: Node) -> void:
	if not can_attack:
		return

	can_attack = false
	if hitbox:
		hitbox.attack_owner = owner
		hitbox.activate()
		await get_tree().create_timer(0.1).timeout  # small hit window
		hitbox.deactivate()

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
