extends HBoxContainer
class_name UsernameLabel

func set_user(user):
	name = user.user_id
	%UsernameLabel.text = user.username
	tooltip_text = user.username

