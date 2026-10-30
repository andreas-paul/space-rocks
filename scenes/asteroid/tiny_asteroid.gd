class_name TinyAsteroid extends CharacterBody2D

var hitpoints = 1
var rotation_speed 
var speed = 100
var mass = 0.5

@export var particles : PackedScene
@onready var screen_size = get_viewport_rect().size


func _ready() -> void:
	var ran = randf()
	if ran >= 0.5:
		rotation_speed = -3.0
	else:
		rotation_speed = 3.0
	
	
func _physics_process(delta: float) -> void:
	
	# Set velocity and rotation
	rotation = rotation + rotation_speed * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is PlayerShip:
			collider.collide_with_asteroid(self)
	
	# Wrap screen
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
	
	
func hit():
	if is_queued_for_deletion():
		return

	hitpoints -= 1
	show_explosion()
	if hitpoints <= 0:
		Events.score.emit(30)
		Utils.show_floating_score(get_parent(), 30, global_position)
		Events.screen_shake.emit(0.15)
		AudioManager.get_node("Sounds").play_asteroid_explosion.emit(1.6)
		queue_free()
	
		
func show_explosion():
	var ontplof = particles.instantiate() as GPUParticles2D
	get_parent().add_child(ontplof)
	ontplof.global_position = global_position
	ontplof.emitting = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
