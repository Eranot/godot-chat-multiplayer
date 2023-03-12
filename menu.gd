extends Node

@onready var loading_component = %LoadingComponent
@onready var form_error_component = %FormErrorComponent

# Called when the node enters the scene tree for the first time.
func _ready():
	if(AccountController.client == null):
		var scheme = "https"
		var host = "estudiorecursivo.online"
		var port = 443
		var server_key = "defaultkey"
		loading_component.set_is_loading(true)
		AccountController.connect_to_server(server_key, host, port, scheme)
		loading_component.set_is_loading(false)


func _on_login_button_pressed():
	loading_component.set_is_loading(true)
	var email = %EmailTextEdit.text
	var password = %PasswordTextEdit.text
	var success = await AccountController.login(email, password)
	if(success):
		get_tree().change_scene_to_file("res://game.tscn")
	else:
		form_error_component.visible = true
		form_error_component.text = "[color=#ff6459]Falha na autenticação![/color]"
	loading_component.set_is_loading(false)


func _on_rich_text_label_meta_clicked(meta):
	get_tree().change_scene_to_file("res://create_account.tscn")


func _on_password_text_edit_text_submitted(new_text):
	_on_login_button_pressed()
