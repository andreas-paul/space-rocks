class_name TinyAsteroid extends CharacterBody2D

var hitpoints = 1
var rotation_speed 
var speed = 100

@export var particles : PackedScene
@onready var screen_size = get_viewport_rect().size


func _ready() -> void:
	velocity = global_position.normalized() * -1 * 200
	var ran = randf()
	if ran >= 0.0:
		rotation_speed = -1.0
	else:
		rotation_speed = 1.0
	
	
func _physics_process(delta: float) -> void:
	
	# Set velocity and rotation
	rotation = rotation + rotation_speed * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is PlayerShip:
			collider.hit()
			hit()
	
	# Wrap screen
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
	
	
func hit():
	hitpoints -= 1
	show_explosion()
	if hitpoints <= 0:
		Events.score.emit()
		queue_free()
	
		
func show_explosion():
	var ontplof = particles.instantiate() as GPUParticles2D
	get_parent().add_child(ontplof)
	ontplof.global_position = global_position
	ontplof.emitting = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
