extends CanvasLayer

@export var rows : GridContainer
@export var empty_label : Label


func _input(event: InputEvent) -> void:
	# Runs before the main menu and InGameMenu, so Space and Esc don't reach them
	if visible and event is InputEventKey:
		get_viewport().set_input_as_handled()
		if event.is_action_released("ui_cancel"):
			hide()


func open():
	for child in rows.get_children():
		child.queue_free()

	var place = 1
	for entry in SaveManager.high_scores:
		add_row([str(place), entry["name"], str(entry["score"])])
		place += 1

	empty_label.visible = SaveManager.high_scores.is_empty()
	show()


func add_row(cells: Array):
	for cell in cells:
		var label = Label.new()
		label.text = cell
		label.add_theme_font_size_override("font_size", 40)
		rows.add_child(label)


func _on_back_button_pressed() -> void:
	hide()
