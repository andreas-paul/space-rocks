extends Node2D

@export var asteroid_explosion : AudioStreamPlayer2D
@export var cannon_sound : AudioStreamPlayer2D
@export var engine_rumble : AudioStreamPlayer2D
@export var ufo_cannon_sound : AudioStreamPlayer2D
@export var player_death_sound : AudioStreamPlayer2D
@export var player_hit_sound : AudioStreamPlayer2D
@export var mothership_death_sound : AudioStreamPlayer2D
@export var rocket_launch_sound : AudioStreamPlayer2D
@export var rocket_explosion_sound : AudioStreamPlayer2D
@export var power_up_pickup_sound : AudioStreamPlayer2D

signal play_asteroid_explosion(pitch: float)
signal play_cannon_sound
signal play_engine_rumble
signal stop_engine_rumble
signal play_ufo_cannon_sound
signal play_player_death_sound
signal play_player_hit_sound
signal play_mothership_death_sound
signal play_rocket_launch_sound
signal play_rocket_explosion_sound
signal play_power_up_pickup_sound

var base_pitches = {}


func _ready() -> void:
	play_asteroid_explosion.connect(on_play_audio_explosion)
	play_cannon_sound.connect(on_play_cannon_sound)
	play_engine_rumble.connect(on_play_engine_rumble)
	stop_engine_rumble.connect(on_stop_engine_rumble)
	play_ufo_cannon_sound.connect(on_play_ufo_cannon_sound)
	play_player_death_sound.connect(on_player_death_sound)
	play_player_hit_sound.connect(on_play_player_hit_sound)
	play_mothership_death_sound.connect(play_with_varied_pitch.bind(mothership_death_sound))
	play_rocket_launch_sound.connect(play_with_varied_pitch.bind(rocket_launch_sound))
	play_rocket_explosion_sound.connect(play_with_varied_pitch.bind(rocket_explosion_sound))
	play_power_up_pickup_sound.connect(play_with_varied_pitch.bind(power_up_pickup_sound))

	# Pitch variation is relative to the pitch set on each player in the scene
	for sound in [asteroid_explosion, cannon_sound, ufo_cannon_sound, player_death_sound, player_hit_sound, mothership_death_sound, rocket_launch_sound, rocket_explosion_sound, power_up_pickup_sound]:
		base_pitches[sound] = sound.pitch_scale

	
func play_with_varied_pitch(sound: AudioStreamPlayer2D, pitch: float = 1.0):
	sound.pitch_scale = base_pitches[sound] * pitch * randf_range(0.92, 1.08)
	sound.play()

func on_play_player_hit_sound():
	play_with_varied_pitch(player_hit_sound)

func on_play_audio_explosion(pitch: float):
	play_with_varied_pitch(asteroid_explosion, pitch)

func on_play_cannon_sound():
	play_with_varied_pitch(cannon_sound)

func on_play_engine_rumble():
	if engine_rumble.playing == false:
		engine_rumble.playing = true
	
func on_stop_engine_rumble():
	if engine_rumble.playing == true:
		engine_rumble.playing = false

func on_play_ufo_cannon_sound():
	play_with_varied_pitch(ufo_cannon_sound)

func on_player_death_sound():
	play_with_varied_pitch(player_death_sound)
