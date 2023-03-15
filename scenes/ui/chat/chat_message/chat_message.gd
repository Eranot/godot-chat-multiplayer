extends RichTextLabel
class_name ChatMessage

func setup(username: String, message: String):
	text = "[b][color=#96d8ff]" + username + ":[/color][/b] " + message
