extends Node

var score : int = 0


func _ready() -> void:
	Events.score.connect(on_score)


func on_score():
	score += 10
	Events.score_updated.emit(score)
