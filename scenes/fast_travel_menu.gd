extends CanvasLayer

# --- Signals for the Babaylan to listen to ---
signal save_pressed
signal travel_pressed(scene_path, spawn_point_name)
signal closed

# --- Link nodes in the Inspector ---
@onready var highlands_button: Button = $Panel/VBoxContainer/HighlandsButton
@onready var basilica_button: Button = $Panel/VBoxContainer/BasilicaButton
@onready var house_button: Button = $Panel/VBoxContainer/HouseButton
@onready var moalboal_button: Button = $Panel/VBoxContainer/MoalboalButton
@onready var save_button: Button = $Panel/VBoxContainer/SaveButton
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

func _ready():
	# Connect all the buttons to functions *in this script*
	save_button.pressed.connect(_on_save_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	# Connect the travel buttons
	highlands_button.pressed.connect(func(): _on_travel_pressed("res://scenes/Cebu Highlands.tscn", "BabaylanSpawn"))
	house_button.pressed.connect(func(): _on_travel_pressed("res://scenes/Ancestral House.tscn", "BabaylanSpawn"))
	basilica_button.pressed.connect(func(): _on_travel_pressed("res://scenes/Basilica.tscn", "BabaylanSpawn"))
	moalboal_button.pressed.connect(func(): _on_travel_pressed("res://scenes/Moalboal.tscn", "BabaylanSpawn")) #<-- Check this path!
	
	# Start hidden
	hide()

# This is the main function, called by the Babaylan
func show_menu():
	# --- This is your unlock logic ---
	# Check the global flags and disable buttons if conditions aren't met
	
	highlands_button.disabled = not (PortalManager.is_manananggal_dead and PortalManager.is_tikbalang_dead)
	house_button.disabled = not (PortalManager.is_bungisngis_dead and PortalManager.is_black_lady_dead)
	moalboal_button.disabled = not PortalManager.is_kapre_dead
	basilica_button.disabled = not PortalManager.is_bungisngis_dead
	
	# Show the menu
	show()

func _on_save_pressed():
	emit_signal("save_pressed")
	hide() # Close menu after saving

func _on_travel_pressed(scene_path: String, spawn_point_name: String):
	emit_signal("travel_pressed", scene_path, spawn_point_name)
	hide()

func _on_close_pressed():
	emit_signal("closed")
	hide()
