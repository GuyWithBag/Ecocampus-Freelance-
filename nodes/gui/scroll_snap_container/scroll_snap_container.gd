## Includes a built in interpolation in between snaps. Automatically determines the size of each snap with the use of the total size of the container. Only works if each column/row in the container is the same size. 
@tool
extends ScrollContainer
class_name ScrollSnapContainer

signal finished_snap

enum ScrollDirection {
	HORIZONTAL, 
	VERTICAL
}

#@export var snaps: int: 
	#set(value): 
		#snaps = value

@export var scroll_direction: ScrollDirection

@export var current_snap_index: int: 
	set(value): 
		current_snap_index = clamp(value, 0, get_scroll_children_size() - 1)
		if !is_node_ready(): 
			await ready
			
		var snap_size: Vector2 = get_scroll_size() / get_scroll_children_size()
		#printerr(snap_size)
		#scroll_horizontal_custom_step = abs(snap_size.x)
		#printerr(get_scroll_children_size())
		#printerr("scroll size: ", get_scroll_size())
		#printerr("snap_size: ", snap_size)
		#printerr("snap_size scale: ", snap_size.x * current_snap_index)
		#printerr("max: ", get_h_scroll_bar().max_value)
		#printerr("scroll_children_size: ", get_scroll_children_size())
		#printerr("current_snap_index: ", current_snap_index)
		match scroll_direction: 
			ScrollDirection.HORIZONTAL: 
				scroll_horizontal_lerp.start_point = scroll_horizontal
				scroll_horizontal_lerp.end_point = snap_size.x * current_snap_index
				if current_snap_index == get_scroll_children_size() - 1: 
					scroll_horizontal_lerp.end_point = get_h_scroll_bar().max_value
				elif current_snap_index == 0: 
					scroll_horizontal_lerp.finished.connect(func(): scroll_horizontal = 0, CONNECT_ONE_SHOT)
					scroll_horizontal_lerp.end_point = 0
				scroll_horizontal_lerp.play()
				
				
			ScrollDirection.VERTICAL: 
				scroll_vertical_lerp.start_point = scroll_vertical
				scroll_vertical_lerp.end_point = snap_size.y * current_snap_index
				scroll_vertical_lerp.play()
		
@export var interpolation: TweenArguments: 
	set(value): 
		interpolation = value
		if !is_node_ready(): 
			await ready
		scroll_horizontal_lerp.interpolation = interpolation
		scroll_vertical_lerp.interpolation = interpolation
@export var mouse_ignore_h_scroll_bar: bool

@export_group("Dependencies")
@export var scroll_horizontal_lerp: FloatPropertyLerpComponent
@export var scroll_vertical_lerp: FloatPropertyLerpComponent


func _ready() -> void: 
	scroll_horizontal_lerp.finished.connect(_on_scroll_lerp_finished)
	scroll_vertical_lerp.finished.connect(_on_scroll_lerp_finished)
	if mouse_ignore_h_scroll_bar: 
		get_h_scroll_bar().mouse_filter = Control.MOUSE_FILTER_IGNORE

#func update() -> void: 
	#pass
	#

func _on_scroll_lerp_finished() -> void: 
	finished_snap.emit()


func next() -> void: 
	current_snap_index += 1
	
	
func back() -> void: 
	current_snap_index -= 1


## How long you have to scroll
func get_scroll_size() -> Vector2: 
	var container: Container = get_container()
	if container != null: 
		return get_container().size
	return Vector2.ZERO

## How many children that are visible. 
func get_scroll_children_size() -> int: 
	return get_container().get_children().filter(
		func(item: Control): 
			return item.is_visible_in_tree()
	).size()
	
	
func get_container() -> Container: 
	for child: Node in get_children(): 
		if child is Container: 
			return child
	return null
