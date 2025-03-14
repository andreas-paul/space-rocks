extends Node2D

@onready var asteroid = preload("res://scenes/asteroid.tscn")
@onready var game_scene = preload("res://scenes/game_scene.tscn")
@onready var screen_size = get_viewport_rect().size

var min_x = -300
var max_x = 1920 + 300
var min_y = -300
var max_y = 1080 + 300
var asteroid_color = Color(0.277, 0.279, 0.267)
var asteroid_scale = 1.0

signal new_game
signal quit


func _ready() -> void:
	
	AudioManager.get_node("Music").play_main_menu_music.emit()
	
	var a = Utils.spawn_asteroid(asteroid, asteroid_color, min_x, min_y, max_x, max_y, asteroid_scale)
	add_child(a)
	
	$Timer.wait_time = randi_range(1, 10)
	$Timer.start()
	
	
func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_released("space"):
		Events.new_game.emit()
		
	if Input.is_action_just_released("ui_cancel"):
		Events.quit.emit()
		
		
func _on_timer_timeout() -> void:
	var children = get_children()
	for child in children:
		if (child is Asteroid) or (child is SmallAsteroid):
			return
			
	var a = Utils.spawn_asteroid(asteroid, asteroid_color, min_x, min_y, max_x, max_y, asteroid_scale)
	add_child(a)
	$Timer.wait_time = randi_range(1, 10)
