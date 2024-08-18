@tool
extends BaseLerpComponent
class_name ColorLerpComponent

@export var start_point: Color = Color.WHITE: 
	set(value): 
		start_point = value 
		if !is_node_ready(): 
			await ready
		_r_lerp.start_point = start_point.r
		_g_lerp.start_point = start_point.g
		_b_lerp.start_point = start_point.b
		_a_lerp.start_point = start_point.a
		
		
@export var end_point: Color = Color.WHITE: 
	set(value): 
		end_point = value 
		if !is_node_ready(): 
			await ready
		_r_lerp.end_point = end_point.r
		_g_lerp.end_point = end_point.g
		_b_lerp.end_point = end_point.b
		_a_lerp.end_point = end_point.a

@export var _r_lerp: FloatLerpComponent
@export var _g_lerp: FloatLerpComponent
@export var _b_lerp: FloatLerpComponent
@export var _a_lerp: FloatLerpComponent

var previous_current: Color

# Can be seen by the editor for debugging purposes
@export var current: Color: 
	set(value): 
		previous_current = current
		current = value

var x: float = 0
var y: float = 0


func _physics_process(_delta: float) -> void: 
	_r_lerp.percentage = percentage
	_g_lerp.percentage = percentage
	_b_lerp.percentage = percentage
	_a_lerp.percentage = percentage
	if is_lerping(): 
		update_current()
		interpolated.emit(current)


func update_current() -> void: 
	_r_lerp.update_current()
	_g_lerp.update_current()
	_b_lerp.update_current()
	_a_lerp.update_current()
	current = Color(
		_r_lerp.current, 
		_g_lerp.current, 
		_b_lerp.current, 
		_a_lerp.current, 
	)


func _set_interpolation(value: TweenArguments) -> void: 
	interpolation = value 
	if !Engine.is_editor_hint(): 
		if !is_node_ready(): 
			await ready
			
	if !is_instance_valid(_a_lerp): 
		return
		
	_r_lerp.interpolation = interpolation
	_g_lerp.interpolation = interpolation
	_b_lerp.interpolation = interpolation
	_a_lerp.interpolation = interpolation
	
	
func set_points(start: Color, end: Color) -> void: 
	start_point = start
	end_point = end
	
	
func _is_finished() -> void: 
	if reset_start_point_when_finished && !Engine.is_editor_hint(): 
		start_point = Color.BLACK
	if reset_end_point_when_finished && !Engine.is_editor_hint(): 
		end_point = Color.BLACK
	if reset_current_when_finished: 
		current = Color.BLACK
	super._is_finished()
