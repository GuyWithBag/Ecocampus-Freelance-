@tool
extends NodeComponent
class_name HoverNodeComponent

# FIXME: Does not work yet. 

@export var node: CanvasItem
@export var autoplay: bool

@export var is_playing: bool

@export var up_offset: float
@export var down_offset: float

@export var hover_lerp: Vector2PropertyLerpComponent
#@export var play_button: bool: 
	#set(value): 
		#play()

var original_position: Vector2

func _ready() -> void: 
	if autoplay: 
		play()
		
		
# FIXME: Doesn't loop properly (BaseLerpComponent problem) 
func play() -> void: 
	return
	#original_position = node.position
	#hover_lerp.start_point = Vector2(node.position.x, node.position.y - up_offset)
	#hover_lerp.end_point = Vector2(node.position.x, node.position.y + down_offset)
	#hover_lerp.node = node
	#hover_lerp.play()
	
	
func stop() -> void: 
	hover_lerp.stop_infinite_loop()
	node.position = original_position
