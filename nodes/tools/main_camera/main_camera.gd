extends Camera2D
class_name MainCamera


@export var follow_node: Node2D: 
	set(value): 
		follow_node = value
		#if !follow_node.is_node_ready(): 
			#await follow_node.ready
		follow_node_component.follow(follow_node)
		
		
@export var follow_node_component: FollowNodeComponent
@export var zoom_offset: Vector2

@export_group("Adjust", "adjust")
@export var adjust_enabled: bool
@export var adjust_camera_on_screen_width: int
@export var adjust_offset: Vector2


func _process(_delta: float) -> void: 
	zoom = Vector2(GlobalVariables.expanded_viewport_percentage.x, GlobalVariables.expanded_viewport_percentage.x) + zoom_offset
	#printerr(GlobalVariables.viewport_size)
	
	if adjust_enabled && GlobalVariables.viewport_size.y <= adjust_camera_on_screen_width: 
		follow_node_component.offset = adjust_offset
	elif !adjust_enabled: 
		follow_node_component.offset = Vector2.ZERO
		
