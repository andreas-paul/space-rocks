extends CharacterBody2D

@onready var screen_size = get_viewport_rect().size
@onready var bullet = preload("res://scenes/bullet.tscn")
@export var timer : Timer
@export var shoot_timer : Timer

var speed : int = 10000
var hitpoints : int = 10
var move_right : bool = true
var is_moving : bool = true
var can_shoot : bool = false
var direction_to_player : Vector2
var player

@onready var particles = preload("res://scenes/mothership_death_explosion.tscn")
@onready var PLAYER_HIT_EFFECT = preload("res://scenes/player_hit_effect.tscn")

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	$Muzzle.look_at(player.global_position)
	$Muzzle.rotation += PI / 2
	var random_offset = randf_range(-0.3,0.3)
	$Muzzle.rotation += random_offset

func _physics_process(delta: float) -> void:
	if is_moving:
		if move_right:
			velocity.x = speed * delta
			move_and_slide()
		else:
			velocity.x = speed * delta * -1
			move_and_slide()

func hit() -> void:
	show_hit_effect()
	hitpoints -= 1
	if hitpoints <= 0:
		destroyed()

func destroyed() -> void:
	show_explosion()
	#await explosion.finished
	Events.score.emit(100)
	queue_free()

func shoot() -> void:

	var b = bullet.instantiate()
	b.transform = $Muzzle.global_transform
	owner.add_child(b)	
	AudioManager.get_node("Sounds").play_ufo_cannon_sound.emit()

func _on_timer_timeout() -> void:
	if global_position.x > screen_size.x:
		move_right = false
	else:
		move_right = true
		
	timer.stop()
	is_moving = true
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	visible = false
	is_moving = false
	can_shoot = false
	timer.wait_time = randi_range(10,15)
	timer.start()
	shoot_timer.stop()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	visible = true
	can_shoot = true
	shoot_timer.start()

func _on_shoot_timer_timeout() -> void:
	shoot()
	
func show_explosion():
	var ontplof = particles.instantiate() as GPUParticles2D
	get_parent().add_child(ontplof)
	ontplof.global_position = global_position
	ontplof.emitting = true
	AudioManager.get_node("Sounds").play_player_death_sound.emit()
	return ontplof
	
func show_hit_effect():
	var hit_effect = PLAYER_HIT_EFFECT.instantiate() as GPUParticles2D
	get_parent().add_child(hit_effect)
	hit_effect.global_position = global_position
	hit_effect.emitting = true
