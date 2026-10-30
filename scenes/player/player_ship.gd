class_name PlayerShip extends CharacterBody2D

@export var acceleration: float = 400  # Forward thrust impulse
@export var reverse_acceleration: float = 50
@export var rotation_damping: float = 6.0  # How quickly the ship settles on the pointer, lower is heavier
@export var min_aim_distance: float = 10  # Stops the ship spinning when the pointer is on top of it
@export var damping_factor: float = 0.9999  # Gradual slow down
@export var stop_damping: float = 0.9
@export var max_speed: float = 400
@export var hitpoints: int = 100
@export var damage_taken : int = 10
@export var ship_mass: float = 1.0
@export var min_bounce_speed: float = 200  # Separation speed of a collision, however gentle
@export var bounciness: float = 0.8  # Share of the collision speed kept after a bounce
@export var fire_cooldown: float = 0.12
@export var rocket_cooldown: float = 5.0
@export var invulnerability_time: float = 1.0
@export var blink_interval: float = 0.1
@export var intro_duration: float = 2.0
@export var intro_start_distance: float = 150  # How far below the screen the ship starts

var can_shoot = true
var is_dead = false
var is_invulnerable = false
var is_in_intro = false
var rocket_cooldown_left : float = 0.0

@onready var screen_size = get_viewport_rect().size
@onready var max_hitpoints = hitpoints
@onready var bullet = preload("res://scenes/bullet/bullet.tscn")
@onready var rocket = preload("res://scenes/rocket/rocket.tscn")
@onready var particles = preload("res://scenes/vfx/player_death_explosion.tscn")
@onready var PLAYER_HIT_EFFECT = preload("res://scenes/vfx/player_hit_effect.tscn")

func _ready() -> void:
	rocket_cooldown_left = rocket_cooldown
	$LeftEngineExhaust.lifetime = 0.02
	$RightEngineExhaust.lifetime = 0.02
	stop_engine_rumble()
	play_intro()

func _exit_tree() -> void:
	stop_engine_rumble()

# Flies in from below the screen to where the ship is placed in the scene, with
# the controls locked and nothing able to touch it
func play_intro():
	is_in_intro = true
	var target_position = position
	var layer = collision_layer
	var mask = collision_mask
	collision_layer = 0
	collision_mask = 0
	position = Vector2(target_position.x, screen_size.y + intro_start_distance)
	rotation = 0
	$LeftEngineExhaust.lifetime = 0.05
	$RightEngineExhaust.lifetime = 0.05
	play_engine_rumble()

	var tween = create_tween()
	tween.tween_property(self, "position", target_position, intro_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

	is_in_intro = false
	collision_layer = layer
	collision_mask = mask
	$LeftEngineExhaust.lifetime = 0.02
	$RightEngineExhaust.lifetime = 0.02
	stop_engine_rumble()

	# A moment of safety in case an asteroid is passing through the middle
	is_invulnerable = true
	play_blink(create_tween())
	await get_tree().create_timer(invulnerability_time).timeout
	is_invulnerable = false

func _input(event: InputEvent) -> void:
	if is_dead or is_in_intro:
		return

	if Input.is_action_just_pressed("fire"):
		fire_rocket()

	if Input.is_action_just_released("move_forward"):
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

	if is_in_intro:
		return

	rocket_cooldown_left = max(rocket_cooldown_left - delta, 0.0)

	# Turn towards the mouse pointer, the ship's nose points along Vector2.UP
	var to_pointer = get_global_mouse_position() - global_position
	if not is_dead and to_pointer.length() > min_aim_distance:
		rotation = lerp_angle(rotation, to_pointer.angle() + PI / 2, 1.0 - exp(-rotation_damping * delta))

	# Set exhaust particle system to low power if max_speed reached
	if velocity.length() == max_speed:
		$LeftEngineExhaust.lifetime = 0.02
		$RightEngineExhaust.lifetime = 0.02	
		stop_engine_rumble()
		
func _physics_process(delta):

	if is_in_intro:
		return

	if not is_dead:
		# Keeps firing while held, shoot() limits the rate
		if Input.is_action_pressed("left_click"):
			shoot()

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
	
	# move_and_slide removes the velocity going into a collision, the bounce needs it
	var velocity_before_slide = velocity
	move_and_slide()

	if get_slide_collision_count() > 0:
		velocity = velocity_before_slide
		for i in get_slide_collision_count():
			collide_with_asteroid(get_slide_collision(i).get_collider())


# Pushes the ship and the asteroid apart, sharing the push by mass. Called from
# both sides because either one can be the one that moved into the other.
func collide_with_asteroid(asteroid):
	var normal = (global_position - asteroid.global_position).normalized()
	var separating_speed = (velocity - asteroid.velocity).dot(normal)

	# Already moving apart from an earlier bounce
	if separating_speed >= min_bounce_speed * 0.5:
		return

	var target_speed = max(-separating_speed * bounciness, min_bounce_speed)
	var impulse = target_speed - separating_speed
	var total_mass = ship_mass + asteroid.mass
	velocity += normal * impulse * asteroid.mass / total_mass
	asteroid.velocity -= normal * impulse * ship_mass / total_mass

	hit()
	# Large asteroids aren't damaged by ramming
	if not asteroid is Asteroid:
		asteroid.hit()


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
		# The muzzles touch the hull, so bullets must ignore the player layer
		b.set_collision_mask_value(1, false)
		c.set_collision_mask_value(1, false)
		owner.add_child(b)
		owner.add_child(c)
		
		AudioManager.get_node("Sounds").play_cannon_sound.emit()

		can_shoot = false
		await get_tree().create_timer(fire_cooldown).timeout
		if not is_dead:
			can_shoot = true


func fire_rocket():
	if rocket_cooldown_left > 0.0:
		return

	rocket_cooldown_left = rocket_cooldown
	var r = rocket.instantiate()
	r.rotation = rotation
	r.position = global_position + Vector2.UP.rotated(rotation) * 60
	owner.add_child(r)
	AudioManager.get_node("Sounds").play_rocket_launch_sound.emit()


# 0 just after firing, 1 when the next rocket is ready
func get_rocket_charge() -> float:
	return 1.0 - rocket_cooldown_left / rocket_cooldown


func hit():
	if is_dead or is_invulnerable:
		return

	show_hit_effect()
	hitpoints = max(hitpoints - damage_taken, 0)
	Events.player_health_changed.emit(hitpoints)
	Events.screen_shake.emit(0.6)
	Events.hit_stop.emit(0.05)
	play_hit_flash()
	AudioManager.get_node("Sounds").play_player_hit_sound.emit()

	if hitpoints > 0:
		is_invulnerable = true
		await get_tree().create_timer(invulnerability_time).timeout
		is_invulnerable = false
	else:
		is_dead = true
		can_shoot = false
		stop_engine_rumble()
		$AnimationPlayer.play("death")
		await $AnimationPlayer.animation_finished
		hide()
		var explosion = show_explosion()
		Events.screen_shake.emit(1.0)
		Events.hit_stop.emit(0.12)
		await explosion.finished
		get_tree().paused = true
		Events.lost.emit()
		queue_free()

# A red flash, then blinking for as long as the ship can't be hit
func play_hit_flash():
	$Sprite2D.modulate = Color(2.5, 0.6, 0.6)
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1)

	if hitpoints > 0:
		play_blink(tween)

func play_blink(tween: Tween):
	var blinks = int((invulnerability_time - 0.1) / (blink_interval * 2))
	for i in range(blinks):
		tween.tween_property($Sprite2D, "modulate:a", 0.3, blink_interval)
		tween.tween_property($Sprite2D, "modulate:a", 1.0, blink_interval)

func heal():
	hitpoints = min(hitpoints + 50, max_hitpoints)
	Events.player_health_changed.emit(hitpoints)

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
