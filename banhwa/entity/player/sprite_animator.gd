extends Node2D

@export var player : Player
@export var MOV_FSM : StateMachine
@export var ATK_FSM : StateMachine

@onready var legs_anim : AnimationPlayer = %AnimationLegs
@onready var upper_anim : AnimationPlayer = %AnimationUpper
@onready var hitbox_pos : AnimationPlayer = %HitboxPosition
@onready var leg : Sprite2D = %Leg
@onready var upper : Sprite2D = %Upper
@onready var streak : Sprite2D = %Streak

#These check which wall the player is sliding
@onready var raycast_R : RayCast2D = $RightWallChecker
@onready var raycast_L : RayCast2D = $LeftWallChecker

var facingRight : bool = true
var override : bool = false

func _ready() -> void:
	#The player should be Idle and facing Right when first entering
	upper_anim.play("Idle")
	legs_anim.play("Idle")
	leg.flip_h = false
	upper.flip_h = false
	
	streak.visible = false
	
	#Connect the signals together
	if ATK_FSM:
		ATK_FSM.state_changed.connect(_on_attack_state_changed)
	if MOV_FSM:
		MOV_FSM.state_changed.connect(_on_movement_state_changed)

#Flips and Unflips the player's sprite when moving left or right
func _process(_delta: float) -> void:
	#print("DEBUG IN SpriteAnimator: " + override)
	if MOV_FSM.cur_state.name != "WallSlide":
		if player.facing_direction.x > 0:
			leg.flip_h = false
			upper.flip_h = false
			streak.flip_h = false
			facingRight = true
		else:
			leg.flip_h = true
			upper.flip_h = true
			streak.flip_h = true
			facingRight = false
			
	else: #If player is wall sliding, then...
		if raycast_R.is_colliding():
			leg.flip_h = true
			upper.flip_h = true
			streak.flip_h = true
			player.facing_direction.x = -1
			facingRight = false
		
		if raycast_L.is_colliding():
			leg.flip_h = false
			upper.flip_h = false
			streak.flip_h = false
			player.facing_direction.x = 1
			facingRight = true

func _on_movement_state_changed(state: String) -> void:
	leg.visible = true
	match state:
		"Idle":
			if !override:
				streak.visible = false
				upper_anim.play("Idle")
			legs_anim.play("Idle")
		"Run":
			if !override:
				streak.visible = false
				upper_anim.play("Run")
			legs_anim.play("Run")
		"Jump":
			if !override:
				streak.visible = false
				upper_anim.play("Jump")
			legs_anim.play("Jump")
		"Dash":
			upper_anim.play("Dash")
			legs_anim.play("Dash")
		"WallJump":
			if !override:
				streak.visible = false
				upper_anim.play("Jump")
			legs_anim.play("Jump")
		"WallSlide":
			leg.visible = false
			upper_anim.play("Wall_Slide")
		"Fall":
			if !override:
				streak.visible = false
				upper_anim.play("Fall")
			legs_anim.play("Fall")

#DEPRECATED
		#"Land":
			#leg.visible = false
			##upper_anim.play("Land")

func _on_attack_state_changed(state: String) -> void:
	match state:
		"Idle":
			player.can_pogo = false
			upper_anim.play("Idle")
			
		"Attack":
			player.can_pogo = false
			upper_anim.play("Attack_Side1")
			override = true #prioritize attack upper animation
			if facingRight:
				hitbox_pos.play("Attack_Side1_Right")
			else:
				hitbox_pos.play("Attack_Side1_Left")
		"Attack2":
			player.can_pogo = false
			upper_anim.play("Attack_Side2")
			override = true #prioritize attack upper animation
			if facingRight:
				hitbox_pos.play("Attack_Side2_Right")
			else:
				hitbox_pos.play("Attack_Side2_Left")
		"AttackUp":
			player.can_pogo = false
			upper_anim.play("Attack_Up")
			override = true
			hitbox_pos.play("Attack_Up")
		"AttackDown":
			upper_anim.play("Attack_Down")
			leg.visible = false
			override = true
			hitbox_pos.play("Attack_Down")

#func play_unique(anim_player: AnimationPlayer, anim_name: String):
	#if anim_player.current_animation != anim_name:
		#anim_player.play(anim_name)

func _on_animation_upper_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("Attack"):
		override = false
		_on_movement_state_changed(MOV_FSM.cur_state.name)
		#print("IN SPRITE ANIMATOR: GOING BACK TO " + MOV_FSM.cur_state.name)
