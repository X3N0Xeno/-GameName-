extends Node

# Signal for when health changes (for UI, "hit flash" effects)
signal health_changed(old_hp, new_hp)
# Signal for when health reaches zero
signal died

@export var max_health: int = 5
var current_health: int

func _ready():
	# Start at full health
	current_health = max_health

# This is the function enemies (or traps) will call
func take_damage(amount: int):
	# If we're already dead, don't do anything
	if current_health <= 0:
		return

	var old_hp = current_health
	current_health = max(0, current_health - amount)
	
	# Let the player script (and UI) know the health changed
	health_changed.emit(old_hp, current_health)
	
	# If we just died, let the player script know
	if current_health <= 0:
		died.emit()
