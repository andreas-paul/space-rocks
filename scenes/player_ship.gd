class_name PlayerShip extends CharacterBody2D

@export var acceleration: float = 400  # Forward thrust impulse
@export var reverse_acceleration: float = 50
@export var rotation_speed: float = 3.0  # Rotation speed in radians per second
@export var damping_factor: float = 0.9999  # Gradual slow down
@export var stop_damping: float = 0.9
@export var max_speed: float = 400
@export var hitpoints: int = 100
@export var damage_taken : int = 10

var can_shoot = true

@onready var screen_size = get_viewport_rect().size
@onready var bullet = preload("res://scenes/bullet.tscn")
@onready var particles = preload("res://scenes/player_death_explosion.tscn")
@onready var PLAYER_HIT_EFFECT = preload("res://scenes/player_hit_effect.tscn")

func _ready() -> void:
	$LeftEngineExhaust.lifetime = 0.02
	$RightEngineExhaust.lifetime = 0.02
	stop_engine_rumble()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_released("fire"):
		shoot()
		
	if Input.is_action_just_released("move_forward"):
		$LeftEngineExhaust.lifetime = 0.02
		$RightEngineExhaust.lifetime = 0.02
		stop_engine_rumble()
		
	if Input.is_action_just_released("turn_right"):
		$LeftEngineExhaust.lifetime = 0.02
		$RightEngineExhaust.lifetime = 0.02
		stop_engine_rumble()
		
	if Input.is_action_just_released("turn_left"):
		$LeftEngineExhaust.lifetime = 0.02
		$RightEngineExhaust.lifetime = 0.02
		stop_engine_rumble()
		
	if Input.is_action_pressed("move_forward"):
		$LeftEngineExhaust.lifetime = 0.05
		$RightEngineExhaust.lifetime = 0.05
		play_engine_rumble()
		
	if Input.is_action_just_pressed("move_forward"):
		$LeftEngineExhaust.lifetime = 0.05
		$RightEngineExhaust.lifetime = 0.05
		play_engine_rumble()

func _process(delta: float) -> void:
	
	# Rotate left (no inertia)
	if Input.is_action_pressed("turn_left"):
		rotation = rotation + rotation_speed * -1 * delta
		$LeftEngineExhaust.lifetime = 0.02
		$RightEngineExhaust.lifetime = 0.05
		play_engine_rumble()

	# Rotate right (no inertia)
	elif Input.is_action_pressed("turn_right"):
		rotation = rotation + rotation_speed * delta
		$LeftEngineExhaust.lifetime = 0.05
		$RightEngineExhaust.lifetime = 0.02
		play_engine_rumble()
	
	# Set exhaust particle system to low power if max_speed reached
	if velocity.length() == max_speed:
		$LeftEngineExhaust.lifetime = 0.02
		$RightEngineExhaust.lifetime = 0.02	
		stop_engine_rumble()
		
func _physics_process(delta):
	
	# Accelerate
	if Input.is_action_pressed("move_forward"):
		velocity += Vector2.UP.rotated(rotation) * acceleration * delta
	
	# Slowly deccelerate
	if Input.is_action_pressed("move_stop"):
		if velocity.length() > 50:
			velocity = velocity * 0.9
		else:
			velocity -= Vector2.UP.rotated(rotation) * reverse_acceleration * delta
	
	if velocity.length() >= max_speed:
		velocity = velocity.normalized() * max_speed
		
	# Wrap around screen
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
	
	move_and_slide()
	
	
func play_engine_rumble():
	AudioManager.get_node("Sounds").play_engine_rumble.emit()

func stop_engine_rumble():
	AudioManager.get_node("Sounds").stop_engine_rumble.emit()
	

func shoot():
	if can_shoot:

		var b = bullet.instantiate()
		b.transform = $LeftMuzzle.global_transform
		var c = bullet.instantiate()
		c.transform = $RightMuzzle.global_transform
		owner.add_child(b)
		owner.add_child(c)
		
		AudioManager.get_node("Sounds").play_cannon_sound.emit()
	
	
func hit():
	show_hit_effect()
	hitpoints -= damage_taken
	Events.reduce_player_health.emit()
	
	if hitpoints <= 0:
		can_shoot = false
		$AnimationPlayer.play("death")
		await $AnimationPlayer.animation_finished
		hide()
		var explosion = show_explosion()
		await explosion.finished
		get_tree().paused = true
		Events.lost.emit()
		queue_free()


func show_explosion():
	var ontplof = particles.instantiate() as GPUParticles2D
	get_parent().add_child(ontplof)
	ontplof.global_position = global_position
	ontplof.emitting = true
	return ontplof
	
func show_hit_effect():
	var hit_effect = PLAYER_HIT_EFFECT.instantiate() as GPUParticles2D
	get_parent().add_child(hit_effect)
	hit_effect.global_position = global_position
	hit_effect.emitting = true
