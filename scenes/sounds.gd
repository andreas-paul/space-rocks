extends Node2D

@export var asteroid_explosion : AudioStreamPlayer2D
@export var cannon_sound : AudioStreamPlayer2D
@export var engine_rumble : AudioStreamPlayer2D
@export var ufo_cannon_sound : AudioStreamPlayer2D

signal play_asteroid_explosion
signal play_cannon_sound
signal play_engine_rumble
signal stop_engine_rumble
signal play_ufo_cannon_sound


func _ready() -> void:
	play_asteroid_explosion.connect(on_play_audio_explosion)
	play_cannon_sound.connect(on_play_cannon_sound)
	play_engine_rumble.connect(on_play_engine_rumble)
	stop_engine_rumble.connect(on_stop_engine_rumble)
	play_ufo_cannon_sound.connect(on_play_ufo_cannon_sound)

	
func on_play_audio_explosion():
	asteroid_explosion.play()

func on_play_cannon_sound():
	cannon_sound.play()

func on_play_engine_rumble():
	if engine_rumble.playing == false:
		engine_rumble.playing = true
	
func on_stop_engine_rumble():
	if engine_rumble.playing == true:
		engine_rumble.playing = false

func on_play_ufo_cannon_sound():
	ufo_cannon_sound.play()
