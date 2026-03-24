extends Node

const SAVE_PATH = "user://leaderboard.save"

signal score_changed(new_score)
signal lives_changed(new_lives)
signal game_over
signal level_cleared

var score: int = 0
var lives: int = 3
var current_level: int = 0
var multiplier: int = 1
var next_life_index: int = 0
var power_up_drop_chance: float = 0.80
var power_up_active: bool = false

var power_up_types: Array = ["extend_paddle", "multi_ball"]
var life_thresholds: Array = [1000, 2000, 4000, 8000, 16000, 32000, 64000]
var local_scores: Array = []

func _ready() -> void:
	load_scores()

var brick_types = {
	"standard": {"health": 1, "points": 100, "color": Color.RED},
	"tough": {"health": 2, "points": 300, "color": Color.BLUE},
	"unbreakable": {"health": -1, "points": 0, "color": Color.WHITE}
}

var brick_map: Dictionary = {
	0: "",
	1: "standard",
	2: "tough",
	3: "unbreakable",
}

func is_high_score(check_score: int) -> bool:
	if local_scores.size() < 10:
		return true
	return check_score > local_scores[9]["score"]

func add_score(points: int) -> void:
	score += points * multiplier
	multiplier *= 2
	score_changed.emit(score)
	check_extra_life()

func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()

func check_level_clear() -> void:
	var remaining = get_tree().get_nodes_in_group("destructible").size()
	if remaining == 0:
		level_cleared.emit()

func reset() -> void:
	score = 0
	lives = 3
	current_level = 0
	score_changed.emit(score)
	lives_changed.emit(lives)

func check_extra_life() -> void:
	if next_life_index >= life_thresholds.size():
		return
	if score >= life_thresholds[next_life_index]:
		lives += 1
		lives_changed.emit(lives)
		next_life_index += 1

func reset_multiplier() -> void:
	multiplier = 1

func add_local_score(player_name: String, player_score: int) -> void:
	local_scores.append({"name": player_name, "score": player_score})
	local_scores.sort_custom(func(a, b): return a["score"] > b["score"])
	if local_scores.size() > 10:
		local_scores.resize(10)
	save_scores()
	
func save_scores() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(local_scores))
	file.close()

func load_scores() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		file.close()
		if json:
			local_scores = json
	else:
		_create_default_scores()

func _create_default_scores() -> void:
	local_scores = [
		{"name": "AAA", "score": 1000},
		{"name": "BBB", "score": 900},
		{"name": "CCC", "score": 800},
		{"name": "DDD", "score": 700},
		{"name": "EEE", "score": 600},
		{"name": "FFF", "score": 500},
		{"name": "GGG", "score": 400},
		{"name": "HHH", "score": 300},
		{"name": "III", "score": 200},
		{"name": "JJJ", "score": 100},
	]
	save_scores()

var levels: Array = [
	# Level 1 - Simple rows
	[
		[1, 0, 0, 0, 0, 0, 0, 1],
		[0, 0, 0, 1, 1, 0, 0, 0],
	],
	# Level 2 - Diamond
	[
		[0, 0, 0, 0, 1, 0, 0, 0, 0],
		[0, 0, 0, 1, 1, 1, 0, 0, 0],
		[0, 0, 1, 1, 1, 1, 1, 0, 0],
		[0, 1, 1, 1, 1, 1, 1, 1, 0],
		[0, 0, 1, 1, 1, 1, 1, 0, 0],
		[0, 0, 0, 1, 1, 1, 0, 0, 0],
		[0, 0, 0, 0, 1, 0, 0, 0, 0],
	],
	# Level 3 - Heart
	[
		[0, 0, 0, 0, 1, 0, 0, 0, 0],
		[0, 0, 0, 1, 1, 1, 0, 0, 0],
		[0, 0, 1, 1, 1, 1, 1, 0, 0],
		[0, 1, 1, 1, 1, 1, 1, 1, 0],
		[1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 1, 1, 1, 0, 1, 1, 1, 1],
		[0, 1, 1, 0, 0, 0, 1, 1, 0],
	],
	# Level 4 - Smiley face
	[
		[0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
		[0, 1, 1, 2, 2, 2, 2, 1, 1, 0],
		[1, 1, 2, 1, 1, 1, 1, 2, 1, 1],
		[1, 2, 1, 1, 1, 1, 1, 1, 2, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 1, 2, 2, 1, 1, 2, 2, 1, 1],
		[1, 1, 2, 2, 1, 1, 2, 2, 1, 1],
		[0, 1, 1, 1, 1, 1, 1, 1, 1, 0],
		[0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
	],
	# Level 5 - Hollow box (ball trap)
	[
		[3, 3, 3, 0, 0, 0, 0, 3, 3, 3],
		[3, 0, 0, 0, 0, 0, 0, 0, 0, 3],
		[3, 0, 1, 1, 1, 1, 1, 1, 0, 3],
		[3, 0, 1, 0, 0, 0, 0, 1, 0, 3],
		[3, 0, 1, 0, 0, 0, 0, 1, 0, 3],
		[3, 0, 1, 1, 1, 1, 1, 1, 0, 3],
		[3, 0, 0, 0, 0, 0, 0, 0, 0, 3],
		[3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
	],
	# Level 6 - Arrow pointing up
	[
		[0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
		[0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
		[0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
		[0, 1, 1, 1, 1, 1, 1, 1, 1, 0],
		[0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
		[0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
		[0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
		[2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
	],
	# Level 7 - Checkerboard
	[
		[0, 1, 0, 2, 0, 1, 0, 2, 0, 1],
		[2, 0, 1, 0, 2, 0, 1, 0, 2, 0],
		[0, 1, 0, 2, 0, 1, 0, 2, 0, 1],
		[2, 0, 1, 0, 2, 0, 1, 0, 2, 0],
		[0, 1, 0, 2, 0, 1, 0, 2, 0, 1],
		[2, 0, 1, 0, 2, 0, 1, 0, 2, 0],
	],
	# Level 8 - Skull
	[
		[0, 0, 1, 0, 1, 1, 0, 1, 0, 0],
		[0, 2, 2, 1, 2, 2, 1, 2, 2, 0],
		[2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
		[2, 2, 3, 3, 2, 2, 3, 3, 2, 2],
		[2, 2, 3, 3, 2, 2, 3, 3, 2, 2],
		[0, 2, 2, 2, 2, 2, 2, 2, 2, 0],
		[0, 0, 2, 2, 2, 2, 2, 2, 0, 0],
	],
	# Level 9 - Double tunnel
	[
		[3, 3, 3, 0, 0, 0, 0, 3, 3, 3],
		[3, 0, 0, 0, 0, 0, 0, 0, 0, 3],
		[3, 0, 1, 0, 0, 0, 0, 1, 0, 3],
		[3, 0, 2, 0, 0, 0, 0, 2, 0, 3],
		[3, 0, 1, 0, 3, 3, 0, 1, 0, 3],
		[3, 0, 2, 0, 3, 3, 0, 2, 0, 3],
		[3, 0, 1, 0, 3, 3, 0, 1, 0, 3],
		[3, 0, 0, 0, 3, 3, 0, 0, 0, 3],
	],
	# Level 10 - The fortress
	[
		[0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
		[2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
		[3, 0, 0, 0, 0, 0, 0, 0, 0, 3],
		[3, 0, 2, 1, 2, 2, 1, 2, 0, 3],
		[3, 0, 1, 1, 1, 1, 1, 1, 0, 3],
		[3, 0, 2, 1, 2, 2, 1, 2, 0, 3],
		[3, 0, 0, 0, 0, 0, 0, 0, 0, 3],
		[2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
		[3, 0, 3, 0, 3, 3, 0, 3, 0, 3],
	],
]
