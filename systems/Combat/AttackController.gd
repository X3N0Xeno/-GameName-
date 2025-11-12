extends Node
@export var current_weapon: BaseWeapon

func _input(event):
	if event.is_action_pressed("attack") and current_weapon:
		current_weapon.attack()
