extends Control

func _on_create_account_button_pressed():
	var email = %EmailTextEdit.text
	var username = %UsernameTextEdit.text
	var password = %PasswordTextEdit.text
	var success = await AccountController.create_account(email, username, password)
	if(success):
		get_tree().change_scene_to_file("res://chat.tscn")
