extends Node

var score : int = 0


func _ready() -> void:
	Events.score.connect(on_score)


func on_score(value: int):
	if value:
		score += value
	else:
		score += 10
	Events.score_updated.emit(score)
