extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _input(event: InputEvent) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("screenshot"):
		var img = get_viewport().get_texture().get_image()
		var img_save_path = "user://screenshots/screenshot_%s.png" % [datetime_string()]
		img.save_png(img_save_path)


func datetime_string() -> String:
	return str(Time.get_unix_time_from_system() * 1000)
