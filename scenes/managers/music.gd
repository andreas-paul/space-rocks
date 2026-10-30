extends Node2D

@export var main_menu_music : AudioStreamPlayer2D
@export var game_scene_music : AudioStreamPlayer2D

@export var transition_duration = 1.00
@export var transition_type = 1 # TRANS_SINE

signal play_main_menu_music
signal play_game_scene_music


func _ready() -> void:
	play_game_scene_music.connect(on_play_game_scene_music)
	play_main_menu_music.connect(on_play_main_menu_music)
	
func on_play_game_scene_music():
	main_menu_music.playing = false
	game_scene_music.play()
	
func on_play_main_menu_music():
	game_scene_music.playing = false
	main_menu_music.play()
