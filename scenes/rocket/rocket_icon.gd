extends Control

@export var icon : Texture2D  # Custom art, light colored because it's tinted by the colors below. A placeholder is drawn without it
@export var ready_color : Color = Color(0.3, 1, 0.4)
@export var charging_color : Color = Color(0.4, 0.4, 0.4)

var charge : float = 0.0


func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	charge = player.get_rocket_charge() if player else 0.0
	queue_redraw()


func _draw() -> void:
	var color = ready_color if charge >= 1.0 else charging_color
	var center = size.x / 2
	if icon:
		draw_texture_rect(icon, Rect2(0, 0, size.x, size.y - 14), false, color)
	else:
		# Placeholder until art is set on the icon export
		draw_colored_polygon(PackedVector2Array([Vector2(center, 0), Vector2(center + 16, 24), Vector2(center + 16, 58), Vector2(center - 16, 58), Vector2(center - 16, 24)]), color)
		draw_colored_polygon(PackedVector2Array([Vector2(center - 16, 40), Vector2(center - 28, 62), Vector2(center - 16, 58)]), color)
		draw_colored_polygon(PackedVector2Array([Vector2(center + 16, 40), Vector2(center + 28, 62), Vector2(center + 16, 58)]), color)

	# Fills up while the next rocket charges
	draw_rect(Rect2(0, size.y - 8, size.x, 8), charging_color.darkened(0.5))
	draw_rect(Rect2(0, size.y - 8, size.x * charge, 8), color)
