class_name Asteroid extends CharacterBody2D

@export var small_asteroid_scene : PackedScene
@export var particles : PackedScene
@export var power_up_scene : PackedScene = preload("res://scenes/power_up/power_up.tscn")
@export var power_up_chance : float = 0.25

@export var hit_allowed : bool = true
@export var hitpoints : int = 5
@export var speed = 50
@export var max_speed = 50

var angles = [-120, -60, 20, 80, 120, 180]
var mouse_is_entered : bool
var spawn_offset_distance = 1.1
var angular_velocity_value 
var rotation_speed
var mass = 3.0
var knockback_decay = 100
var has_entered_screen : bool = true

@onready var screen_size = get_viewport_rect().size


func _ready() -> void:
	angles.shuffle()
	velocity = global_position.normalized() * -1 * speed
	var ran = randf()
	if ran >= 0.5:
		rotation_speed = -1.0
	else:
		rotation_speed = 1.0
		
		
func _physics_process(delta: float) -> void:
	# Set velocity and rotation
	rotation = rotation + rotation_speed * delta
	
	# Wrap around the screen, wave asteroids start outside it and fly in first
	if has_entered_screen:
		position.x = wrapf(position.x, 0, screen_size.x)
		position.y = wrapf(position.y, 0, screen_size.y)
	else:
		has_entered_screen = Rect2(Vector2.ZERO, screen_size).has_point(position)

	# Handle collisions with other objects
	var collision = move_and_collide(velocity * delta)
	if collision:
		var object = collision.get_collider()
		if object is PlayerShip:
			object.collide_with_asteroid(self)

	# Slow back down to cruising speed after being knocked
	if velocity.length() > max_speed:
		velocity = velocity.move_toward(velocity.normalized() * max_speed, knockback_decay * delta)
		
		
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
	
func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	$VisibleOnScreenNotifier2D.visible = true


func hit():
	if is_queued_for_deletion():
		return

	if hit_allowed:
		hitpoints -= 1
		show_explosion()
		if hitpoints <= 0:
			Events.score.emit(10)
			Utils.show_floating_score(get_parent(), 10, global_position)
			Events.screen_shake.emit(0.5)
			Events.hit_stop.emit(0.04)
			AudioManager.get_node("Sounds").play_asteroid_explosion.emit(1.0)
			var large_asteroid_position = global_position
			
			for i in range(3):
				var small_asteroid = small_asteroid_scene.instantiate() as CharacterBody2D
				get_parent().call_deferred("add_child", small_asteroid)
				var angle = angles[i]  
				var direction = Vector2.RIGHT.rotated(deg_to_rad(angle))
				small_asteroid.global_position = large_asteroid_position + direction * spawn_offset_distance
				small_asteroid.velocity = direction * 200

			if randf() < power_up_chance:
				var power_up = power_up_scene.instantiate()
				power_up.position = large_asteroid_position
				get_parent().call_deferred("add_child", power_up)

			queue_free()
			
		
func show_explosion():
	var ontplof = particles.instantiate() as GPUParticles2D
	get_parent().add_child(ontplof)
	ontplof.global_position = global_position
	ontplof.emitting = true
