extends Node

const SPAWN_MARGIN = 120  # Far enough outside the screen to hide a whole large asteroid

var fake_glow_texture : GradientTexture2D
var additive_material : CanvasItemMaterial
var uses_fake_glow : bool = false


func _ready() -> void:
	additive_material = CanvasItemMaterial.new()
	additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	var gradient = Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1, 1, 1, 0))
	fake_glow_texture = GradientTexture2D.new()
	fake_glow_texture.gradient = gradient
	fake_glow_texture.fill = GradientTexture2D.FILL_RADIAL
	fake_glow_texture.fill_from = Vector2(0.5, 0.5)
	fake_glow_texture.fill_to = Vector2(1.0, 0.5)

	# The web build runs on Compatibility, which ignores viewport/hdr_2d, so colors
	# above 1 don't glow there. Additive blending stands in for it.
	uses_fake_glow = RenderingServer.get_current_rendering_method() == "gl_compatibility"
	if uses_fake_glow:
		get_tree().node_added.connect(on_node_added)


func on_node_added(node: Node):
	if node is GPUParticles2D and node.material == null:
		node.material = additive_material


# Does nothing on Forward+ unless always is set, the WorldEnvironment glow handles it there
func add_fake_glow(parent: Node2D, color: Color, size: float, always: bool = false):
	if not uses_fake_glow and not always:
		return

	var glow = Sprite2D.new()
	glow.texture = fake_glow_texture
	glow.material = additive_material
	glow.modulate = color
	glow.scale = Vector2.ONE * size / fake_glow_texture.width
	glow.show_behind_parent = true
	parent.add_child(glow)


func show_floating_score(parent: Node, value: int, pos: Vector2):
	show_floating_text(parent, "+%d" % value, pos)


func show_floating_text(parent: Node, text: String, pos: Vector2):
	var label = Label.new()
	label.text = text
	label.z_index = 50
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 32)
	parent.add_child(label)
	label.position = pos - Vector2(30, 20)

	var tween = label.create_tween()
	tween.set_parallel()
	tween.tween_property(label, "position:y", label.position.y - 60, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)


# Creates an asteroid outside the screen. Call launch_asteroid after adding it to the scene.
func spawn_asteroid(asteroid: PackedScene, asteroid_color, asteroid_scale):
	var a = asteroid.instantiate() as Asteroid
	a.global_position = random_offscreen_position()
	a.has_entered_screen = false
	a.modulate = asteroid_color
	a.hit_allowed = true
	a.scale = Vector2.ONE * asteroid_scale
	return a


# Aims at the middle of the screen so the asteroid always flies in, Asteroid._ready only heads for the top left
func launch_asteroid(a: Asteroid):
	var screen_size = get_viewport().get_visible_rect().size
	var target = Vector2(randf_range(0.25, 0.75) * screen_size.x, randf_range(0.25, 0.75) * screen_size.y)
	a.velocity = (target - a.global_position).normalized() * a.speed


func random_offscreen_position() -> Vector2:
	var screen_size = get_viewport().get_visible_rect().size
	if randf() < 0.5:
		return Vector2([-SPAWN_MARGIN, screen_size.x + SPAWN_MARGIN].pick_random(), randf_range(0, screen_size.y))
	return Vector2(randf_range(0, screen_size.x), [-SPAWN_MARGIN, screen_size.y + SPAWN_MARGIN].pick_random())
