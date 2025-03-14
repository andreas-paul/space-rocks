extends Node

var current_highscore : int
var json_data : Dictionary
var json_file_path : String = "user://highscore.json"
var score

func _ready() -> void:
	Events.lost.connect(on_lost_won)
	Events.won.connect(on_lost_won)
	
	score = ScoreManager.score
	
	if !FileAccess.file_exists(json_file_path):
		var file = FileAccess.open(json_file_path, FileAccess.WRITE)
		var json = JSON.stringify({"highscore": score})
		file.store_string(json)
		
	current_highscore = load_highscore_from_json(json_file_path)
	

func save_highscore_to_json(file_path, score):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var json = JSON.stringify({"highscore": score})
	file.store_string(json)


func load_highscore_from_json(file_path) -> int:
	var data = FileAccess.open(file_path, FileAccess.READ)
	var parsed_data = JSON.parse_string(data.get_as_text())
	return parsed_data["highscore"]


func handle_highscore(score: int):
	if score > current_highscore:
		save_highscore_to_json(json_file_path, score)


func on_lost_won():
	pass
