extends Panel

@onready var text_label = $Label
@onready var close_button = $Button

func _ready():
	hide()
	close_button.pressed.connect(_on_close_pressed)

func show_clue_text(text: String):
	text_label.text = text
	show()

func _on_close_pressed():
	hide()
