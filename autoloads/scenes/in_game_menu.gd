extends Control


func _input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_cancel"):
		if visible:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true
 
func _on_restart_button_pressed() -> void:
	hide()
	get_tree().paused = false
	Events.restart.emit()

func _on_main_menu_button_pressed() -> void:
	hide()
	get_tree().paused = false
	Events.open_main_menu.emit()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	Events.options.emit()
