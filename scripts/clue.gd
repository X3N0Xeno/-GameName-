extends Node2D

@export var clue_index: int
@export var clue_text: String
@export var manager_path: NodePath
@export var popup_path: NodePath

var player_in_area := false
var found := false

func _ready():
	$Label.visible = false

func set_active(state: bool):
	print(name, " active set to ", state)
	$Area2D.monitoring = state
	$Area2D.monitorable = state
	visible = state

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		show_clue()

func show_clue():
	$Label.visible = false
	var popup = get_node(popup_path)
	popup.show_clue_text(clue_text)

	if not found:
		found = true
		var manager = get_node(manager_path)
		manager.clue_found(clue_index)

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		$Label.visible = true  # show “Press E”

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		$Label.visible = false  # hide “Press E”
