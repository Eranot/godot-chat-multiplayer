extends Control

@onready var loading_component = %LoadingComponent as LoadingComponent
@onready var form_error_component = %FormErrorComponent

func _on_create_account_button_pressed():
	loading_component.set_is_loading(true)
	var email = %EmailTextEdit.text
	var username = %UsernameTextEdit.text
	var password = %PasswordTextEdit.text
	var success = await AccountController.create_account(email, username, password)
	if(success):
		get_tree().change_scene_to_file("res://game.tscn")
	else:
		form_error_component.visible = true
		form_error_component.text = "[color=#ff6459]Falha ao criar conta![/color]"
	loading_component.set_is_loading(false)


func _on_password_text_edit_text_submitted(new_text):
	_on_create_account_button_pressed()


func _on_voltar_label_meta_clicked(meta):
	get_tree().change_scene_to_file("res://menu.tscn")
