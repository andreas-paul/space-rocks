extends MarginContainer


func _on_quit_button_pressed() -> void:
	Events.quit.emit()
