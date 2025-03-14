extends Node2D

@onready var screen_size = get_viewport_rect().size
@onready var asteroid = preload("res://scenes/asteroid.tscn")

var min_x = -300
var max_x = 1920 + 300
var min_y = -300
var max_y = 1080 + 300
var asteroid_scale = 0.5
var asteroid_color = Color(1,1,1)


func _ready() -> void:
	
	AudioManager.get_node("Music").play_game_scene_music.emit()
	
	#var num_initial_asteroids = randi_range(2,4)
	#for i in range(num_initial_asteroids):
		#var a = Utils.spawn_asteroid(asteroid, asteroid_color, min_x, min_y, max_x, max_y, asteroid_scale)
		#add_child(a)
		

func _process(delta: float) -> void:
	
	var asteroids = []
	var children = get_children()
	for child in children:
		if child is Asteroid or child is SmallAsteroid or child is TinyAsteroid:
			asteroids.append(child)
			
	if asteroids.size() <= 0:
		Events.won.emit()
		get_tree().paused = true
			

func _on_timer_timeout() -> void:
	pass # Replace with function body.
