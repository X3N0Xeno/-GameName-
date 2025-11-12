extends CharacterBody2D

@export var HORIZONTAL_SPEED: float = 100.0
@export var INITIAL_UP_VELOCITY: float = 180.0
@export var GRAVITY: float = 180.0  # Reduced gravity for slower fall
@export var ANGLE_VARIATION: float = 30
@export var FLOOR_DELAY: float = 0.25  # seconds before breaking after landing
@export var HORIZONTAL_VARIATION: float = 300.0  # random horizontal offset

var launched: bool = false
var landed: bool = false

func _ready() -> void:
	_launch()
	
	var area = $Area2D
	if area:
		area.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))

func _launch() -> void:
	var angle_deg = randf_range(-ANGLE_VARIATION, ANGLE_VARIATION)
	var angle_rad = deg_to_rad(angle_deg)
	
	# Random horizontal speed around HORIZONTAL_SPEED ± HORIZONTAL_VARIATION
	var random_hor = HORIZONTAL_SPEED + randf_range(-HORIZONTAL_VARIATION, HORIZONTAL_VARIATION*0.5)
	var horizontal = cos(angle_rad) * random_hor
	
	velocity = Vector2(horizontal, -INITIAL_UP_VELOCITY)
	launched = true

func _physics_process(delta: float) -> void:
	if launched and not landed:
		velocity.y += GRAVITY * delta
		move_and_slide()

		if is_on_floor():
			landed = true
			var t = get_tree().create_timer(FLOOR_DELAY)
			t.timeout.connect(func(): queue_free())
			
func get_damage() -> int:
	return 1
