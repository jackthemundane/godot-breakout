extends CanvasLayer

@onready var level_completed: Control = $LevelCompleted
@onready var score: Control = $Score
@onready var lives: Control = $Lives
@onready var game_over: Control = $GameOver
@onready var start: Control = $Start
@onready var pause: Control = $Pause
@onready var enter_name_control: VBoxContainer = $GameOver/TryAgainControl/EnterNameControl

@onready var current_score_label: Label = $Score/VBoxContainer/CurrentScore/CurrentScoreLabel
@onready var lives_label: Label = $Lives/VBoxContainer/LivesLabel
@onready var leaderboard_label: Label = $GameOver/TryAgainControl/EnterNameControl/LeaderboardLabel
@onready var leader_board: Label = $Score/VBoxContainer/HighScore/LeaderBoard

@onready var start_button: Button = $Start/VBoxContainer/StartButton
@onready var exit_button: Button = $Start/VBoxContainer/ExitButton
@onready var resume_button: Button = $Pause/ResumeButton
@onready var try_again: Button = $GameOver/TryAgainControl/TryAgain
@onready var exit_game: Button = $GameOver/TryAgainControl/ExitGame
@onready var submit_score_button: Button = $GameOver/TryAgainControl/EnterNameControl/SubmitScore

@onready var name_input: LineEdit = $GameOver/TryAgainControl/EnterNameControl/NameInput

func _ready() -> void:
	GameData.score_changed.connect(_on_score_changed)
	GameData.lives_changed.connect(_on_lives_changed)
	GameData.game_over.connect(_on_game_over)
	GameData.level_cleared.connect(_on_level_cleared)
	name_input.text_changed.connect(_on_name_input_changed)
	
	update_local_leaderboard()

	game_over.visible = false
	level_completed.visible = false
	pause.visible = false
	current_score_label.text = str(GameData.score)
	lives_label.text = "Lives: " + str(GameData.lives)
	
	pause.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over.process_mode = Node.PROCESS_MODE_ALWAYS
	
	start_button.pressed.connect(_on_start_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	try_again.pressed.connect(_on_try_again_pressed)
	exit_game.pressed.connect(_on_exit_game_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	submit_score_button.pressed.connect(_on_submit_score_pressed)
	LeaderBoard.scores_loaded.connect(_on_scores_loaded)
	LeaderBoard.score_submitted.connect(_on_score_submitted)
	
	start.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_completed.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lives.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_score_changed(new_score: int) -> void:
	current_score_label.text = str(new_score)

func _on_lives_changed(new_lives: int) -> void:
	lives_label.text = "Lives: " + str(new_lives)

func _on_game_over() -> void:
	game_over.visible = true
	if GameData.is_high_score(GameData.score):
		enter_name_control.visible = true
		submit_score_button.disabled = false
		name_input.editable = true
		name_input.text = ""
	else:
		enter_name_control.visible = false
	LeaderBoard.fetch_scores()

func _on_level_cleared() -> void:
	level_completed.visible = true
	await get_tree().create_timer(3.0).timeout
	level_completed.visible = false

func show_pause_menu(p_is_paused: bool) -> void:
	pause.visible = p_is_paused

func _on_start_pressed() -> void:
	start.visible = false
	score.visible = true
	lives.visible = true
	get_parent().start_game()

func _on_resume_pressed() -> void:
	get_parent().toggle_pause()

func _on_try_again_pressed() -> void:
	game_over.visible = false
	GameData.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_game_pressed() -> void:
	get_tree().quit()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and GameData.lives > 0:
		if start.visible or game_over.visible or level_completed.visible:
			return
		get_parent().toggle_pause()

func _on_submit_score_pressed() -> void:
	var player_name = name_input.text.strip_edges().to_upper()
	if player_name.length() != 3:
		return
	submit_score_button.disabled = true
	name_input.editable = false
	GameData.add_local_score(player_name, GameData.score)
	#high_score_label.text = str(int(GameData.local_scores[0]["score"]))
	update_local_leaderboard()
	LeaderBoard.submit_score(player_name, GameData.score)

func _on_score_submitted() -> void:
	LeaderBoard.fetch_scores()

func _on_scores_loaded(scores: Array) -> void:
	var text = "=== LEADERBOARD ===\n"
	for i in scores.size():
		text += str(i + 1) + ". " + scores[i]["name"] + " - " + str(scores[i]["score"]) + "\n"
	leader_board.text = text

func _on_name_input_changed(new_text: String) -> void:
	var upper = new_text.to_upper()
	if new_text != upper:
		name_input.text = upper
		name_input.caret_column = upper.length()

func update_local_leaderboard() -> void:
	var text = ""
	for i in GameData.local_scores.size():
		text += str(i + 1) + ". " + GameData.local_scores[i]["name"] + " - " + str(int(GameData.local_scores[i]["score"])) + "\n"
	leader_board.text = text
