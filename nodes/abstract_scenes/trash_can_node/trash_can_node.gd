extends StorageNode
class_name TrashCanNode

@export var can_take: ItemModel.Type


func _mouse_drag_can_drop_condition(drag_data: Dictionary) -> bool: 
	var item: ItemStack = drag_data["item"]
	#var from_inventory: Inventory = item.owner
	#printerr("cond")
	return item.model.type == can_take
