extends Panel
class_name LoadingComponent

@export var is_loading: bool = true

func _ready():
	set_is_loading(is_loading)

func set_is_loading(is_loading: bool):
	self.is_loading = is_loading
	if(is_loading):
		%LoadingSprite.play("default")
		visible = true
	else:
		%LoadingSprite.stop()
		visible = false
