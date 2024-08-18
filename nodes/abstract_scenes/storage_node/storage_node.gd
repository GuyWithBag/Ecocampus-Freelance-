extends EntityNode
class_name StorageNode

@export var drop_audio: AudioManagerPlayer
@export var goal_stack: int = 10

signal item_rejected(item_stack: ItemStack)
signal item_accepted(item_stack: ItemStack)

func _on_mouse_drag_drop_area_dropped(drag_data: Dictionary) -> void: 
	var item: ItemStack = drag_data["item"]
	var from_inventory: Inventory = item.owner
	inventory.take_item_from_inventory(from_inventory, item, self)
	drop_audio.play()
	InventoryGUI.this().update()
	#printerr(inventory.get_total_stack())
	
	# If this storage node's inventory has a total stack of 10, then it will add to the player data the +10
	if inventory.get_total_stack() == goal_stack: 
		PlayerManager.player_data.trash_can_items += goal_stack
	#print(InventoryGUI.this().inventory)


func mouse_drag_can_drop_condition(drag_data: Dictionary) -> bool: 
	var item: ItemStack = drag_data["item"]
	var result: bool = _mouse_drag_can_drop_condition(drag_data)
	if result: 
		item_accepted.emit(item)
	else: 
		item_rejected.emit(item)
	return result
	
	
func _mouse_drag_can_drop_condition(_drag_data: Dictionary) -> bool: 
	return true
	
	
