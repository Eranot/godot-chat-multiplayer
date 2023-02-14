extends Node

var client: NakamaClient
var session: NakamaSession

func connect_to_server(server_key: String, host: String, port: int, scheme: String):
	client = Nakama.create_client(server_key, host, port, scheme)
	return true

func create_account(email: String, username: String, password: String) -> bool:
	var s = await client.authenticate_email_async(email, password, username, true)
	if s.is_exception():
		return false
	session = s
	return true
	
func login(email: String, password: String) -> bool:
	var s = await client.authenticate_email_async(email, password, null, false)
	if s.is_exception():
		return false
	session = s
	return true
