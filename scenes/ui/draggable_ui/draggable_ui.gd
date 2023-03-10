extends Control

## Whether the dragging behaviour is active or not
@export var active: bool = true

## The node that will be dragged
@export var parent: Control

var drag_position = null

func _on_gui_input(event):
	if not active:
		self.mouse_default_cursor_shape = CursorShape.CURSOR_ARROW
		return
		
	if event is InputEventMouseButton:
		var mouse_position = get_global_mouse_position()
		
		if event.pressed:
			drag_position = mouse_position - parent.global_position
		else:
			drag_position = null
	
	elif event is InputEventMouseMotion:
		var mouse_position = get_global_mouse_position()
		self.mouse_default_cursor_shape = CursorShape.CURSOR_DRAG
		
		if drag_position:
			parent.global_position = mouse_position - drag_position
