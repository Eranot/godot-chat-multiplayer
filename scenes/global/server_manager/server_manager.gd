extends Node

var _client: NakamaClient

func connect_to_server():
	var scheme = "https"
	var host = "estudiorecursivo.online"
	var port = 443
	var server_key = "qj^#Q$fj#Q2E25k3!X%7"
	_client = Nakama.create_client(server_key, host, port, scheme)


func is_connected_to_server() -> bool:
	return not _client == null


func get_client() -> NakamaClient:
	return _client
