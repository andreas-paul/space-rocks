extends Area2D

@export var texture : Texture2D  # Custom art, pointing up. A placeholder is drawn without it
@export var speed : float = 700
@export var lifetime : float = 1.0  # Explodes by itself after this long
@export var aoe_radius : float = 350
@export var damage : int = 5  # Destroys a large asteroid, a quarter of the mothership

var has_exploded : bool = false
var ring_radius : float = 0.0

@onready var screen_size = get_viewport_rect().size
@onready var explosion_scene = preload("res://scenes/vfx/mothership_death_explosion.tscn")


func _ready() -> void:
	z_index = 40
	Utils.add_fake_glow(self, Color(1, 0.6, 0.2, 0.8), 60)
	get_tree().create_timer(lifetime, false).timeout.connect(explode)


func _physics_process(delta: float) -> void:
	if has_exploded:
		return

	position -= transform.y * speed * delta
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)


func _on_body_entered(body: Node2D) -> void:
	explode()


func explode() -> void:
	if has_exploded:
		return

	has_exploded = true
	set_deferred("monitoring", false)
	damage_targets_in_range()
	show_explosion()

	Events.screen_shake.emit(1.0)
	Events.hit_stop.emit(0.08)
	AudioManager.get_node("Sounds").play_rocket_explosion_sound.emit()


func damage_targets_in_range() -> void:
	var targets = get_tree().get_nodes_in_group("Asteroids") + get_tree().get_nodes_in_group("Mothership")
	for target in targets:
		# A mothership waiting for its next pass is hidden, and the Asteroids group also holds a Timer
		if not target.has_method("hit") or not target.visible:
			continue
		if target.global_position.distance_to(global_position) > aoe_radius:
			continue
		for i in range(damage):
			if target.is_queued_for_deletion():
				break
			target.hit()


func show_explosion() -> void:
	var particles = explosion_scene.instantiate() as GPUParticles2D
	get_parent().add_child(particles)
	particles.global_position = global_position
	particles.scale *= 3
	particles.emitting = true
	particles.finished.connect(particles.queue_free)

	# An expanding ring that shows how far the blast reaches
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_method(set_ring_radius, 0.0, aoe_radius, 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)


func set_ring_radius(value: float) -> void:
	ring_radius = value
	queue_redraw()


func _draw() -> void:
	if has_exploded:
		draw_arc(Vector2.ZERO, ring_radius, 0, TAU, 64, Color(1, 0.7, 0.3), 6)
	elif texture:
		draw_texture(texture, -texture.get_size() / 2)
	else:
		# Placeholder until art is set on the texture export
		draw_colored_polygon(PackedVector2Array([Vector2(0, -22), Vector2(8, 10), Vector2(-8, 10)]), Color(0.9, 0.9, 0.9))
		draw_colored_polygon(PackedVector2Array([Vector2(5, 10), Vector2(0, 26), Vector2(-5, 10)]), Color(1, 0.6, 0.2))
