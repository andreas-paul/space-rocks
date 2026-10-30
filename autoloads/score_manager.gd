extends Node

var score : int = 0


func _ready() -> void:
	Events.score.connect(on_score)
	Events.new_game.connect(reset_score)
	Events.restart.connect(reset_score)


func on_score(value: int):
	if value:
		score += value
	else:
		score += 10
	Events.score_updated.emit(score)


func reset_score():
	score = 0
	Events.score_updated.emit(score)
