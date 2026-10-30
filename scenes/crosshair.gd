extends Node2D

@export var texture : Texture2D  # Custom art, drawn centered on the pointer. Lines are drawn without it
@export var color : Color = Color(1, 1, 1, 0.9)
@export var radius : float = 12
@export var line_length : float = 8
@export var line_width : float = 2


func _process(delta: float) -> void:
	global_position = get_global_mouse_position()


func _draw() -> void:
	if texture:
		draw_texture(texture, -texture.get_size() / 2)
	else:
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, color, line_width)
		for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
			draw_line(direction * (radius - line_length / 2), direction * (radius + line_length), color, line_width)
