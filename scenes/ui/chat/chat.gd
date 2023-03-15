extends Control

@export var chat_message_scene: PackedScene
@export var username_label_scene: PackedScene
@export var chat_manager: ChatManager

@onready var scroll_container = %ScrollContainer
@onready var messages_container = %MessagesContainer

func _ready():
	chat_manager.connected.connect(on_connected)
	chat_manager.receive_message.connect(on_receive_message)
	chat_manager.add_user.connect(on_add_user)
	chat_manager.remove_user.connect(on_remove_user)
		

func on_connected():
	%LoadingPanel.set_is_loading(false)


func on_receive_message(username: String, message: String):
	var chat_message = chat_message_scene.instantiate() as ChatMessage
	messages_container.add_child(chat_message)
	chat_message.setup(username, message)
	await get_tree().create_timer(0.1).timeout
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func on_add_user(user):
	var user_label = username_label_scene.instantiate() as UsernameLabel
	%UsersContainer.add_child(user_label)
	user_label.set_user(user)


func on_remove_user(user):
	var user_label = %UsersContainer.get_node(user.user_id)
	%UsersContainer.remove_child(user_label)


func _on_chat_box_text_submitted(new_text):
	chat_manager.send_message(new_text)
	%ChatBox.text = ""


func _input(event):
	# If clicks outside the Chat, releases the focus from the LineEdit
	if event is InputEventMouseButton and not _is_pos_in(event.position):
		%ChatBox.release_focus()


func _is_pos_in(checkpos: Vector2):
	var gr = self.get_global_rect()
	return checkpos.x>=gr.position.x and checkpos.y>=gr.position.y and checkpos.x<gr.end.x and checkpos.y<gr.end.y	


func _on_users_button_toggled(button_pressed):
	%UsuariosContainer.visible = button_pressed
