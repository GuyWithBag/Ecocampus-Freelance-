@tool
extends Entity
class_name Player

signal current_cosmetic_changed

@export var default_cosmetic: Cosmetic

@export var current_cosmetic: Cosmetic: 
	set(value): 
		current_cosmetic = value
		current_cosmetic_changed.emit()
		
	get: 
		if current_cosmetic == null: 
			return default_cosmetic
		return current_cosmetic
		
# FIXME: BANDAID SOLUTION
@export var inventory: Inventory: 
	set(value): 
		inventory = value
		if inventory: 
			inventory.owner = self
			inventory.obtained_new_item.connect(_on_obtained_new_item)
		else:
			inventory.obtained_new_item.disconnect(_on_obtained_new_item)


# more bandaid solutions lol
# this will be used for quests who have no way of checking if the faucets/lights have been turned off without visiting the scenes first. 
# ^^ this ^^ problem exists when the player has turned off the faucets before they get to activate the quest. 
var faucets_turned_off: int
var lights_turned_off: int
var trash_can_items: int

func _init() -> void: 
	super._init()
	save.save_properties_as_resource_path = [
		"current_cosmetic"
	]


func _on_obtained_new_item(item: ItemModel) -> void: 
	ItemObtainedScreen.display(item)


func is_equipped() -> bool: 
	return current_cosmetic != default_cosmetic


func equip_cosmetic(cosmetic: Cosmetic) -> void: 
	current_cosmetic = cosmetic


func unequip_cosmetic() -> void: 
	current_cosmetic = default_cosmetic


func _save_properties() -> PackedStringArray: 
	var arr: PackedStringArray = [
		"current_cosmetic", 
		"inventory", 
		"faucets_turned_off", 
		"lights_turned_off", 
		"trash_can_items", 
	]
	arr.append_array(super._save_properties())
	return arr
	
	
func reset() -> void: 
	unequip_cosmetic()
	inventory.reset()
	faucets_turned_off = 0
	lights_turned_off = 0
	trash_can_items = 0
