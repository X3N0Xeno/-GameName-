class_name Hitbox
extends Area2D

var attack_damage: int = 0

func _ready():
	body_entered.connect(_on_body_entered)
	monitoring = false
	print_debug("Hitbox READY at %s" % global_position)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		return
	
	print_debug("HITBOX HIT %s FOR %d DAMAGE" % [body.name, attack_damage])
	
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)
