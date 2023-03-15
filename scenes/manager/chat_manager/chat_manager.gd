extends Node
class_name ChatManager

signal connected
signal receive_message
signal add_user
signal remove_user

var socket
var channel

func _ready():
	await connect_socket(ServerManager.get_client(), AccountController.get_session())
	connected.emit()
	channel = await join_chat("global")
	for user in channel.presences:
		add_user.emit(user)


func connect_socket(client: NakamaClient, session: NakamaSession):
	socket = Nakama.create_socket_from(client)
	socket.connected.connect(self._on_socket_connected)
	socket.closed.connect(self._on_socket_closed)
	socket.received_error.connect(self._on_socket_error)
	await socket.connect_async(session)	
	socket.received_channel_message.connect(self._on_receive_chat_message)
	socket.received_channel_presence.connect(self._on_channel_presence)


func send_message(message: String):
	await socket.write_chat_message_async(channel.id, {
		'message': message
	})

func join_chat(chat_id: String) -> NakamaRTAPI.Channel:
	return await socket.join_chat_async("global", 1, true, false)


func _on_socket_connected():
	pass


func _on_socket_closed():
	pass


func _on_socket_error(err):
	printerr("Socket error %s" % err)


func _on_receive_chat_message(data):
	var content = JSON.parse_string(data.content)
	var username = data.username
	var message = content['message']
	receive_message.emit(username, message)


func _on_channel_presence(data):
	for user in data.joins:
		add_user.emit(user)
	
	for user in data.leaves:
		remove_user.emit(user)
