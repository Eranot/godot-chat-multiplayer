@tool
extends Control

enum CORNER {
	TOP = 1, 
	BOTTOM = 2, 
	LEFT = 4, 
	RIGHT = 8, 
	TOP_LEFT = 16, 
	TOP_RIGHT = 32, 
	BOTTOM_LEFT = 64, 
	BOTTOM_RIGHT = 128
} 

enum MODE {
	SIZE, MINIMUM_SIZE
}

## Whether the resizing behaviour is active or not
@export var active: bool = true

## Thickness of the line where the mouse has to be to be able to start the resizing
@export var border_width: int = 6

## Minimum size that the parent node will be
@export var min_size: Vector2 = Vector2(250, 150)

## Maximum size that the parent node will be
@export var max_size: Vector2 = Vector2(700, 400)

@export_flags( \
	"TOP", \
	"BOTTOM", \
	"LEFT", \
	"RIGHT", \
	"TOP_LEFT", \
	"TOP_RIGHT", \
	"BOTTOM_LEFT", \
	"BOTTOM_RIGHT" \
) var activated_corners = 255

@export var mode: MODE = MODE.SIZE

var initial_resize_position = null
var initial_parent_size = null
var initial_parent_position = null
var current_corner = null
@onready var parent = get_parent()

func _enter_tree():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent):
	if not active:
		return
	
	if event is InputEventMouseMotion:
		var corner = _is_mouse_near_corner()
		
		if corner != null:
			var is_corner_active = activated_corners & corner
			if not is_corner_active:
				return
		
		if(corner == CORNER.TOP_LEFT or corner == CORNER.BOTTOM_RIGHT):
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_FDIAGSIZE)
			get_viewport().set_input_as_handled()
		elif(corner == CORNER.BOTTOM_LEFT or corner == CORNER.TOP_RIGHT):
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_BDIAGSIZE)
			get_viewport().set_input_as_handled()
		elif(corner == CORNER.TOP or corner == CORNER.BOTTOM):
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_VSIZE)
			get_viewport().set_input_as_handled()
		elif(corner == CORNER.LEFT or corner == CORNER.RIGHT):
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_HSIZE)
			get_viewport().set_input_as_handled()
		
		if(initial_resize_position):
			var new_size_and_position = _get_new_size_and_position()
			if(mode == MODE.SIZE):
				parent.size = new_size_and_position.new_size
				parent.position = new_size_and_position.new_position
			elif(mode == MODE.MINIMUM_SIZE):
				parent.custom_minimum_size = new_size_and_position.new_min_size
			
	elif event is InputEventMouseButton:
		var corner = _is_mouse_near_corner()
		
		if corner != null:
			var is_corner_active = activated_corners & corner
			if not is_corner_active:
				return
		
		if event.is_pressed() and corner != null and not initial_resize_position:
			initial_resize_position = get_global_mouse_position()
			initial_parent_size = parent.size if mode == MODE.SIZE else parent.custom_minimum_size
			initial_parent_position = parent.position
			current_corner = corner
		elif not event.is_pressed():
			initial_resize_position = null
			current_corner = null

func _get_new_size_and_position():
	var new_size = parent.size
	var new_min_size = parent.custom_minimum_size
	var new_position = initial_parent_position
	
	if(mode == MODE.SIZE):
		new_size = _get_new_size(new_size)
	elif mode == MODE.MINIMUM_SIZE:
		new_min_size = _get_new_size(new_min_size)
	
	if current_corner == CORNER.TOP_LEFT or current_corner == CORNER.LEFT:
		new_position = initial_parent_position - (new_size - initial_parent_size)
	elif current_corner == CORNER.TOP_RIGHT or current_corner == CORNER.RIGHT or  current_corner == CORNER.TOP:
		var x = initial_parent_position.x
		var y = initial_parent_position.y - (new_size.y - initial_parent_size.y)
		new_position = Vector2(x, y)
	elif current_corner == CORNER.BOTTOM_LEFT:
		var x = initial_parent_position.x - (new_size.x - initial_parent_size.x)
		var y = initial_parent_position.y
		new_position = Vector2(x, y)
	
	return {
		'new_size': new_size,
		'new_min_size': new_min_size,
		'new_position': new_position,
	}

func _get_new_size(size: Vector2):
	var new_size = size
		
	var is_corner_active = activated_corners & current_corner
	if not is_corner_active:
		return new_size
	
	if current_corner == CORNER.BOTTOM_RIGHT:
		new_size = initial_parent_size + (get_global_mouse_position() - initial_resize_position)
	elif current_corner == CORNER.TOP_LEFT:
		new_size = initial_parent_size - (get_global_mouse_position() - initial_resize_position)
	elif current_corner == CORNER.TOP_RIGHT:
		var x = initial_parent_size.x + (get_global_mouse_position().x - initial_resize_position.x)
		var y = initial_parent_size.y - (get_global_mouse_position().y - initial_resize_position.y)
		new_size = Vector2(x, y)
	elif current_corner == CORNER.BOTTOM_LEFT:
		var x = initial_parent_size.x - (get_global_mouse_position().x - initial_resize_position.x)
		var y = initial_parent_size.y + (get_global_mouse_position().y - initial_resize_position.y)
		new_size = Vector2(x, y)
	elif current_corner == CORNER.LEFT:
		var x = initial_parent_size.x - (get_global_mouse_position().x - initial_resize_position.x)
		new_size = Vector2(x, new_size.y)
	elif current_corner == CORNER.RIGHT:
		var x = initial_parent_size.x + (get_global_mouse_position().x - initial_resize_position.x)
		new_size = Vector2(x, new_size.y)
	elif current_corner == CORNER.BOTTOM:
		var y = initial_parent_size.y + (get_global_mouse_position().y - initial_resize_position.y)
		new_size = Vector2(new_size.x, y)
	elif current_corner == CORNER.TOP:
		var y = initial_parent_size.y - (get_global_mouse_position().y - initial_resize_position.y)
		new_size = Vector2(new_size.x, y)
	
	return _respect_min_max_size(new_size)

func _is_mouse_near_corner():
	var mouse_position: Vector2 = get_global_mouse_position()
	var is_near_y_top = _is_near(mouse_position.y, parent.global_position.y)
	var is_near_x_left = _is_near(mouse_position.x, parent.global_position.x)
	var is_near_y_bottom = _is_near(mouse_position.y, parent.global_position.y + parent.get_global_rect().size.y)
	var is_near_x_right = _is_near(mouse_position.x, parent.global_position.x + parent.get_global_rect().size.x)
	
	if is_near_y_top and is_near_x_left:
		return CORNER.TOP_LEFT
		
	if is_near_y_bottom and is_near_x_left:
		return CORNER.BOTTOM_LEFT
	
	if is_near_y_top and is_near_x_right:
		return CORNER.TOP_RIGHT
		
	if is_near_y_bottom and is_near_x_right:
		return CORNER.BOTTOM_RIGHT
	
	var is_inside_container = mouse_position.x >= parent.global_position.x - border_width \
		and mouse_position.x <= parent.global_position.x + parent.size.x + border_width \
		and mouse_position.y >= parent.global_position.y - border_width \
		and mouse_position.y <= parent.global_position.y + parent.size.y + border_width
	
	if is_near_y_top and is_inside_container:
		return CORNER.TOP
		
	if is_near_y_bottom and is_inside_container:
		return CORNER.BOTTOM
		
	if is_near_x_left and is_inside_container:
		return CORNER.LEFT
		
	if is_near_x_right and is_inside_container:
		return CORNER.RIGHT
	
	return null
	
# Returns if the values are near eachother, based on the border_width
func _is_near(value1, value2):
	return abs(value1 - value2) <= border_width

func _respect_min_max_size(new_size):
	if(min_size.x != 0 and new_size.x < min_size.x):
		new_size.x = min_size.x
	if(min_size.y != 0 and new_size.y < min_size.y):
		new_size.y = min_size.y
	if(max_size.x != 0 and new_size.x > max_size.x):
		new_size.x = max_size.x
	if(max_size.y != 0 and new_size.y > max_size.y):
		new_size.y = max_size.y
	return new_size
	
