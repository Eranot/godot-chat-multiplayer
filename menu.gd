extends Node

var connected := false

# Called when the node enters the scene tree for the first time.
func _ready():
	var scheme = "https"
	var host = "estudiorecursivo.online"
	var port = 443
	var server_key = "defaultkey"
	connected = AccountController.connect_to_server(server_key, host, port, scheme)

func _on_login_button_pressed():
	if(connected):
		var email = %EmailTextEdit.text
		var password = %PasswordTextEdit.text
		var success = await AccountController.login(email, password)
		if(success):
			get_tree().change_scene_to_file("res://game.tscn")
	else:
		# show some error
		pass


func _on_create_account_button_pressed():
	get_tree().change_scene_to_file("res://create_account.tscn")
