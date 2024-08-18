@icon("res://addons/node_components/class_icons/points-counter.png")
@tool
extends SaveableResource
class_name PointCounter

signal current_changed(new: float, prev: float)
signal current_added(value: float)
signal current_subtracted(value: float)

signal maximum_exceeded(value: float)
signal minimum_exceeded(value: float)
signal maximum_hit(value: float)
signal minimum_hit(value: float)

signal is_emptied

@export var starting_value: float = 1: 
	set(value): 
		starting_value = value
		current = starting_value
		
@export var minimum: float = 0
@export var maximum: float = 5
@export var cant_be_added: bool = false
@export var cant_be_subtracted: bool = false

# Stay when maximum is hit
@export var when_maximum_stay: bool = false
# Stay when minimum is hit
@export var when_minmum_stay: bool = false

@export var reset_after_maximum_exceeded: bool = false
@export var reset_after_minimum_exceeded: bool = false

@export var reset_after_maximum_hit: bool = false
@export var reset_after_minimum_hit: bool = false

@export var rounded_off: bool = false
@export var disabled: bool = false

var current: float = 1: 
	set(value): 
		var new_val: float = value
		previous = current
			
		if when_maximum_stay: 
			new_val = min(value, maximum)
		if when_minmum_stay: 
			new_val = max(value, minimum)
			
		if reset_after_maximum_exceeded && current > maximum: 
			new_val = minimum
		if reset_after_minimum_exceeded && current < minimum: 
			new_val = maximum
			
		if reset_after_maximum_hit && current == maximum: 
			new_val = minimum
		if reset_after_minimum_hit && current == minimum: 
			new_val = maximum
			
		if rounded_off: 
			new_val = round(value)
			
		current = new_val
		
		current_changed.emit(new_val, current)
		
		if value > maximum: 
			maximum_exceeded.emit(value)
		elif value == maximum: 
			maximum_hit.emit(value)
		elif value < minimum: 
			minimum_exceeded.emit(value)
		elif value == minimum: 
			minimum_hit.emit(value)
			
		if new_val == 0: 
			is_emptied.emit()
			
var previous: float = current


func increment() -> void: 
	add(1)
	
	
func decrement() -> void: 
	subtract(1)


func add(value: float) -> void: 
	if disabled: 
		return
	if cant_be_added: 
		return
	previous = current
	current += value
	current_added.emit(value)
	current_changed.emit(current, previous)
	
	
func subtract(value: float) -> void: 
	if disabled: 
		return
	if cant_be_subtracted: 
		return
	previous = current
	current -= value
	current_subtracted.emit(value)
	current_changed.emit(current, previous)
	
	
func is_minimum() -> bool: 
	if current <= minimum: 
		return true
	return false


func is_maximum() -> bool: 
	return current >= maximum


func is_greater_than_minimum() -> bool: 
	return current > minimum
	
	
func is_less_than_maximum() -> bool: 
	return current < maximum


func is_empty() -> bool: 
	return current == 0


func has_exceeded_maximum() -> bool: 
	return current > maximum
	
	
func has_exceeded_minimum() -> bool: 
	return current < minimum


func reset() -> void: 
	current = starting_value


func max_out() -> void: 
	current = maximum


#func load_data(data: Dictionary) -> void: 
	#var properties: PackedStringArray = data.keys()
	#for property in properties: 
		##if property == "state_machine": 
			##state_machine.load_data(data[property])
			##continue
		#self.set(property, data[property])


func set_properties(props: PointCounterProperties) -> void: 
	starting_value = props.starting_value
	maximum = props.maximum
	minimum = props.minimum


func _save_properties() -> PackedStringArray: 
	return [
		"disabled", 
		"current", 
		"minimum", 
		"maximum", 
		"cant_be_added", 
		"cant_be_subtracted"
	]
	
	
func _to_string() -> String: 
	return "PointCounter#%s(current:%s)" % [get_instance_id(), current]
