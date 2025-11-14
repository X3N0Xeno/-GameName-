extends Node2D

@export var intro_scene : PackedScene

func _ready() -> void:
	var intro = intro_scene.instantiate()
	add_child(intro)


func _on_buttplay_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Museum_Dark.tscn")

func _on_butt_credits_pressed() -> void:
	$AnimationPlayer.play("scroll_up")
	%Camera2D.position = Vector2(480.0, 90.0)

func _on_butt_quit_pressed() -> void:
	get_tree().quit()

func _on_butt_back_pressed() -> void:
	$AnimationPlayer.stop()
	%Camera2D.position = Vector2(160.0, 90.0)
