extends BaseWeapon

func _ready():
	super._ready()
	attack_damage = 30
	cooldown = 0.2
	print_debug("Sword3 initialized")
