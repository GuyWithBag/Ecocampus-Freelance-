## ItemStack resource that contains modifiable properties and contains ItemModel. 
@tool
extends SaveableResource
class_name ItemStack

signal full

@export_storage var stack: PointCounter: 
	get: 
		if !stack: 
			stack = PointCounter.new()
		return stack

@export var model: ItemModel: 
	set(value): 
		model = value
		
		if model == null: 
			return
			
		stack.when_maximum_stay = true
		stack.maximum = model.maximum_stack
		#stack.starting_value = 1
		#printerr("model: %s, stack: %s" % [model, stack.current])
		stack.maximum_hit.connect(
			func(_val: float): 
				full.emit()
		)

## For debug purposes. 
@export var stack_starting_value: float = 1: 
	set(value): 
		stack_starting_value = value
		stack.starting_value = stack_starting_value

var owner: Inventory


static func from_item(item: ItemModel, _owner: Object) -> ItemStack: 
	var obj: ItemStack = ItemStack.new()
	obj.owner = _owner
	#obj.stack_starting_value = item_stack.stack_starting_value
	#obj.stack.current = item_stack.stack.current
	obj.model = item
	return obj


static func from_item_stack(item_stack: ItemStack, _owner: Object) -> ItemStack: 
	var obj: ItemStack = ItemStack.new()
	obj.owner = _owner
	#obj.stack_starting_value = item_stack.stack_starting_value
	obj.model = item_stack.model
	obj.stack.current = item_stack.stack.current
	return obj


## If the stack is empty, this will return true. 
func subtract_from_similar(item: ItemStack) -> void: 
	if item.model != model: 
		return 
	stack.subtract(item.stack.current)
	
	
func is_equal_to(item: ItemStack) -> bool: 
	return model == item.model
	
	
func is_full() -> bool: 
	return stack.current == model.maximum_stack
	
	
func is_empty() -> bool: 
	return stack.current <= 0
	
	
func _to_string() -> String: 
	var n: String = "NullName"
	var cur: int = -1
	if model: 
		n = model.name
	if stack: 
		cur = int(stack.current)
	return "%s<ItemStack#%s>(stack_count:%s)" % [n, get_instance_id(),  cur]


func _save_properties() -> PackedStringArray: 
	return [
		"model", 
		"stack"
		#"owner", 
	]
	
	
