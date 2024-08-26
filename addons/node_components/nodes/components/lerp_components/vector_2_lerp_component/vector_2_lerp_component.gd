@tool
extends BaseLerpComponent
class_name Vector2LerpComponent

@export var _x_interpolate: FloatLerpComponent
@export var _y_interpolate: FloatLerpComponent

@export var start_point: Vector2: 
	set(value): 
		start_point = value
		if !Engine.is_editor_hint(): 
			if !is_node_ready(): 
				await ready
		if _x_interpolate: 
			_x_interpolate.start_point = start_point.x
		if _y_interpolate: 
			_y_interpolate.start_point = start_point.y
@export var end_point: Vector2: 
	set(value): 
		end_point = value
		if !Engine.is_editor_hint(): 
			if !is_node_ready(): 
				await ready
		if _x_interpolate: 
			_x_interpolate.end_point = end_point.x
		if _y_interpolate: 
			_y_interpolate.end_point = end_point.y

var previous_current: Vector2

# Can be seen by the editor for debugging purposes
@export var current: Vector2: 
	set(value): 
		previous_current = current
		current = value


func _physics_process(_delta: float) -> void: 
	if _x_interpolate: 
		_x_interpolate.percentage = percentage
	if _y_interpolate: 
		_y_interpolate.percentage = percentage
	if is_lerping(): 
		update_current()
		interpolated.emit(current)
	

func update_current() -> void: 
	if _x_interpolate: 
		_x_interpolate.update_current()
	if _y_interpolate: 
		_y_interpolate.update_current()
	current = Vector2(_x_interpolate.current, _y_interpolate.current)


func _set_interpolation(value: TweenArguments) -> void: 
	interpolation = value 
	if !Engine.is_editor_hint(): 
		if !is_node_ready(): 
			await ready
	if _x_interpolate: 
		_x_interpolate.interpolation = interpolation
	if _y_interpolate: 
		_y_interpolate.interpolation = interpolation
	
	
func set_points(start: Vector2, end: Vector2) -> void: 
	start_point = start
	end_point = end
	
	
func _is_finished() -> void: 
	if reset_start_point_when_finished && !Engine.is_editor_hint(): 
		start_point = Vector2.ZERO
	if reset_end_point_when_finished && !Engine.is_editor_hint(): 
		end_point = Vector2.ZERO
	if reset_current_when_finished && !Engine.is_editor_hint(): 
		current = Vector2.ZERO
	super._is_finished()
