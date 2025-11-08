extends CharacterBody2D

# Constants 
const GRAVITY = 500.0
const SPEED = 150.0
const CHARGE_MULTIPLIER = 2.0 
const DETECTION_RANGE = 300.0
const JUMP_DISTANCE = 200.0      # how close horizontally before pounce triggers
const JUMP_FORCE = -200.0  
const POUNCE_SPEED = 900.0      # faster forward speed when pouncing
const max_hp = 3


# References
@onready var player = $"res://Scenes/hk.tscn"  # Adjust path as needed
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

#Variable
var is_knocked_back = false
var hp
var can_jump := true             # prevents repeated pounces in the air

func _ready() -> void:
	hp = max_hp
	sprite.play("walk")

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
		can_jump = true  # reset pounce ability when touching ground

	if not is_knocked_back:
		if player and global_position.distance_to(player.global_position) <= DETECTION_RANGE:
			var dir_to_player = (player.global_position - global_position).normalized()

			#Pounce behavior
			if can_jump and abs(player.global_position.x - global_position.x) <= JUMP_DISTANCE and is_on_floor():
				velocity.y = JUMP_FORCE
				velocity.x = dir_to_player.x * POUNCE_SPEED
				can_jump = false
			else:
				# Normal chase toward player
				velocity.x = dir_to_player.x * SPEED * CHARGE_MULTIPLIER
		else:
			#Idle (stand still) when outside detection range
			velocity.x = 0
	else:
		# Knockback deceleration
		velocity = velocity.move_toward(Vector2.ZERO, 1000 * delta)

	# Apply movement
	move_and_slide()

	# Flip sprite
	if not is_knocked_back and velocity.x != 0:
		sprite.flip_h = velocity.x < 0


#Debug input (test damage)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test_damage"):
		if player:
			take_damage(1, player.global_position)


# Knockback + Damage Handling
func take_damage(amount: int, from: Vector2) -> void:
	hp -= amount
	print("Zombie HP:", hp)

	if hp <= 0:
		queue_free()
		return

	var knock_dir = (global_position - from).normalized()
	velocity = knock_dir * 400
	is_knocked_back = true
	
	var knock_timer := get_tree().create_timer(0.2)
	knock_timer.timeout.connect(func(): is_knocked_back = false)
