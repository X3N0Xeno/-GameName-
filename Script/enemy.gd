extends CharacterBody2D

func _ready() -> void:
	add_to_group("Enemy")

func get_damage() -> int:
	var damage: int = 1
	return damage

func take_damage(damage: int):
	print("Enemy got hit for " , damage , " damage!")
