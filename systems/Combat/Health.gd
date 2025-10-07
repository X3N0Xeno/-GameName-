extends Node
class_name Health

signal health_changed(old_hp: int, new_hp: int)
signal died()

@export var max_health: float = 100
@export var regen_rate: float = 0  # health per second, 0 = no regen

var current_health: float

func _ready():
	current_health = max_health

func take_damage(amount: int) -> void:
	var old_hp = current_health
	current_health = clamp(current_health - amount, 0, max_health)
	emit_signal("health_changed", int(old_hp), int(current_health))
	if current_health == 0:
		emit_signal("died")

func heal(amount: int) -> void:
	var old_hp = current_health
	current_health = clamp(current_health + amount, 0, max_health)
	emit_signal("health_changed", int(old_hp), int(current_health))

func is_alive() -> bool:
	return current_health > 0

# Optionally call this every frame or via a Timer if regen_rate > 0
func _process(delta: float) -> void:
	if regen_rate > 0.0 and current_health < max_health:
		var before = current_health
		heal(regen_rate * delta)
		if current_health != before:
			print("Regenerated to:", current_health)
