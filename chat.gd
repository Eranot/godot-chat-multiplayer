extends Node

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
	print(data)
	var content = JSON.parse_string(data.content)
	var message = content['message']
	var username = data.username
	$Messages.text += username + ": " + message + "\n"

func _on_socket_connected():
	pass

func _on_socket_closed():
	pass

func _on_socket_error(err):
	printerr("Socket error %s" % err)

func _on_send_message_button_pressed():
	await socket.write_chat_message_async(channel.id, {
		'message': %ChatBox.text
	})
	%ChatBox.text = ""
