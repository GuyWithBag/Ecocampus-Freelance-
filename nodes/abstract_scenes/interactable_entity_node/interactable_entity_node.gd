@tool
extends EntityNode
class_name InteractableEntityNode

@export var drop_audio: AudioManagerPlayer
@export var allowed_items: Array[ItemModel] = []
@export var dont_take_item: bool

signal item_rejected(item_stack: ItemStack)
signal item_accepted(item_stack: ItemStack)


func _on_mouse_drag_drop_area_dropped(drag_data: Dictionary) -> void:
	var item: ItemStack = drag_data["item"]
	var from_inventory: Inventory = item.owner
	if !dont_take_item: 
		inventory.take_item_from_inventory(from_inventory, item, self)
	drop_audio.play()
	InventoryGUI.this().update()


func mouse_drag_can_drop_condition(drag_data: Dictionary) -> bool: 
	var item: ItemStack = drag_data["item"]
	var result: bool = false
	if item.model in allowed_items: 
		result = true
	
	if result: 
		item_accepted.emit(item)
	else: 
		item_rejected.emit(item)
	return result
	
	
func _mouse_drag_can_drop_condition(_drag_data: Dictionary) -> bool: 
	return true
