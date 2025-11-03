extends Node2D
class_name BaseWeapon

@export var attack_damage: int = 10
@export var attack_duration: float = 0.2
@export var cooldown: float = 0.5

var can_attack: bool = true
var hitbox: Hitbox
var _cooldown_timer: Timer

func _ready():
	# Validate and setup hitbox
	if not has_node("Hitbox"):
		push_error("%s missing Hitbox child!" % name)
		return
	
	hitbox = $Hitbox
	hitbox.monitoring = false
	hitbox.attack_damage = attack_damage
	
	# Setup cooldown timer
	_cooldown_timer = Timer.new()
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(_cooldown_timer)
	
	print_debug("Weapon READY: %s" % name)

func attack():
	if not can_attack:
		print_debug("%s on cooldown" % name)
		return
	
	can_attack = false
	print_debug("%s ATTACK START" % name)
	
	# Activate hitbox
	hitbox.monitoring = true
	
	# Wait for attack duration
	await get_tree().create_timer(attack_duration).timeout
	
	# Deactivate hitbox
	hitbox.monitoring = false
	print_debug("%s attack window closed" % name)
	
	# Start cooldown
	_cooldown_timer.start(cooldown)

func _on_cooldown_timeout():
	can_attack = true
	print_debug("%s ready to attack" % name)
