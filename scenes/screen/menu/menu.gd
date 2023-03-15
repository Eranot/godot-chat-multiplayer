extends Node

@export var game_scene: PackedScene
@export var create_account_scene: PackedScene

@onready var loading_component = %LoadingComponent
@onready var form_error_component = %FormErrorComponent


func _ready():
	if(not ServerManager.is_connected_to_server()):
		loading_component.set_is_loading(true)
		ServerManager.connect_to_server()
		loading_component.set_is_loading(false)


func _on_login_button_pressed():
	loading_component.set_is_loading(true)
	var email = %EmailTextEdit.text
	var password = %PasswordTextEdit.text
	var success = await AccountController.login(email, password)
	if(success):
		get_tree().change_scene_to_packed(game_scene)
	else:
		show_error("Falha na autenticação!")
	loading_component.set_is_loading(false)


func show_error(message: String):
	form_error_component.visible = true
	form_error_component.text = "[color=#ff6459]{message}[/color]".format({"message": message})


func _on_rich_text_label_meta_clicked(meta):
	get_tree().change_scene_to_packed(create_account_scene)


func _on_password_text_edit_text_submitted(new_text):
	_on_login_button_pressed()
