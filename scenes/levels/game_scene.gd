extends Node2D

@onready var screen_size = get_viewport_rect().size
@onready var asteroid = preload("res://scenes/asteroid/asteroid.tscn")
@onready var crosshair_scene = preload("res://scenes/ui_elements/crosshair.tscn")
@onready var game_over_screen_scene = preload("res://scenes/ui_elements/game_over_screen.tscn")
@onready var wave_banner_scene = preload("res://scenes/ui_elements/wave_banner.tscn")
@onready var rocket_icon_scene = preload("res://scenes/rocket/rocket_icon.tscn")
@onready var mothership = $MotherShip

@export var total_waves : int = 5
@export var wave_delay : float = 2.0
@export var extra_asteroids_per_wave : int = 1
@export var extra_speed_per_wave : int = 10
@export var max_shake_offset : float = 10  # Keep below 14, tiny asteroids free themselves when their notifier leaves the screen
@export var shake_decay : float = 2.0

var crosshair : CanvasLayer
var wave_banner : CanvasLayer
var current_wave : int = 1
var is_between_waves : bool = false
var is_game_over : bool = false
var camera : Camera2D
var shake_trauma : float = 0.0


func _ready() -> void:
	
	AudioManager.get_node("Music").play_game_scene_music.emit()

	# Ambient rumble, keeps looping through the pause menu and the end screen
	$BackgroundNoise.stream.loop = true
	$BackgroundNoise.process_mode = Node.PROCESS_MODE_ALWAYS
	$BackgroundNoise.play()

	camera = Camera2D.new()
	camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	add_child(camera)
	# Slightly oversized so shaking doesn't show the edge of the background
	$StarryNightBackground.scale = Vector2.ONE * 1.02
	Events.screen_shake.connect(add_shake)

	$CanvasLayer.add_child(rocket_icon_scene.instantiate())
	crosshair = crosshair_scene.instantiate()
	add_child(crosshair)
	add_child(game_over_screen_scene.instantiate())
	wave_banner = wave_banner_scene.instantiate()
	add_child(wave_banner)
	wave_banner.show_wave(current_wave, total_waves, wave_delay)
	InGameMenu.visibility_changed.connect(on_menu_visibility_changed)
	Events.won.connect(on_game_over)
	Events.lost.connect(on_game_over)
	capture_pointer()


func _process(delta: float) -> void:

	update_shake(delta)

	if is_game_over or is_between_waves:
		return

	var asteroids = []
	var children = get_children()
	for child in children:
		if child is Asteroid or child is SmallAsteroid or child is TinyAsteroid:
			asteroids.append(child)
			
	if asteroids.size() <= 0:
		if current_wave >= total_waves:
			Events.won.emit()
			get_tree().paused = true
		else:
			start_next_wave()


func add_shake(strength: float) -> void:
	shake_trauma = min(shake_trauma + strength, 1.0)


func update_shake(delta: float) -> void:
	shake_trauma = max(shake_trauma - shake_decay * delta, 0.0)
	var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	camera.offset = direction * max_shake_offset * shake_trauma * shake_trauma


func start_next_wave() -> void:
	is_between_waves = true
	current_wave += 1
	wave_banner.show_wave(current_wave, total_waves, wave_delay)

	# Doesn't run while paused, so the delay waits for the pause menu
	await get_tree().create_timer(wave_delay, false).timeout

	# Wave 1 is the 5 asteroids placed in the scene
	var count = 5 + (current_wave - 1) * extra_asteroids_per_wave
	for i in range(count):
		spawn_wave_asteroid()
	if is_instance_valid(mothership):
		mothership.start_pass()
	is_between_waves = false


func spawn_wave_asteroid() -> void:
	var a = Utils.spawn_asteroid(asteroid, Color.WHITE, 1.0)
	a.speed += (current_wave - 1) * extra_speed_per_wave
	a.max_speed = a.speed
	add_child(a)
	Utils.launch_asteroid(a)


			

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	InGameMenu.can_open = true


func on_game_over() -> void:
	is_game_over = true
	camera.offset = Vector2.ZERO
	# The pause menu would open underneath the game over screen
	InGameMenu.can_open = false
	release_pointer()


func capture_pointer() -> void:
	# Keeps the pointer position usable for aiming, MOUSE_MODE_CAPTURED would freeze it
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	crosshair.show()


func release_pointer() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	crosshair.hide()


func on_menu_visibility_changed() -> void:
	if InGameMenu.visible:
		release_pointer()
	else:
		capture_pointer()


func _on_timer_timeout() -> void:
	pass # Replace with function body.
