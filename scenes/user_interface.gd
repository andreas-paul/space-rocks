extends MarginContainer


@export var score_number : Label
@export var health_bar : ProgressBar


func _ready() -> void:
	Events.score_updated.connect(on_score_updated)
	Events.reduce_player_health.connect(on_reduce_player_health)
	score_number.text = str(ScoreManager.score)
	
	
func on_score_updated(score):
	score_number.text = str(ScoreManager.score)


func on_reduce_player_health():
	health_bar.value -= 10
	
	if health_bar.value <= 70:
		health_bar.modulate = Color(1, 1, 0)
		
	if health_bar.value <= 30:
		health_bar.modulate = Color(1, 0.271, 0)
		
