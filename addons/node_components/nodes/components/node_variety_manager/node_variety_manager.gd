@tool
extends NodeComponent
class_name NodeVarietyManager


@export var index: int: 
	set(value): 
		# To prevent infinite loop. 
		if index == value: 
			return
		index = clamp(value, 0, get_variety_count() - 1)
		var children: Array[Node] = get_children()
		for i: int in children.size(): 
			var child: Node = children[i]
			if get_children().find(child) != index: 
				child.active = false
				continue
			child.active = true
			# To prevent infinite loop. 
			if child.name != variety_name: 
				variety_name = child.name
			#print("Selected variety: %s" % child.name)
			
@export var variety_name: String: 
	set(value): 
		variety_name = value
		var children: Array[Node] = get_children()
		for i: int in children.size(): 
			var child: Node = children[i]
			if child.name.to_snake_case() == variety_name.to_snake_case(): 
				child.active = true
				index = i
				continue
			child.active = false


func get_variety_count() -> int: 
	return get_child_count()


func get_variety_at(_index: int) -> NodeVariety: 
	return NodeTools.get_item_from_array(get_children(), func(_item, i):
		if _index == i: 
			return true
		return false
	)

func get_variety(s: String) -> NodeVariety: 
	var children: Array[Node] = get_children()
	for child: NodeVariety in children: 
		if child.name.to_snake_case() == s.to_snake_case(): 
			return child
	return null


func has_variety(s: String) -> bool: 
	var node: NodeVariety = get_variety(s)
	#printerr(node)
	if is_instance_valid(node): 
		return true
	return false


func _get_configuration_warnings() -> PackedStringArray: 
	var warnings = []
	if get_children().is_empty(): 
		warnings.append("Missing NodeVariety nodes as children")
	return warnings


static func index_modifier_setter(this: Node, value: int) -> int: 
		if !this.node_variety_manager: 
			return value
		var variety_index: int = value
		
		this.node_variety_manager.index = variety_index
		variety_index = this.node_variety_manager.index
		
		if this.variety_name != this.node_variety_manager.variety_name: 
			this.variety_name = this.node_variety_manager.variety_name
		return variety_index
	
	
static func name_modifier_setter(this: Node, value: String) -> String: 
	if !this.node_variety_manager: 
		return value
	var _variety_name: String = value
	
	# Dont so that it sets the index
	this.node_variety_manager.variety_name = _variety_name
	_variety_name = this.node_variety_manager.variety_name
	
	if this.variety_index != this.node_variety_manager.index: 
		this.variety_index = this.node_variety_manager.index
	return _variety_name
