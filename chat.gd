extends Control

var socket
var channel

func _ready():
	await connect_socket(AccountController.client, AccountController.session)
	channel = await join_chat("global")

func connect_socket(client: NakamaClient, session: NakamaSession):
	socket = Nakama.create_socket_from(client)
	socket.connected.connect(self._on_socket_connected)
	socket.closed.connect(self._on_socket_closed)
	socket.received_error.connect(self._on_socket_error)
	await socket.connect_async(session)	
	socket.received_channel_message.connect(self._on_receive_chat_message)

func join_chat(chat_id: String) -> NakamaRTAPI.Channel:
	return await socket.join_chat_async("global", 1, true, false)

func _on_receive_chat_message(data):
	var content = JSON.parse_string(data.content)
	var message_text = content['message']
	var username = data.username
	
	var message = preload("res://message.tscn").instantiate()
	message.text = "[b]" + username + "[/b]" + ": " + message_text
	%MessagesContainer.add_child(message)
	await get_tree().create_timer(0.1).timeout
	%ScrollContainer.scroll_vertical = %ScrollContainer.get_v_scroll_bar().max_value

func _on_socket_connected():
	pass

func _on_socket_closed():
	pass

func _on_socket_error(err):
	printerr("Socket error %s" % err)

func _on_chat_box_text_submitted(new_text):
	await socket.write_chat_message_async(channel.id, {
		'message': new_text
	})
	%ChatBox.text = ""

func _input(event):
	# If clicks outside the Chat, releases the focus from the LineEdit
	if event is InputEventMouseButton and not _is_pos_in(event.position):
		%ChatBox.release_focus()

func _is_pos_in(checkpos: Vector2):
	var gr = self.get_global_rect()
	return checkpos.x>=gr.position.x and checkpos.y>=gr.position.y and checkpos.x<gr.end.x and checkpos.y<gr.end.y	
