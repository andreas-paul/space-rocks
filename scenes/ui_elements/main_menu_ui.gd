extends MarginContainer

@onready var high_score_list = preload("res://scenes/ui_elements/high_score_list.tscn").instantiate()


func _ready() -> void:
	add_child(high_score_list)
	high_score_list.visibility_changed.connect(on_high_score_list_visibility_changed)


func _on_high_scores_button_pressed() -> void:
	high_score_list.open()


func on_high_score_list_visibility_changed():
	$CenterContainer.visible = not high_score_list.visible
	$QuitButton.visible = not high_score_list.visible


func _on_quit_button_pressed() -> void:
	Events.quit.emit()
