extends Node

func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("https://dontpad.com/frosty-fall-scorebordzera")

func _on_request_completed(result, response_code, headers, body):
	print(body.get_string_from_utf8())
