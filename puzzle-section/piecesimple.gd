extends Sprite2D

var dragging = false

var cnct = null

func _process(_delta: float) -> void:
	if dragging:
		var newpos = get_global_mouse_position()
		position = newpos
	else:
		if cnct != null:
			position = cnct
			dragging = false
			cnct = null
			
func _on_button_button_down() -> void:
	dragging = true

func _on_button_button_up() -> void:
	dragging = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if dragging:
		cnct = area.get_parent().position
		cnct += area.position*2
