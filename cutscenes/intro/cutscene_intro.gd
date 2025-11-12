extends Node2D

func _ready() -> void:
	%Music.playing = true

##So the cutscene automatically loads when this scene gets instantiated or loaded.
##If you don't want that, disable autoplay on load sa AnimationPlayer
##and use a condition to trigger it instead.

func play_custscene() -> void:
	%AnimationPlayer.play("cutscene")

##THIS SKIPS THE CUTSCENE
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		%Music.play(71.0)
		%Fader.visible = true
		%Fader.color = Color()
		%Fader.modulate = Color(255.014, 255.014, 255.014, 1.0)
		%AnimationPlayer.stop()
		##INSERT GO TO OTHER SCENE CODE HERE OR DELETE THIS SCENE. HOWEVER U WANNA IMPLEMENT THE START SCREEN
		get_tree().change_scene_to_file("res://scenes/Museum_Dark.tscn")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scenes/Museum_Dark.tscn")


func _on_timer_timeout() -> void:
	$Label.visible = false
