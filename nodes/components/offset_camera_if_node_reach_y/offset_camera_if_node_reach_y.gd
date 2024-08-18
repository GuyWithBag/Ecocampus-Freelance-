@tool
class_name OffsetCameraIfNodeReachY
extends NodeComponent


@export var node: Node2D
@export var reach_y: float

@export var camera: Camera2D
@export var camera_offset: Vector2
@export var camera_offset_default: Vector2

@export var camera_offset_transition: TweenArguments
#@export var map_top_limit: int
@export var disabled: bool

var reached: bool

func _process(_delta: float) -> void: 
	if Engine.is_editor_hint() || disabled: 
		return
		
	if !is_node_ready(): 
		return
		
	var follow_node_component: FollowNodeComponent = camera.follow_node_component
	
	if node is EntityNode: 
		if node.walk.direction.y > 0: 
			if reached: 
				follow_node_component.offset = camera_offset_default
			reached = false
			return
	
	if node.global_position.y <= reach_y: 
		if !reached: 
			#var tween: Tween = camera_offset_transition.create_tween(get_tree()) 
			#var top_border_position: float= follow_node_component.get_new_position_after_offset().y - 1080
			#tween.finished.connect(
				#func(): 
					#reached = true
			#)
			#if top_border_position <= map_top_limit: 
				#printerr("diff: ", map_top_limit - top_border_position)
				#tween.tween_property(follow_node_component, "offset", camera_offset + Vector2(0, map_top_limit - top_border_position), camera_offset_transition.duration)
			#else: 
				#printerr(follow_node_component.get_new_position_after_offset())
				#tween.tween_property(follow_node_component, "offset", camera_offset, camera_offset_transition.duration)
			#tween.play()
			follow_node_component.offset = camera_offset
			#return
		reached = true
	else: 
		if reached: 
			#var tween: Tween = camera_offset_transition.create_tween(get_tree()) 
			#tween.tween_property(follow_node_component, "offset", Vector2.ZERO, camera_offset_transition.duration)
			#tween.play()
			#await tween.finished
			follow_node_component.offset = camera_offset_default
		reached = false
		
