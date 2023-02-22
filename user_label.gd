extends HBoxContainer

func set_user(user):
	name = user.user_id
	$UsernameLabel.text = user.username
