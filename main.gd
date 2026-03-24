extends Node3D

@export var ball_path: NodePath
@export var paddle_path: NodePath
@export var level_spawner_path: NodePath

@onready var ui: CanvasLayer = $MainUI

var ball: Node3D
var paddle: Node3D
var level_spawner: Node3D
var starting_level: int = 0
var game_started: bool = false

func _ready() -> void:
	ball = get_node(ball_path)
	paddle = get_node(paddle_path)
	level_spawner = get_node(level_spawner_path)
	
	GameData.game_over.connect(_on_game_over)
	GameData.level_cleared.connect(_on_level_cleared)
	
	ball.visible = false
	paddle.visible = false
	get_tree().paused = true

func toggle_pause() -> void:
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused
	ui.show_pause_menu(is_paused)

func start_game() -> void:
	ball.visible = true
	paddle.visible = true
	game_started = true
	GameData.current_level = starting_level
	level_spawner.spawn_level(GameData.levels[GameData.current_level])
	get_tree().paused = false

func _on_level_cleared() -> void:
	# Clean up any extra balls from multi-ball
	for b in get_tree().get_nodes_in_group("active_balls"):
		if b != ball:
			b.queue_free()
	ball.reset()
	GameData.current_level += 1
	if GameData.current_level >= GameData.levels.size():
		get_tree().paused = true
	else:
		get_tree().paused = true
		await get_tree().create_timer(3.0, true, false, true).timeout
		level_spawner.spawn_level(GameData.levels[GameData.current_level])
		get_tree().paused = false

func _on_game_over() -> void:
	game_started = false
	ball.queue_free()
	get_tree().paused = true
