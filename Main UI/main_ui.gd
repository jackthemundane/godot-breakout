extends CanvasLayer

func _ready() -> void:
	GameData.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int) -> void:
	$HighScore/VBoxContainer/HighScoreLabel.text = str(new_score)
