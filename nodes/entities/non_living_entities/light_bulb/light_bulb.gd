@tool
extends EntityNode
class_name LightBulb

signal turned_on
signal turned_off

@export var state: GlobalEnums.OnState: 
	set(value): 
		state = value
		if !is_node_ready(): 
			await ready
		if state == GlobalEnums.OnState.ON: 
			node_variety_manager.index = 1
			turned_on.emit()
		else: 
			node_variety_manager.index = 0
			turned_off.emit()
			
		#printerr(state)


func _interact() -> void: 
	if is_on(): 
		state = GlobalEnums.OnState.OFF
		PlayerManager.player_data.lights_turned_off += 1
	else: 
		state = GlobalEnums.OnState.ON


func _on_on_state_entered() -> void:
	node_variety_manager.index = 1


func _on_off_state_entered() -> void:
	node_variety_manager.index = 0
	
	
func is_on() -> bool: 
	return node_variety_manager.index == 1
	
	
	
