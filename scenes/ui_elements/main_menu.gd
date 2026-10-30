extends Node2D

@onready var asteroid = preload("res://scenes/asteroid/asteroid.tscn")
@onready var game_scene = preload("res://scenes/levels/game_scene.tscn")
@onready var screen_size = get_viewport_rect().size

var asteroid_color = Color(0.277, 0.279, 0.267)
var asteroid_scale = 1.0

signal new_game
signal quit


func _ready() -> void:
	
	AudioManager.get_node("Music").play_main_menu_music.emit()
	
	spawn_background_asteroid()

	$Timer.wait_time = randi_range(1, 10)
	$Timer.start()
	
	
func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_released("fire"):
		Events.new_game.emit()
		
	if Input.is_action_just_released("ui_cancel"):
		Events.quit.emit()
		
		
func _on_timer_timeout() -> void:
	var children = get_children()
	for child in children:
		if (child is Asteroid) or (child is SmallAsteroid):
			return
			
	spawn_background_asteroid()
	$Timer.wait_time = randi_range(1, 10)


func spawn_background_asteroid() -> void:
	var a = Utils.spawn_asteroid(asteroid, asteroid_color, asteroid_scale)
	add_child(a)
	Utils.launch_asteroid(a)
