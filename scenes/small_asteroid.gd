class_name SmallAsteroid extends CharacterBody2D

var hitpoints = 3
var rotation_speed
var speed = 50
var max_speed = 50
var angles = [-120, -60, 20, 80, 120, 180]
var spawn_offset_distance = 1
var bounce_strength = 50

@export var tiny_asteroid_scene : PackedScene
@export var particles : PackedScene

@onready var screen_size = get_viewport_rect().size

func _ready() -> void:
	
	angles.shuffle()

	var ran = randf()
	if ran >= 0.0:
		rotation_speed = -1.0
	else:
		rotation_speed = 1.0
		
func _physics_process(delta: float) -> void:
	
	# Set velocity and rotation
	rotation = rotation + rotation_speed * delta
	move_and_collide(velocity * delta)
	
	# Wrap screen
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
	
	# Handle collisions with other objects
	var collision = move_and_collide(velocity * delta)
	if collision:
		var object = collision.get_collider()
		if object is PlayerShip:
			hit()
			object.hit()
						
		velocity = velocity.bounce(collision.get_normal()) * bounce_strength
		
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed

func hit():
	hitpoints -= 1
	show_explosion()
	if hitpoints <= 0:
		Events.score.emit()
		var small_asteroid_position = global_position
		hide()
		for i in range(2):
			var tiny_asteroid = tiny_asteroid_scene.instantiate() as CharacterBody2D
			get_parent().call_deferred("add_child", tiny_asteroid)
			var angle = angles[i]  
			var direction = Vector2.RIGHT.rotated(angle) 
			tiny_asteroid.global_position = small_asteroid_position + direction * spawn_offset_distance
			tiny_asteroid.velocity = direction * 200  
	
			
func show_explosion():
	var ontplof = particles.instantiate() as GPUParticles2D
	get_parent().add_child(ontplof)
	ontplof.global_position = global_position
	ontplof.emitting = true		


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
