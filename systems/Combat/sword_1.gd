extends BaseWeapon

func _ready():
	super._ready()
	attack_damage = 10
	cooldown = 0.5
	print_debug("Sword1 initialized")
