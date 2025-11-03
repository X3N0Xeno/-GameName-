extends Node2D

@export var attack_damage: int = 20   # 💥 Stronger sword
@export var cooldown := 0.3          # Faster swing
var can_attack := true

@onready var hitbox = $Hitbox
@onready var timer = Timer.new()

func _ready():
	hitbox.monitoring = false
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_cooldown_timeout"))

func attack():
	if not can_attack:
		return

	can_attack = false
	hitbox.attack_damage = attack_damage  # ✅ damage specific to Sword2
	hitbox.monitoring = true

	await get_tree().create_timer(0.2).timeout

	hitbox.monitoring = false
	timer.start(cooldown)

func _on_cooldown_timeout():
	can_attack = true
