class_name SmallAsteroid extends CharacterBody2D

var hitpoints = 3
var rotation_speed
var speed = 50
var mass = 1.0
var angles = [-120, -60, 20, 80, 120, 180]
var spawn_offset_distance = 1

@export var tiny_asteroid_scene : PackedScene
@export var particles : PackedScene

@onready var screen_size = get_viewport_rect().size

func _ready() -> void:
	
	angles.shuffle()

	var ran = randf()
	if ran >= 0.5:
		rotation_speed = -2.0
	else:
		rotation_speed = 2.0
		
func _physics_process(delta: float) -> void:
	
	# Set velocity and rotation
	rotation = rotation + rotation_speed * delta
	
	# Wrap screen
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
	
	# Handle collisions with other objects
	var collision = move_and_collide(velocity * delta)
	if collision:
		var object = collision.get_collider()
		if object is PlayerShip:
			object.collide_with_asteroid(self)

func hit():
	if is_queued_for_deletion():
		return

	hitpoints -= 1
	show_explosion()
	if hitpoints <= 0:
		Events.score.emit(20)
		Utils.show_floating_score(get_parent(), 20, global_position)
		Events.screen_shake.emit(0.3)
		AudioManager.get_node("Sounds").play_asteroid_explosion.emit(1.3)
		var small_asteroid_position = global_position
		for i in range(2):
			var tiny_asteroid = tiny_asteroid_scene.instantiate() as CharacterBody2D
			get_parent().call_deferred("add_child", tiny_asteroid)
			var angle = angles[i]  
			var direction = Vector2.RIGHT.rotated(deg_to_rad(angle))
			tiny_asteroid.global_position = small_asteroid_position + direction * spawn_offset_distance
			tiny_asteroid.velocity = direction * 200

		queue_free()
	
			
func show_explosion():
	var ontplof = particles.instantiate() as GPUParticles2D
	get_parent().add_child(ontplof)
	ontplof.global_position = global_position
	ontplof.emitting = true		


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
