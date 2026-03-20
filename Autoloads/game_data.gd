extends Node

signal score_changed(new_score)
var score: int = 0

var brick_types = {
	"standard": {"health": 1, "points": 100, "color": Color.RED},
	"tough": {"health": 2, "points": 300, "color": Color.BLUE},
	"unbreakable": {"health": -1, "points": 0, "color": Color.WHITE}
}

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)
