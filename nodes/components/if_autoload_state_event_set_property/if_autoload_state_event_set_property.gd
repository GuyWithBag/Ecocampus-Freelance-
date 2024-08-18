extends ConditionalSetPropertyComponent
class_name IfAutoloadStateEventSetProperty

enum StateEvent {
	STATE_ENTERED, 
	STATE_EXITED
}

@export var autoload: String
@export var property: String
@export var state_event: StateEvent

var autoload_node: Node: 
	get: 
		return NodeTools.get_autoload(self, autoload)

var state: StateChartState: 
	get: 
		return autoload_node.get(property) 

func _ready() -> void: 
	super._ready()
	update_condition()
	#printerr(property)
	if debug: 
		print_color.out_debug_wvalue("connected %s", state)
	match state_event: 
		StateEvent.STATE_ENTERED: 
			state.state_entered.connect(update_condition)
		StateEvent.STATE_EXITED: 
			state.state_exited.connect(update_condition)


func _condition() -> bool: 
	if state_event == StateEvent.STATE_EXITED: 
		return !state.active
	return state.active
