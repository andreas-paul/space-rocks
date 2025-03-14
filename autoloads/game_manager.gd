extends Node

@onready var game_scene = preload("res://scenes/game_scene.tscn")
@onready var main_menu = preload("res://scenes/main_menu.tscn")

func _ready() -> void:
	Events.new_game.connect(on_new_game)
	Events.quit.connect(on_quit)
	Events.restart.connect(on_restart)
	Events.open_main_menu.connect(on_open_main_menu)
	Events.toggle_fullscreen.connect(on_toggle_fullscreen)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("toggle_fullscreen"):
		Events.toggle_fullscreen.emit()
	
func on_new_game():
	get_tree().change_scene_to_packed(game_scene)
	
func on_quit():
	get_tree().quit()

func on_restart():
	get_tree().change_scene_to_packed(game_scene)

func on_open_main_menu():
	get_tree().change_scene_to_packed(main_menu)
	
func on_toggle_fullscreen():
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
