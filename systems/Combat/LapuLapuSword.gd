extends BaseWeapon

func _ready():
	super._ready()
	attack_damage = 20  # stronger
	cooldown = 0.3      # faster
	print_debug("Sword2 (Lapu-Lapu Sword) initialized")
