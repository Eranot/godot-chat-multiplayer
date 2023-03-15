extends Node

var _session: NakamaSession

func login(email: String, password: String) -> bool:
	if not ServerManager.is_connected_to_server():
		return false
	
	var s = await ServerManager.get_client().authenticate_email_async(email, password, null, false)
	if s.is_exception():
		return false
	
	_session = s
	return true


func create_account(email: String, username: String, password: String) -> bool:
	if not ServerManager.is_connected_to_server():
		return false
		
	var s = await ServerManager.get_client().authenticate_email_async(email, password, username, true)
	if s.is_exception():
		return false
	
	_session = s
	return true


func is_logged_in() -> bool:
	return not _session == null


func get_session():
	return _session
