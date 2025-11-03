extends Area2D
signal damaged(damage: int)

func _ready():
	add_to_group("enemy_hurtbox")

func apply_damage(amount: int):
	emit_signal("damaged", amount)
