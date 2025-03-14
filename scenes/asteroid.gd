class_name Asteroid extends CharacterBody2D

@export var small_asteroid_scene : PackedScene
@export var particles : PackedScene

@export var hit_allowed : bool = true
@export var hitpoints : int = 5
@export var speed = 50
@export var max_speed = 50

var angles = [-120, -60, 20, 80, 120, 180]
var mouse_is_entered : bool
var spawn_offset_distance = 1.1
var angular_velocity_value 
var rotation_speed
var bounce_strength = 10000

@onready var screen_size = get_viewport_rect().size


func _ready() -> void:
	angles.shuffle()
	velocity = global_position.normalized() * -1 * speed
	var ran = randf()
	if ran >= 0.0:
		rotation_speed = -1.0
	else:
		rotation_speed = 1.0
		
		
func _physics_process(delta: float) -> void:
	# Set velocity and rotation
	rotation = rotation + rotation_speed * delta
	
	# Wrap around the screen
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
	
	# Handle collisions with other objects
	var collision = move_and_collide(velocity * delta)
	if collision:
		var object = collision.get_collider()
		if object is PlayerShip:
			object.hit()
			object.velocity = velocity.bounce(collision.get_normal()) * bounce_strength
			
		velocity = velocity.bounce(collision.get_normal()) * bounce_strength
		
	# Limit velocity
	if velocity.length() >= max_speed:
		velocity = velocity.normalized() * speed
		
		
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
	
func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	$VisibleOnScreenNotifier2D.visible = true


func hit():
	if hit_allowed:
		hitpoints -= 1
		show_explosion()
		if hitpoints <= 0:
			Events.score.emit()
			AudioManager.get_node("Sounds").play_asteroid_explosion.emit()
			var large_asteroid_position = global_position
			hide()
			
			for i in range(3):
				var small_asteroid = small_asteroid_scene.instantiate() as CharacterBody2D
				get_parent().call_deferred("add_child", small_asteroid)
				var angle = angles[i]  
				var direction = Vector2.RIGHT.rotated(angle) 
				small_asteroid.global_position = large_asteroid_position + direction * spawn_offset_distance
				small_asteroid.velocity = direction * 200  
			
		
func show_explosion():
	var ontplof = particles.instantiate() as GPUParticles2D
	get_parent().add_child(ontplof)
	ontplof.global_position = global_position
	ontplof.emitting = true
