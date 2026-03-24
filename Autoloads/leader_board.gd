extends Node

signal scores_loaded(scores: Array)
signal score_submitted

var base_url: String

func _ready() -> void:
	if OS.has_feature("web"):
		base_url = "/api/breakout/scores"
	else:
		base_url = "http://localhost:3000/api/breakout/scores"

func fetch_scores() -> void:
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_fetch_completed.bind(http))
	http.request(base_url)

func submit_score(player_name: String, score: int) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_submit_completed.bind(http))
	
	var body = JSON.stringify({"name": player_name, "score": score})
	var headers = ["Content-Type: application/json"]
	http.request(base_url, headers, HTTPClient.METHOD_POST, body)

func _on_fetch_completed(result: int, code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	if code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		scores_loaded.emit(json)
	else:
		print("Leaderboard fetch failed with code: ", code)
		scores_loaded.emit([])

func _on_submit_completed(result: int, code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	if code == 201:
		score_submitted.emit()
	else:
		print("Score submit failed with code: ", code)
