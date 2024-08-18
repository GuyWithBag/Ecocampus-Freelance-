@tool
extends SaveableResource
class_name Inventory

signal full

signal items_changed(new_items: Array[ItemStack])

signal items_set(new_items: Array[ItemStack])

signal items_added(new_items: Array[ItemStack])
signal item_added(new_item: ItemStack)

signal obtained_new_item(new_item: ItemModel)

signal items_taken_from_inventory(by: Node, new_items: Array[ItemStack])

signal items_removed(new_items: Array[ItemStack])
signal item_removed(new_item: ItemStack)

@export var items: Array[ItemStack] = []: 
	set(value): 
		items = value
		
		for item: ItemStack in items: 
			item.owner = self

@export var max_items: int = -1

var owner: Object: 
	set(value): 
		owner = value
		print_color.owner = owner
		
var print_color: PrintColor
var _max_items_error: Callable = func(val): print_color.out_debug_wvalue("Cannot add more items since the inventory has reached it's maximum. The new items", val)
var added_items_history: Array[ItemModel]

func _init() -> void: 
	super._init()
	print_color = PrintColor.new()
	print_color.owner = owner
	print_color.owner_name_color = Color("93ffb5")
	print_color.color = Color("b4ff00")

## type == ItemModel.Type
func get_items_by_type(type, inversed: bool = false) -> Array[ItemStack]: 
	return items.filter(
		func(item): 
			if inversed: 
				return item.model.type != type
			return item.model.type == type
	)
	
	
func get_tool_items() -> Array[ItemStack]: 
	return get_items_by_type(ItemModel.Type.TOOL)


func set_items(new_items: Array[ItemStack]) -> void: 
	if _is_value_too_big(new_items.size()): 
		_max_items_error.call(new_items)
		return
	items = new_items
	items_set.emit(new_items)
	items_changed.emit(new_items)


func item_was_in_history(item: ItemModel) -> bool: 
	return added_items_history.any(
		func(i: ItemModel): 
			if i == item: 
				return true
			return false
	)


func add_items(new_items: Array[ItemStack], by: Object = null) -> void: 
	#if _is_value_too_big(new_items.size()): 
		#_max_items_error.call(new_items)
		#return
	for item: ItemStack in new_items: 
		add_item(item, by)
	items_added.emit(new_items)


func add_item(new_item_stack: ItemStack, by: Object = null) -> void: 
	
	added_items_history.append(new_item_stack.model)
	
	for item_stack: ItemStack in items: 
		if item_stack.is_equal_to(new_item_stack) && !item_stack.is_full(): 
			var dupe_debug: ItemStack = ItemStack.from_item_stack(new_item_stack, self)
			
			item_stack.stack.add(new_item_stack.stack.current)
			
			item_added.emit(dupe_debug)
			items_changed.emit([dupe_debug] as Array[ItemStack])
			print_color.out_debug_wvalue("Inventory: %s added item to stack, new value" % by, item_stack)
			print_items()
			return
	
	# Checks if the item already exists in the inventory. 
	if is_full(): 
		_max_items_error.call(new_item_stack)
		return
		
	var dupe: ItemStack = ItemStack.from_item_stack(new_item_stack, self)
	items.append(dupe)
	
	if is_full(): 
		full.emit()
	
	item_added.emit(dupe)
	if is_new_item(new_item_stack.model): 
		obtained_new_item.emit(new_item_stack.model)
		
	items_changed.emit([dupe] as Array[ItemStack])
	print_color.out_debug_wvalue("Inventory: %s added item" % by, dupe)
	print_items()


func get_total_stack() -> int: 
	var stack: int = 0
	for item: ItemStack in items: 
		stack += int(item.stack.current)
	return stack
	

func is_overloaded() -> bool: 
	return items.size() == max_items


func is_full() -> bool: 
	return items.size() == max_items


func take_items_from_inventory(inventory: Inventory, _items: Array[ItemStack], by: Object = null) -> void: 
	add_items(inventory.remove_items(_items, by), by)


func take_item_from_inventory(inventory: Inventory, item: ItemStack, by: Object = null) -> void: 
	add_item(inventory.remove_item(item, by), by)


func take_inventory(inventory: Inventory, by: Object = null) -> void: 
	if self == inventory: 
		print_color.out_debug_wvalue("Inventory: Cannot take items from itself", inventory)
		return
	var taken_items: Array[ItemStack] = inventory.clear(by)
	#printerr(taken_items)
	add_items(taken_items, by)
	items_taken_from_inventory.emit(owner, taken_items)


#func take_items_from_inventory(by: Object, inventory: Inventory) -> void: 
	#if self == inventory: 
		#print_color.out_debug_wvalue("Cannot take items from itself", inventory)
		#return
	#add_items(inventory.clear(by))
	
	
func clear(by: Object) -> Array[ItemStack]:
	var all_items: Array[ItemStack] = remove_items(items, by)
	items_removed.emit(by, all_items)
	items_changed.emit(items)
	return all_items


func remove_items(new_items: Array[ItemStack], by: Object = null) -> Array[ItemStack]:
	var _items: Array[ItemStack] = []
	for new_item: ItemStack in new_items:
		_items.append(remove_item(new_item, by))
	items_removed.emit(_items)
	return _items


func remove_item(new_item: ItemStack, by: Object = null) -> ItemStack: 
	#var _item = items.pop_at(items.find(new_item))
	var index: int = find_item_by_model(new_item.model, true)
	#printerr("res: ", index)
	if index <= -1: 
		print_color.out_debug_wvalue("Inventory: Item does not exist", new_item)
		return null
		
	var item_stack: ItemStack = items[index]
	
	var taken_item: ItemStack = ItemStack.from_item_stack(new_item, self)
	
	#printerr(self)
	#print_items()
	item_stack.subtract_from_similar(new_item)
	
	if item_stack.is_empty(): 
		items.erase(item_stack)
	
	
	print_color.out_debug_wvalue("Inventory: %s removed item" % by, taken_item)
	print_items()
	item_removed.emit(taken_item)
	items_changed.emit(items)
	return taken_item

# old code
func has_item_name(item_name: StringName) -> bool:
	return find_item_by_name(item_name) > -1

# old code
func find_item_by_name(item_name: StringName) -> int:
	for i in items.size():
		if items[i].item_name == item_name:
			return i
	return -1

#
#func get_lowest_item_stack(model: ItemModel) -> ItemStack: 
	#var least: float = 100
	#return NodeTools.get_item_from_array(
		#items, 
		#func(item: ItemStack, _i: int): 
			#var count: float = min(item.stack.current, least)
			#return item.model == model && 
	#)
	
	
func count_item_by_model(model: ItemModel) -> int: 
	var count: int = 0
	for item_stack: ItemStack in items: 
		if item_stack.model == model: 
			count += int(item_stack.stack.current)
	return count

	# Purpose of item not full is so that the 
func find_item_by_model(model: ItemModel, item_not_full: bool = false) -> int: 
	#printerr("size: ", items.size())
	# FIXME
	for i: int in items.size(): 
		var item: ItemStack = items[i]
		#printerr("item: ", item.model)
		#printerr("model: ", model)
		#printerr("cond: ", item.model == model)
		#printerr(i)
		if item.model == model: 
			if item_not_full && item.model.maximum_stack > 1: 
				if !item.is_full(): 
					return i
			else: 
				return i
	return -1


func _to_string() -> String: 
	var string: String = "Inventory<#%s>(%s, items:%s)" % [get_instance_id(), owner, items]
	return string
	
	
# FIXME: NEEDS WORK
func _is_value_too_big(value: int) -> bool: 
	return max_items > 0 && value >= max_items
	
	
func print_items() -> void: 
	print_color.out_debug_wvalue("Inventory: Items are", items)
	
	
#func iterate_similar_items(item: ItemStack, method: Callable) -> void: 
	#
	#
## This function exists since duplicate(true) doesn't duplicate the items for some reason. 
func clone() -> Inventory: 
	var inventory: Inventory = Inventory.new()
	inventory.max_items = max_items
	inventory.owner = owner
	
	inventory.print_color.disabled = true
	for item_stack: ItemStack in items: 
		inventory.add_item(ItemStack.from_item_stack(item_stack, self))
	inventory.print_color.disabled = false
	
	return inventory
	
	
func is_new_item(item: ItemModel) -> bool: 
	if added_items_history.count(item) == 1: 
		return true 
	return false
	
	
func _save_properties() -> PackedStringArray: 
	return [
		"items", 
		"max_items",
		"added_items_history"
	]


func _load_update(data) -> void: 
	var item: ItemStack = data
	item.owner = self
	items_changed.emit([item] as Array[ItemStack])
	

# Completely removes everything, from the history
func reset() -> void: 
	added_items_history.clear()
	items.clear()
	printerr(items)
	
