extends Node

const MAX_HIGH_SCORES = 10

var high_scores : Array = []  # Best first, each entry is {"name": String, "score": int}
var current_highscore : int = 0
var is_new_highscore : bool = false
var json_file_path : String = "user://highscore.json"

func _ready() -> void:
	Events.lost.connect(on_lost_won)
	Events.won.connect(on_lost_won)

	load_high_scores()


func load_high_scores():
	if !FileAccess.file_exists(json_file_path):
		return

	var data = FileAccess.open(json_file_path, FileAccess.READ)
	var parsed_data = JSON.parse_string(data.get_as_text())
	if not parsed_data is Dictionary:
		return

	if parsed_data.has("scores"):
		for entry in parsed_data["scores"]:
			high_scores.append({"name": str(entry["name"]), "score": int(entry["score"])})
	# Older saves only kept a single score without a name
	elif parsed_data.get("highscore", 0) > 0:
		high_scores.append({"name": "---", "score": int(parsed_data["highscore"])})

	update_current_highscore()


func save_high_scores():
	var file = FileAccess.open(json_file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"scores": high_scores}))
	file.close()


func update_current_highscore():
	current_highscore = high_scores[0]["score"] if high_scores.size() > 0 else 0


func qualifies_for_high_scores(score: int) -> bool:
	if score <= 0:
		return false
	return high_scores.size() < MAX_HIGH_SCORES or score > high_scores[-1]["score"]


# Returns the entry's place in the list, starting at 1
func add_high_score(player_name: String, score: int) -> int:
	var index = 0
	while index < high_scores.size() and high_scores[index]["score"] >= score:
		index += 1

	high_scores.insert(index, {"name": player_name, "score": score})
	high_scores.resize(min(high_scores.size(), MAX_HIGH_SCORES))
	update_current_highscore()
	save_high_scores()
	return index + 1


func on_lost_won():
	is_new_highscore = ScoreManager.score > current_highscore
