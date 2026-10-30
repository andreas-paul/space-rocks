extends CanvasLayer

@export var title_label : Label
@export var score_label : Label
@export var high_score_label : Label
@export var name_entry : Control
@export var name_edit : LineEdit
@export var save_button : Button
@export var end_buttons : Control


func _ready() -> void:
	Events.won.connect(on_game_over.bind("YOU WON"))
	Events.lost.connect(on_game_over.bind("GAME OVER"))


func on_game_over(title: String):
	title_label.text = title
	score_label.text = "SCORE: %d" % ScoreManager.score
	if SaveManager.is_new_highscore:
		high_score_label.text = "NEW HIGH SCORE!"
	else:
		high_score_label.text = "HIGH SCORE: %d" % SaveManager.current_highscore

	var can_enter_name = SaveManager.qualifies_for_high_scores(ScoreManager.score)
	name_entry.visible = can_enter_name
	end_buttons.visible = not can_enter_name
	show()

	if can_enter_name:
		save_button.disabled = true
		name_edit.edit()


func _on_name_edit_text_changed(new_text: String) -> void:
	var filtered = ""
	for character in new_text.to_upper():
		if character in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789":
			filtered += character
	name_edit.text = filtered
	name_edit.caret_column = filtered.length()
	save_button.disabled = filtered.length() != 3


func _on_name_edit_text_submitted(new_text: String) -> void:
	if not save_button.disabled:
		save_name()


func _on_save_button_pressed() -> void:
	save_name()


func _on_skip_button_pressed() -> void:
	name_entry.hide()
	end_buttons.show()


func save_name():
	var place = SaveManager.add_high_score(name_edit.text, ScoreManager.score)
	high_score_label.text = "#%d ON THE HIGH SCORE LIST" % place
	name_entry.hide()
	end_buttons.show()


func _on_play_again_button_pressed() -> void:
	get_tree().paused = false
	Events.restart.emit()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	Events.open_main_menu.emit()
