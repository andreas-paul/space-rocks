extends Node2D

@export var lifetime : float = 15.0
@export var speed : float = 80
@export var blink_interval : float = 0.35

var velocity : Vector2

@onready var screen_size = get_viewport_rect().size


func _ready() -> void:
	velocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * speed
	$Area2D.body_entered.connect(on_body_entered)
	# A halo on every renderer, so it stands out against the dark background
	Utils.add_fake_glow(self, Color(0.4, 1, 0.5, 0.45), 120, true)

	var blink_tween = create_tween().set_loops()
	blink_tween.tween_property(self, "modulate:a", 0.25, blink_interval)
	blink_tween.tween_property(self, "modulate:a", 1.0, blink_interval)

	await get_tree().create_timer(lifetime, false).timeout
	blink_tween.kill()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)


func _physics_process(delta: float) -> void:
	position += velocity * delta
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)


func on_body_entered(body: Node2D) -> void:
	# Stays around for later if the ship is already at full health
	if body is PlayerShip and not body.is_dead and body.hitpoints < body.max_hitpoints:
		body.heal()
		Utils.show_floating_text(get_parent(), "+50 HP", global_position)
		AudioManager.get_node("Sounds").play_power_up_pickup_sound.emit()
		queue_free()
