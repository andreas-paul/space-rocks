extends MarginContainer

@export var score_number : Label
@export var health_bar : ProgressBar

@onready var healthy_color = health_bar.modulate


func _ready() -> void:
	Events.score_updated.connect(on_score_updated)
	Events.player_health_changed.connect(on_player_health_changed)
	score_number.text = str(ScoreManager.score)

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		health_bar.max_value = player.hitpoints
		on_player_health_changed(player.hitpoints)
	
	
func on_score_updated(score):
	score_number.text = str(ScoreManager.score)


func on_player_health_changed(hitpoints: int):
	health_bar.value = hitpoints

	var health_ratio = health_bar.value / health_bar.max_value
	if health_ratio <= 0.3:
		health_bar.modulate = Color(1, 0.271, 0)
	elif health_ratio <= 0.7:
		health_bar.modulate = Color(1, 1, 0)
	else:
		health_bar.modulate = healthy_color
		
