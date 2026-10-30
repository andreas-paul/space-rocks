extends Node

@onready var game_scene = preload("res://scenes/levels/game_scene.tscn")
@onready var main_menu = preload("res://scenes/ui_elements/main_menu.tscn")

@export var fade_duration : float = 0.25

var fade_rect : ColorRect
var is_transitioning : bool = false
var is_hit_stopped : bool = false

func _ready() -> void:
	create_fade_rect()
	Events.hit_stop.connect(on_hit_stop)
	Events.new_game.connect(on_new_game)
	Events.quit.connect(on_quit)
	Events.restart.connect(on_restart)
	Events.open_main_menu.connect(on_open_main_menu)
	Events.toggle_fullscreen.connect(on_toggle_fullscreen)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("toggle_fullscreen"):
		Events.toggle_fullscreen.emit()
	
func on_new_game():
	fade_to_scene(game_scene)

func on_quit():
	get_tree().quit()

func on_restart():
	fade_to_scene(game_scene)

func on_open_main_menu():
	fade_to_scene(main_menu)

func create_fade_rect():
	var layer = CanvasLayer.new()
	layer.layer = 128
	add_child(layer)
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(fade_rect)

func fade_to_scene(scene: PackedScene):
	if is_transitioning:
		return
	is_transitioning = true
	await fade(1.0)
	# The game keeps running during the fade, so it could have paused itself by now
	get_tree().paused = false
	get_tree().change_scene_to_packed(scene)
	await fade(0.0)
	is_transitioning = false

func fade(alpha: float):
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "color:a", alpha, fade_duration)
	await tween.finished

func on_hit_stop(duration: float):
	if is_hit_stopped:
		return
	is_hit_stopped = true
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
	is_hit_stopped = false

func on_toggle_fullscreen():
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
